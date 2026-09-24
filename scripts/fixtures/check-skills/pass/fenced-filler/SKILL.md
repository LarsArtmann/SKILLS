---
name: fenced-filler
description: >
  Use when verifying check 15 fence and blockquote awareness: this fixture
  quotes throat-clearing phrases only inside fenced code and blockquotes,
  which check 15 must not flag. Not a real skill; do not install.
metadata:
  tags: fixture, testing
---

# Fenced Filler Fixture

This fixture exists so `check-skills.sh --selftest` can prove check 15 is
fence- and quote-aware: a skill teaching against throat-clearing by
quoting the exact phrases must pass the gate.

## Quoted examples (must NOT fail)

```text
It is important to note that this sentence lives inside a fence.
```

> Needless to say, this blockquote quotes a banned phrase and must not count.

The banned phrases are only safe to quote inside fences or blockquotes;
a bare-prose use still hard-fails (see the fail/ fixture tree).
