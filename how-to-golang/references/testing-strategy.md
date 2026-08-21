# Testing Strategy

Distilled from rules 033-038. Testing is not optional — it's the safety net that enables confident change.

## Testing Pyramid for Go

```
     ╱  E2E  ╲          — Critical user journeys, run before release
    ╱ Integration ╲     — Real DB, real services, no mocks
   ╱  BDD (Ginkgo) ╲   — Behavior specification, not implementation
  ╱  Property-Based ╲  — Invariants across wide input ranges
 ╱  Unit (table-driven)╲ — Pure functions, fast, isolated
╱ Benchmark (continuous) ╲— Performance budgets in CI
```

## Rule 033: Test-Driven Development

Write tests before implementation. Minimum 80% code coverage. All tests must pass before merge.

### Go TDD with Ginkgo

```go
var _ = Describe("UserService", func() {
    Describe("Create", func() {
        Context("with valid input", func() {
            It("creates a user and returns an ID", func() {
                user, err := service.Create(ctx, validCmd)
                Expect(err).NotTo(HaveOccurred())
                Expect(user.ID).NotTo(BeZero())
            })
        })

        Context("with duplicate email", func() {
            It("returns ErrAlreadyExists", func() {
                _, _ = service.Create(ctx, validCmd)
                _, err := service.Create(ctx, validCmd)
                Expect(err).To(MatchError(domainerrors.ErrAlreadyExists))
            })
        })
    })
})
```

### Coverage Gate in CI

```yaml
- name: Run tests with coverage
  run: go test -coverprofile=coverage.out -covermode=atomic ./...
- name: Check coverage threshold
  run: |
    COVERAGE=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | sed 's/%//')
    if (( $(echo "$COVERAGE < 80" | bc -l) )); then
      echo "Coverage ${COVERAGE}% below 80%"
      exit 1
    fi
```

## Rule 034: Integration Testing

Test against real dependencies, not mocks. Use real databases, real queues.

### With testcontainers

```go
var _ = Describe("UserRepository", func() {
    var (
        repo     *UserRepository
        db       *sql.DB
        container *postgres.PostgresContainer
    )

    BeforeEach(func() {
        ctx := context.Background()
        var err error
        container, err = postgres.RunContainer(ctx,
            testcontainers.WithImage("postgres:16"),
            postgres.WithDatabase("testdb"),
            postgres.WithUsername("test"),
            postgres.WithPassword("test"),
        )
        Expect(err).NotTo(HaveOccurred())

        dsn, err := container.ConnectionString(ctx, "sslmode=disable")
        Expect(err).NotTo(HaveOccurred())

        db, err = sql.Open("pgx", dsn)
        Expect(err).NotTo(HaveOccurred())

        // Run migrations
        _, err = db.ExecContext(ctx, migrationSQL)
        Expect(err).NotTo(HaveOccurred())

        repo = NewUserRepository(db)
    })

    AfterEach(func() {
        db.Close()
        container.Terminate(context.Background())
    })

    It("persists and retrieves users", func() {
        user := &User{Email: "test@example.com", Name: "Test"}
        saved, err := repo.Save(ctx, user)
        Expect(err).NotTo(HaveOccurred())

        found, err := repo.FindByID(ctx, saved.ID)
        Expect(err).NotTo(HaveOccurred())
        Expect(found.Email).To(Equal("test@example.com"))
    })
})
```

## Rule 035: End-to-End Testing

Automate critical user journeys. Run against staging before every release.

```go
var _ = Describe("User Registration E2E", Ordered, func() {
    It("registers, confirms email, and logs in", func() {
        baseURL := "http://localhost:8080"

        // 1. Register
        regBody, _ := json.Marshal(CreateUserRequest{
            Email: "e2e@example.com",
            Name:  "E2E User",
        })
        resp, err := http.Post(baseURL+"/api/users", "application/json", bytes.NewReader(regBody))
        Expect(err).NotTo(HaveOccurred())
        Expect(resp.StatusCode).To(Equal(http.StatusCreated))

        // 2. Confirm email (simulated)
        confirmURL := resp.Header.Get("X-Confirmation-URL")
        resp, err = http.Get(baseURL + confirmURL)
        Expect(err).NotTo(HaveOccurred())
        Expect(resp.StatusCode).To(Equal(http.StatusOK))

        // 3. Login
        loginBody, _ := json.Marshal(LoginRequest{
            Email:    "e2e@example.com",
            Password: "test-password",
        })
        resp, err = http.Post(baseURL+"/api/auth/login", "application/json", bytes.NewReader(loginBody))
        Expect(err).NotTo(HaveOccurred())
        Expect(resp.StatusCode).To(Equal(http.StatusOK))

        var loginResp struct{ Token string }
        err = json.NewDecoder(resp.Body).Decode(&loginResp)
        Expect(err).NotTo(HaveOccurred())
        Expect(loginResp.Token).NotTo(BeEmpty())
    })
})
```

## Rule 036: Property-Based Testing

Verify invariants across wide input ranges. Complements example-based tests.

```go
import "testing/quick"

func TestEmailNormalization(t *testing.T) {
    err := quick.Check(func(email string) bool {
        normalized := normalizeEmail(email)
        // Property: normalized email is always lowercase
        return normalized == strings.ToLower(normalized)
    }, nil)
    if err != nil { t.Error(err) }
}

// With gopter for advanced property testing (generators, shrinking):
import (
    "github.com/leanovate/gopter"
    "github.com/leanovate/gopter/gen"
    "github.com/leanovate/gopter/prop"
)

func TestULIDSortability(t *testing.T) {
    properties := gopter.NewProperties(nil)
    properties.Property("ULIDs are lexicographically sortable", prop.ForAll(
        func(a, b int) bool {
            id1 := generateULID(time.Unix(int64(a), 0))
            id2 := generateULID(time.Unix(int64(b), 0))
            if a < b { return id1 < id2 }
            return id1 >= id2
        },
        gen.Int(), gen.Int(), // one generator per parameter
    ))
    properties.TestingRun(t)
}
```

## Rule 038: Load Testing

Define performance budgets. Run load tests before every release. Fail builds that exceed thresholds.

```go
func TestAPIConcurrency(t *testing.T) {
    if testing.Short() { t.Skip("skipping load test") }

    concurrent := 100
    maxDuration := 200 * time.Millisecond
    errors := make(chan error, concurrent)

    var wg sync.WaitGroup
    for i := 0; i < concurrent; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            start := time.Now()
            resp, err := client.Get("/api/users")
            if err != nil { errors <- err; return }
            if time.Since(start) > maxDuration {
                errors <- fmt.Errorf("response took %v", time.Since(start))
            }
        }()
    }
    wg.Wait()
    close(errors)

    for err := range errors { t.Error(err) }
}
```

## Snapshot Testing (go-snaps)

For API responses and structured data that rarely changes. Import the
**package** path (module root has no Go files): `github.com/gkampitakis/go-snaps/snaps`.
Inside a Ginkgo `It` block there is no `*testing.T` — pass `GinkgoT()`
(it satisfies `testing.TB`):

```go
It("returns expected user API response", func() {
    resp, err := client.Get("/api/users/123")
    Expect(err).NotTo(HaveOccurred())
    snaps.MatchSnapshot(GinkgoT(), resp.Body)
})
```

## Test Quality Metrics

| Metric               | Target        | Tool                             |
| -------------------- | ------------- | -------------------------------- |
| Line Coverage        | ≥ 80%         | `go test -cover`                 |
| Test Execution Time  | < 5 min total | CI pipeline                      |
| Flaky Test Rate      | 0%            | No retries — fix the flake       |
| Test Independence    | 100%          | No shared state between tests    |
| Benchmark Regression | 0%            | `go test -bench` + CI comparison |
