"""Self-tests for annotate-prose and the shared marker builder.

Run: python3 annotate-prose_test.py
(The source files have hyphens, so they are loaded via importlib below.)
Mirrors the annotate-rows_test.py precedent (T56): asserts the h/v/p/w
markers — including the UTC-default date for the `p` kind — plus the
prose script's item-matching and continuation-strike behavior on a
scratch file.
"""

import importlib.util
import tempfile
from datetime import UTC, datetime
from pathlib import Path


def load(name, file_name):
    spec = importlib.util.spec_from_file_location(
        name, Path(__file__).with_name(file_name)
    )
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


markers = load("annotate_markers", "annotate-markers.py")
prose = load("annotate_prose", "annotate-prose.py")
marker_for = markers.marker_for


def main() -> int:
    failures = []

    def check(name, got, want):
        if got != want:
            failures.append(f"{name}: got {got!r}, want {want!r}")

    # --- marker_for: the shared vocabulary ---
    check("h single", marker_for("h", "abc1234"), "done at `abc1234`")
    check("h multi", marker_for("h", "a1,b2"), "done at `a1`, `b2`")
    check("v evidence", marker_for("v", "live curl check"), "done — live curl check")
    check("v strips redundant done", marker_for("v", "done: verified live"), "done — verified live")
    check("v bare", marker_for("v", "done"), "done")
    check("p explicit date", marker_for("p", "2026-09-24"), "done (docs-health pass 2026-09-24)")
    today = datetime.now(tz=UTC).date().isoformat()
    check("p UTC default", marker_for("p", "-"), f"done (docs-health pass {today})")
    check("w", marker_for("w", "user decision"), "**Won't implement — user decision.**")
    try:
        marker_for("x", "y")
        failures.append("bad kind: no SystemExit raised")
    except SystemExit:
        pass

    # --- prose annotation: end-to-end on a scratch file ---
    sample = (
        "# Report\n"
        "\n"
        "## f) Next\n"
        "\n"
        "1. First item\n"
        "   continued line\n"
        "2. Second item\n"
        "\n"
        "3. After a blank line (own item)\n"
        "\n"
        "## g) Tail\n"
        "\n"
        "1. Different section, same number\n"
    )
    with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False) as f:
        f.write(sample)
        target = Path(f.name)
    try:
        sys_argv_backup = prose.sys.argv
        prose.sys.argv = ["annotate-prose.py", str(target), "## f)", "1:h:abc1234", "2:w:never wanted"]
        prose.main()
        out = target.read_text()
        check("item 1 struck", "~~First item~~ done at `abc1234`" in out, True)
        check("item 1 continuation struck", "   ~~continued line~~" in out, True)
        check("item 2 struck", "~~Second item~~ **Won't implement — never wanted.**" in out, True)
        check("blank line not struck", "\n\n3. After a blank line" in out, True)
        check("section g untouched", "1. Different section, same number" in out, True)
        # Already-annotated guard: re-running item 1 must fail loudly.
        prose.sys.argv = ["annotate-prose.py", str(target), "## f)", "1:v:again"]
        try:
            prose.main()
            failures.append("already-annotated guard: no SystemExit")
        except SystemExit:
            pass
        prose.sys.argv = sys_argv_backup
    finally:
        target.unlink()

    if failures:
        print(f"FAILED ({len(failures)}):")
        for f_ in failures:
            print(f"  - {f_}")
        return 1
    print("OK: annotate-prose_test.py passed (markers + prose strikes + guards).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
