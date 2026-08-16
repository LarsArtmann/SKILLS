# Performance Tuning: Concurrency, Memory, IO, and Hardware Economics

GOMAXPROCS is a **hardware-topology default, not a workload optimum**. It answers "how many threads can run", never "how many threads should run for this workload". On a 32-CPU machine, bandwidth-bound work can peak at ~20 threads: past that knee, extra threads add memory-controller contention, cache-line ping-pong, and queueing delay while throughput stays flat or drops. SMT makes it worse — hyperthread siblings share the same core's load/store ports and L1/L2, so they are nearly useless for bandwidth-bound work.

## Contents

1. [Decision tree: choosing a concurrency level](#decision-tree-choosing-a-concurrency-level)
2. [Measure first: profiling and benchmark methodology](#measure-first-profiling-and-benchmark-methodology)
3. [Finding the knee: measure, don't guess](#finding-the-knee-measure-dont-guess)
4. [Capping parallelism in code](#capping-parallelism-in-code)
5. [Containers: GOMAXPROCS and cgroup quotas](#containers-gomaxprocs-and-cgroup-quota)
6. [GC: bandwidth share and deployment knobs](#gc-bandwidth-share-and-deployment-knobs)
7. [Memory: allocation and cache-aware data layout](#memory-allocation-and-cache-aware-data-layout)
8. [Synchronization](#synchronization)
9. [IO](#io)
10. [Network and remote datastores](#network-and-remote-datastores)
11. [NUMA: what the runtime does and doesn't do](#numa-what-the-runtime-does-and-doesnt-do)
12. [What this file deliberately does not cover](#what-this-file-deliberately-does-not-cover)
13. [Verification status](#verification-status)

## Decision tree: choosing a concurrency level

```
What does the bottleneck look like?
│
├── Compute-bound (crypto, compression, parsing, pure math)
│   → Scales to GOMAXPROCS. Fan out freely; the ALUs are the limit.
│
├── Bandwidth-bound (streaming/hashing/copying large buffers)
│   → Measure the knee with a -cpu sweep; cap workers below it.
│     The shared memory controller saturates before the cores do.
│
├── Latency-bound service with p99 SLOs
│   → Cap below the knee. Oversubscription inflates tail latency
│     (queueing hits the slowest requests first) long before
│     mean throughput degrades.
│
├── IO-bound (network, disk, DB calls)
│   → Concurrency limit comes from the remote end (connection pool,
│     DB max connections), not from CPU count at all.
│
└── Mixed → profile first (see "Measure first");
    the dominant cost decides the policy per hot path.
```

## Measure first: profiling and benchmark methodology

Tuning blind produces cargo cults. Before changing anything, know which layer is actually the bottleneck.

**Profiles to know (all stdlib, `runtime/pprof` / `net/http/pprof` for live services):**

| Profile                      | Catches                                                    | How to enable                                        |
| ---------------------------- | ---------------------------------------------------------- | ---------------------------------------------------- |
| CPU                          | Where cycles go                                            | `go test -cpuprofile`, pprof endpoint               |
| Heap (`inuse_space`)         | What live memory is held by whom                           | `go test -memprofile`, pprof endpoint               |
| Heap (`alloc_space`)         | Allocation churn (GC pressure) even if nothing is retained | pprof endpoint, `-memprofile` with `-alloc_space`   |
| Goroutine                    | Leaks, blocked goroutine stacks                            | pprof `goroutine` profile                            |
| Mutex                        | Lock contention hotspots                                   | `runtime.SetMutexProfileFraction(1)`                |
| Block                        | Time blocked on channels/locks/syscalls                    | `runtime.SetBlockProfileRate(1)`                    |
| Execution tracer             | Scheduler latency, GC pauses, goroutine wake-up gaps       | `go test -trace` / `runtime/trace`, `go tool trace` |

Use `pprof.Labels` to attach request/endpoint labels so production profiles aggregate by code path, not by shared function.

**Goroutine leaks:** `go.uber.org/goleak` in `TestMain` catches goroutines that outlive tests — the cheapest time to find a leak is in CI, not from an RSS graph in production.

**Benchmark methodology (the part most people get wrong):**

- Use `for b.Loop()` (Go 1.24+) — it resets the timer around setup/cleanup so neither pollutes the measurement.
- For pre-1.24 loops (`for i := 0; i < b.N; i++`), assign results to a package-level sink so the compiler cannot eliminate the work.
- `b.ReportAllocs()` on every benchmark — allocation regressions matter as much as time.
- `b.RunParallel` when the hot path is contended; a single-goroutine benchmark hides lock convoying.
- Compare with `benchstat` (golang.org/x/perf/cmd/benchstat), never by eyeballing ±5% noise: run `-count=10`, feed old and new output files to benchstat, and trust only deltas it marks significant.

## Finding the knee: measure, don't guess

The `-cpu` flag reruns benchmarks at multiple GOMAXPROCS values — the scaling curve falls out directly:

```bash
go test -bench=StreamBuffer -cpu=4,8,12,16,20,24,32 -benchmem ./
```

Read the output as a curve: the knee is where per-iteration time stops improving or reverses (e.g. `ns/op` flat from 20→24→32). That number is your worker cap.

Rules of the measurement:

- **The knee is machine-specific AND access-pattern-specific.** Sequential streaming, random access, and pointer-chasing each saturate differently. Re-measure on the deployment hardware, not your laptop.
- **Noisy neighbors lower the effective knee** — a number measured on an idle box will not hold on shared hardware.
- **Energy/heat:** a throughput-first batch job capped at the knee often delivers the same work for a large fraction of the power. Free win on cloud billing and laptops.

## Capping parallelism in code

Prefer a worker cap over changing GOMAXPROCS — it scopes the decision to the hot path instead of the whole process:

```go
// errgroup: g.Go blocks until a slot frees up
g, ctx := errgroup.WithContext(ctx)
g.SetLimit(20) // the measured knee, not runtime.NumCPU()
for _, item := range items {
    g.Go(func() error { return process(ctx, item) })
}
err := g.Wait()

// or a semaphore channel when errgroup doesn't fit
sem := make(chan struct{}, 20)
```

When to lower GOMAXPROCS itself (process-wide, owned by `main`, never in libraries):

- Bandwidth-bound batch jobs where even GC worker parallelism hurts (see GC section)
- Serving multiple processes per box (one GOMAXPROCS each) or leaving headroom for sidecars
- Benchmark isolation

## Containers: GOMAXPROCS and cgroup quotas

Since Go 1.25, the runtime default on Linux considers the cgroup CPU quota (plus logical CPU count and affinity mask) and **updates it periodically** if the quota changes. Verify the deployed value once at startup:

```go
log.Info("runtime", "gomaxprocs", runtime.GOMAXPROCS(0))
```

Gotchas:

- Setting `GOMAXPROCS` env or calling `runtime.GOMAXPROCS(n)` **disables automatic updates** — if you pin it, you own it.
- Pre-1.25 modules (or `GODEBUG=containermaxprocs=0`, the default for language version ≤ 1.24) default to host CPU count: a 64-core node with a 2-CPU quota spawns a scheduler and GC sized for 64. Pin `GOMAXPROCS` to the quota, or import `uber-go/automaxprocs` (legacy codebases).
- Throttling at the cgroup level shows up as unexplained p99 spikes; check container throttled-seconds metrics before blaming the app.

## GC: bandwidth share and deployment knobs

Background GC mark work targets **25% of GOMAXPROCS** (`gcBackgroundUtilization = 0.25` in `runtime/mgcpacer.go`). Marking scans the heap — that is memory bandwidth and cache pollution competing with your workers on the same memory controller.

Implications:

- On bandwidth-bound services, a lower GOMAXPROCS sometimes *increases* throughput purely by throttling GC parallelism. Measure with a `-cpu` sweep — this is the same knee, measured end-to-end.
- Pointer-light data (values, arrays, SoA over AoS, contiguous slices instead of pointer graphs) cuts both your access cost and the GC's scan cost.
- Set `GOMEMLIMIT` to cap heap size on services; a heap that fits in cache is a heap the GC scans cheaply.

**Deployment knobs:**

| Knob                                  | Default   | What it does / when to touch                                                                                                                                              |
| ------------------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `GOGC`                                | `100`     | Heap grows to (live × (1+GOGC/100)) before next cycle. Raising it = fewer cycles, more memory; lowering = more cycles, less memory. Tune together with GOMEMLIMIT, not alone. |
| `GOMEMLIMIT`                          | unlimited | Soft limit on total memory (heap + stacks + runtime). The container OOM guard: set to ~90% of the container memory limit. It is soft — the runtime would rather GC harder than crash. |
| `GOGC=off` + `GOMEMLIMIT`             | —         | Batch-job trick: no GC cycles mid-run until the limit is hit; throughput win when the job's live set is bounded.                                                           |
| `GODEBUG=madvdontneed`                | on        | Linux default is `MADV_DONTNEED`, so freed heap pages drop out of RSS promptly. Setting `madvdontneed=0` opts into `MADV_FREE` (lazier RSS, marginally cheaper).           |
| `debug.FreeOSMemory()`                | —         | Forces GC + returns memory to the OS. It is a full-STW-cycle tool for idle transitions, not a per-request knob. Calling it in hot paths is a self-inflicted pause.          |

**RSS vs heap:** process RSS will exceed the Go heap (stacks, runtime, freed-but-not-returned pages). Monitor `runtime/metrics` heap numbers for capacity planning; use RSS for container limits. A sawtooth RSS on an idle-ish service is normal GC behavior, not a leak — a monotonic RSS climb with flat heap is.

## Memory: allocation and cache-aware data layout

### Cache-aware data modeling

The memory hierarchy is the real machine: registers ~ns-free, L1 ~4 cycles, L2 ~12, L3 ~40, DRAM ~200+ cycles. Every technique below is about keeping the hot set in the small fast levels.

- **False sharing:** two goroutines writing different fields of the same struct can share one 64-byte cache line — every write invalidates the other core's copy. Symptom: contention-shaped profiles with no contended lock. Fix: pad hot per-goroutine/per-P state with `cpu.CacheLinePad` (golang.org/x/sys/cpu).
- **Field ordering:** group fields by size/alignment to cut struct padding. The `fieldalignment` analyzer (golang.org/x/tools) reports wasteful layouts. Apply where it matters (hot, high-volume types) — don't churn domain types for a few bytes.
- **SoA over AoS:** if a loop touches one field across many records, `[]field` beats `[]struct` — you stream exactly the bytes you use instead of dragging whole cache lines per record.
- **Tile/chunk:** process data in blocks sized to L2/L3 so each byte is loaded from DRAM once and reused from cache. This converts DRAM-bound (doesn't scale with cores) into cache-bound (does).
- **Contiguous over pointer-chasing:** slices of values prefetch well; linked pointer graphs defeat the prefetcher and make the GC scanner chase pointers. Same data, 2-10x access-cost difference is common — measure with a profile.

### Allocation discipline

- **Preallocate:** `make([]T, 0, n)` / sized maps when the count is knowable — append-growth is repeated copy + GC garbage. Missing capacity hints are the most common benign-looking benchmark regression.
- **Escape analysis:** `go build -gcflags='-m -l'` prints what escapes to the heap. Values that escape (returned pointers, values stored in interfaces, captured by escaping closures) cost a malloc + GC scan; values that stay on the stack cost nothing.
- **`sync.Pool`** recycles hot buffers between GC cycles. It is a recycle bin, not a cache — anything in it may be dropped at any GC, so never use it for correctness or retention. Use for per-request buffers (byte slices, temp objects) in allocation-hot paths.
- **Strings vs bytes:** every `string(bs)` / `[]byte(s)` copies. Hot loops should settle on one representation; keep map keys as `string` but avoid converting per lookup.
- **Big allocations:** very large objects (tens of KiB and up) get their own spans and cost page-level work. Stream instead of buffering whole files/responses in memory (see IO).

## Synchronization

- **Profile before sharding.** The mutex profile names the contended lock; redesigning data structures around an unprofiled hunch usually adds complexity without removing the bottleneck.
- **Counters → atomics.** `atomic.Int64` increments under mutex are a classic self-inflicted serialization point.
- **`sync.RWMutex` is not free:** read locks still bounce the lock's cache line across cores. A read-mostly map behind an RWMutex loses to sharded plain maps or `atomic.Pointer` snapshots at high core counts. RWMutex earns its keep at moderate read concurrency with rare writes — benchmark it.
- **`sync.Map` is niche** (its own doc says most code should use an ordinary map + lock): it wins when keys are written once and read many times, or goroutines work on disjoint key sets. High-churn maps perform worse than a plain map + mutex.
- **Channel costs:** every channel operation is a lock + potential scheduler interaction. Batching (one send of a slice beats N sends of items) removes both when the consumer can absorb batches. Unbuffered channels are synchronization points — exactly right for pipelines, wasteful when used as queues.
- **Bound goroutine count** on fan-out (see [Capping parallelism](#capping-parallelism-in-code)) — unbounded `go func()` per request/item is how latency SLOs die.

## IO

- **Buffer sizes:** `bufio` defaults to 4096 bytes. For large sequential streams, `bufio.NewReaderSize(r, 128<<10)` (or a `sync.Pool` of buffers) cuts syscall count dramatically. Unbuffered small reads on an `os.File` are one syscall each.
- **`io.Copy` is smart, help it:** `io.Copy` uses `ReaderFrom`/`WriterTo` when either side implements them — that hands the whole buffer to the OS/writer and skips an intermediate copy. Implement these two interfaces on hot custom types.
- **Gather writes:** `net.Buffers` (a `[][]byte`) writes multiple buffers in one OS-level batch write (`writev`) — one syscall instead of N for header+payload patterns.
- **Batch syscalls:** read many → process → write many. Per-item read/write loops pay syscall tax (plus context switches) per element.
- **Durability costs money:** buffered write « `fdatasync` < `fsync` (metadata). Group commits: one fsync per batch of writes, not per write. On Linux use `syscall.Fdatasync` when only file data (not size/metadata) changed.
- **FD limits:** every open file and socket is a descriptor; high-connection services need `ulimit -n` raised (systemd `LimitNOFILE` or equivalent) or they fail at exactly the load you succeeded at in the load test.
- **Stream, don't load** (rule 013 in [./rules.md](./rules.md)): constant memory beats O(n) memory, and it composes with the batching advice above.

## Network and remote datastores

### HTTP client defaults are a trap

`http.Transport` defaults: `MaxIdleConnsPerHost = 2`, `MaxIdleConns = 0` (no limit). Consequence for a service making concurrent calls to one internal API: only 2 idle connections are kept; bursts beyond that create-and-tear connections (TCP+TLS handshake per request — often more expensive than the request itself). Set `MaxIdleConnsPerHost` to your expected concurrent calls per host.

### Protocol choices

- **Keep-alive everywhere** for service-to-service traffic — Go enables it by default; don't disable it.
- **TCP_NODELAY is already on** (Go sets no-delay by default) — data is sent immediately; nothing to do, but don't switch it off.
- **HTTP/2 multiplexing** shines for many small requests over one connection, but a single connection can head-of-line-block behind one large response. If your traffic mixes tiny and huge payloads, benchmark both protocols before assuming HTTP/2 is "faster".
- **Compression is a CPU-for-bandwidth trade** — the exact trade the concurrency knee measures. On fast networks between services, compression can be a net loss; on WAN links it usually wins. zstd (klauspost/compress) costs substantially less CPU per byte than stdlib gzip at similar ratios — benchmark on your payload shapes.

### Timeouts (both directions, always)

Defaults of zero mean "hang forever": set `http.Client.Timeout`, Transport-level dial/TLS/response-header timeouts on clients, and `ReadHeaderTimeout`/`ReadTimeout`/`WriteTimeout`/`IdleTimeout` on servers. Missing server read timeouts are how one slow client pins a connection and a goroutine (slowloris-shaped resource exhaustion).

### Database connections (`database/sql`)

- **Defaults: `MaxOpenConns` 0 = unlimited.** An unbounded pool will happily open more connections than the database can serve — the remote end, not your CPU count, is the limit. Set `SetMaxOpenConns` to the DB's real capacity, `SetMaxIdleConns` to match expected steady concurrency (avoid connection churn), and `SetConnMaxLifetime`/`SetConnMaxIdleTime` to survive LB/firewall idle drops.
- **N+1 queries:** one query returning N rows beats N queries. Batch `IN (...)` reads, multi-row inserts, and `rows.Scan` into preallocated slices.
- This is the decision-tree "IO-bound" case: the pool size is your concurrency cap for that path.

### Latency geography

Memory access is orders of magnitude cheaper than a same-DC round trip, which is orders of magnitude cheaper than cross-region. Corollary: batch aggressively across the WAN, chatter is cheap within the rack, and a "fast" in-process cache beats a "fast" remote cache every time it hits.

## NUMA: what the runtime does and doesn't do

The Go scheduler and allocator are **not NUMA-aware**: no node placement policy for heap arenas, topology-blind work stealing, and threads migrate between nodes by design (that is what makes Go cooperate with cgroups and `taskset`). Remote-node DRAM costs ~1.5-2x local latency. Real tracking issue: golang/go#78044 ("degraded performance on multi-NUMA-node machines", open).

When to care: multi-socket servers running allocation-heavy or bandwidth-bound Go. Not single-socket boxes, not laptops, not web services whose request latency is dominated by network/DB time.

Mitigations, in escalation order (measure with `numastat` / `perf c2c` before investing in any of them):

1. **Usually nothing.** Remote DRAM adds ~100ns; a typical request spends milliseconds elsewhere.
2. `numactl --interleave=all ./app` — round-robins pages across nodes, converting worst-case-remote into average-remote. The standard first try for allocation-heavy multi-socket services.
3. `runtime.LockOSThread` + OS affinity for dedicated per-node hot loops.
4. Share-nothing: run N single-node processes under `taskset`, one per node, instead of one process — sidesteps the runtime entirely.

## What this file deliberately does not cover

- **Library choices** (json/v2, xxh3, blake3, otter, failsafe-go...) — owned by [./rules.md](./rules.md) and [./banned-libraries.md](./banned-libraries.md).
- **CI benchmark wiring** — owned by [./rules.md](./rules.md) "Continuous Benchmarking". This file covers methodology; that file covers automation.
- **io_uring / async runtime libraries** — not stdlib, fast-moving; do not encode into policy without a verified, versioned need.
- **Kernel tuning** (THP, IRQ affinity, CPU governor) — ops territory, machine-specific, claims would be unverified here.

## Verification status

| Claim                                                            | Status      | Source                                                                            |
| ---------------------------------------------------------------- | ----------- | --------------------------------------------------------------------------------- |
| `-cpu` flag reruns benchmarks at listed GOMAXPROCS values        | ✅ Verified | `go help testflag`, Go 1.26.5                                                     |
| `testing.B.Loop` exists, resets timer around setup/cleanup       | ✅ Verified | `go doc testing.B.Loop`, Go 1.26.5                                                |
| GC background mark utilization = 25% of GOMAXPROCS               | ✅ Verified | `runtime/mgcpacer.go` (`gcBackgroundUtilization = 0.25`), Go 1.26.5               |
| GOMAXPROCS default considers cgroup quota (Linux), auto-updates  | ✅ Verified | `go doc runtime.GOMAXPROCS`, Go 1.26.5                                            |
| Env var / `runtime.GOMAXPROCS(n)` disables automatic updates     | ✅ Verified | `go doc runtime.GOMAXPROCS`, Go 1.26.5                                            |
| `errgroup.SetLimit(n)` blocks `Go` at the limit                  | ✅ Verified | pkg.go.dev/golang.org/x/sync/errgroup                                             |
| `DefaultMaxIdleConnsPerHost = 2`; `MaxIdleConns` 0 = no limit    | ✅ Verified | `net/http/transport.go` (Go 1.26.5) + `go doc net/http.Transport`                  |
| `database/sql` `MaxOpenConns` default 0 (unlimited)              | ✅ Verified | `database/sql/sql.go` SetMaxOpenConns doc, Go 1.26.5                               |
| `bufio` default buffer 4096 bytes                                | ✅ Verified | `bufio/bufio.go` (`defaultBufSize = 4096`), Go 1.26.5                              |
| TCP_NODELAY (no delay) on by default                             | ✅ Verified | `go doc net.TCPConn.SetNoDelay`, Go 1.26.5                                         |
| `net.Buffers` optimized into batch write (writev)                | ✅ Verified | `go doc net.Buffers`, Go 1.26.5                                                    |
| `syscall.Fdatasync` exists (Linux)                               | ✅ Verified | `go doc syscall.Fdatasync`, Go 1.26.5                                              |
| `pprof.Labels` exists for profile attribution                    | ✅ Verified | `go doc runtime/pprof.Labels`, Go 1.26.5                                           |
| `-gcflags=-m` prints optimization (escape) decisions             | ✅ Verified | `go tool compile -h`, Go 1.26.5                                                    |
| Linux default `MADV_DONTNEED`; `GODEBUG=madvdontneed=0` → MADV_FREE | ✅ Verified | `runtime/extern.go` GODEBUG docs, Go 1.26.5                                      |
| Arena experiment exists behind GOEXPERIMENT (experimental, unsupported) | ✅ Verified | `internal/goexperiment/flags.go`, Go 1.26.5 — treat as experimental, not policy |
| `cpu.CacheLinePad` in golang.org/x/sys/cpu                       | ✅ Verified | golang/sys `cpu/cache.go`: "used to pad structs to avoid false sharing"            |
| `fieldalignment` analyzer exists                                 | ✅ Verified | golang/tools `go/analysis/passes/fieldalignment`                                   |
| `benchstat` exists                                               | ✅ Verified | golang/perf `cmd/benchstat`                                                        |
| `goleak` exists                                                  | ✅ Verified | uber-go/goleak                                                                     |
| klauspost/compress exists (zstd)                                 | ✅ Verified | github.com/klauspost/compress                                                      |
| Scheduler/allocator not NUMA-aware; multi-NUMA perf degradation  | ✅ Verified | golang/go#78044 (open); no NUMA API in `runtime` docs                             |
| `uber-go/automaxprocs` exists for pre-1.25 container defaults    | ✅ Verified | pkg.go.dev/github.com/uber-go/automaxprocs                                         |
| Bandwidth knee example (~20 of 32 CPUs)                          | ⚠️ Anecdote | One measurement on one machine (2026-08-16); illustrative, not portable — measure  |
| Cache/DRAM cycle latencies, NUMA 1.5-2x, syscall context-switch costs | ⚠️ Order-of-magnitude | Standard architecture knowledge (hardware-dependent); used qualitatively, verify on target HW |
