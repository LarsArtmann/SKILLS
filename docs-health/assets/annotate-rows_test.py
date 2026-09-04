"""Self-tests for annotate-rows.marker_for.

Run (the source file has a hyphen, so import via importlib):
python3 -c "import importlib.util,sys; s=importlib.util.spec_from_file_location('ar','annotate-rows.py'); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); exec(open('annotate-rows_test.py').read().replace('from annotate_rows import marker_for','marker_for = m.marker_for'))"
"""

import sys

from annotate_rows import marker_for


def main() -> int:
    failures = []

    def check(name, got, want):
        if got != want:
            failures.append(f"{name}: got {got!r}, want {want!r}")

    # v-kind renders "done — <evidence>" with no nested parens...
    check("v plain", marker_for("v", "verified live 2026-08-29"), "done — verified live 2026-08-29")
    # ...and does NOT double the "done" when the value already carries one
    # (the 2026-08-29 sweep shipped "done (done — ...)" markers).
    check("v strips leading done", marker_for("v", "done — some evidence"), "done — some evidence")
    check("v strips 'done:'", marker_for("v", "done: x"), "done — x")
    check("v strips 'done '", marker_for("v", "done at the site"), "done — at the site")
    check("v empty", marker_for("v", ""), "done")
    # h/p/w unchanged
    check("h", marker_for("h", "abc123"), "done at `abc123`")
    check("p default", marker_for("p", "-").startswith("done (docs-health pass "), True)
    check("w", marker_for("w", "gated upstream"), "**Won't implement — gated upstream.**")

    if failures:
        print("\n".join(failures))
        return 1

    print("annotate-rows self-tests: all passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
