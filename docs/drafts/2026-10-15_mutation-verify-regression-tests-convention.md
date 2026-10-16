## Problem

The best test-quality practice in this fleet is oral tradition: revert the fix, watch the new regression test fail with the EXACT original symptom, restore, watch it pass. BuildFlow's own vendor-consistency regression tests were built exactly this way on 2026-09-11 — parser temporarily reverted, both subtests failed with the original "is explicitly required in go.mod, but not marked as explicit in vendor/modules.txt" message, restored, full suite green. httputil's testing conventions codify the same discipline. BuildFlow's AGENTS.md does not mention it anywhere.

## Ask

**One bullet in AGENTS.md testing conventions:** every regression test is mutation-verified — fix temporarily reverted, test must fail with the original message (not merely compile or fail vaguely), then restored. Measured cost when the 06-16 session did it: ~3 minutes. It converts "I wrote a test" into "the test catches the bug".

💘 Generated with Crush
