"""Self-tests for annotate-rows.

Run: python3 annotate-rows_test.py
(The source file has a hyphen, so it is loaded via importlib below.)
"""

import importlib.util
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    "annotate_rows", Path(__file__).with_name("annotate-rows.py")
)
_mod = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_mod)

marker_for = _mod.marker_for
already_annotated = _mod.already_annotated
outside_code_spans = _mod.outside_code_spans


def main() -> int:
    failures = []

    def check(name, got, want):
        if got != want:
            failures.append(f"{name}: got {got!r}, want {want!r}")

    # outside_code_spans: tildes inside code spans are not strikethrough...
    check(
        "code-span tildes stripped",
        outside_code_spans("| x | skip guard when `~~...~~` occurs |"),
        "| x | skip guard when  occurs |",
    )
    check("plain text kept", outside_code_spans("a ~~b~~ c"), "a ~~b~~ c")
    check(
        "doubled-backtick span stripped",
        outside_code_spans("x ``a`b`` y"),
        "x  y",
    )

    # already_annotated: the 2026-09-16 F12.1-class false trip — a row whose
    # task text QUOTES the marker syntax must count as unannotated...
    check(
        "code-span tildes are not annotation",
        already_annotated(
            "| F12.1 | skip already-annotated guard when `~~` occurs in code spans | High |"
        ),
        False,
    )
    # ...while real markers still trip it
    check(
        "struck row trips", already_annotated("| M1 | ~~task~~ done at `abc` |"), True
    )
    check("clean row passes", already_annotated("| M1 | task | High |"), False)

    # v-kind renders "done — <evidence>" with no nested parens...
    check(
        "v plain",
        marker_for("v", "verified live 2026-08-29"),
        "done — verified live 2026-08-29",
    )
    # ...and does NOT double the "done" when the value already carries one
    # (the 2026-08-29 sweep shipped "done (done — ...)" markers).
    check(
        "v strips leading done",
        marker_for("v", "done — some evidence"),
        "done — some evidence",
    )
    check("v strips 'done:'", marker_for("v", "done: x"), "done — x")
    check("v strips 'done '", marker_for("v", "done at the site"), "done — at the site")
    check("v empty", marker_for("v", ""), "done")
    # h/p/w unchanged
    check("h", marker_for("h", "abc123"), "done at `abc123`")
    check("p default", marker_for("p", "-").startswith("done (docs-health pass "), True)
    check(
        "w", marker_for("w", "gated upstream"), "**Won't implement — gated upstream.**"
    )

    if failures:
        print("\n".join(failures))
        return 1

    print("annotate-rows self-tests: all passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
