---
name: signal-fixture
description: >
  Use when testing the --signal counters: this fixture pins known
  preamble/prose/filler/jargon counts so counter drift is caught by
  check-skills.sh --selftest. Not a real skill; do not install.
metadata:
  tags: fixture, testing
---

# Signal Fixture

Preamble one.
Preamble two.

## Body

alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo lima mike november oscar papa quebec romeo sierra tango uniform victor whiskey xray yankee zulu one two three four five six seven eight nine ten eleven twelve thirteen

The `split-brain` term above carries inline code, so this paragraph must not count as prose even though it is long.

Jargon without a gloss is flagged by the advisory counter only.

> It is important to note that a blockquote quoting filler must not count.

```
It's worth noting that fenced filler must not count either.
```
