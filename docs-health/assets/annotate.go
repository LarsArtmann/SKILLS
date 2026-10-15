// annotate — docs-health annotation toolkit.
//
// Single Go program replacing the five Python assets (annotate-rows.py,
// annotate-prose.py, annotate-status-items.py, check-rows.py,
// annotate-markers.py): one build, one marker vocabulary — the importlib
// trick (hyphenated filenames) and the marker drift it existed to prevent
// both disappear.
//
// Run: go run annotate.go <subcommand> ...
//
//	rows [--dry-run] [--section <prefix>] <file> <row-id>:<kind>:<value>...
//	prose [--dry-run] <file> <section-prefix> <row-id>:<kind>:<value>...
//	status-items [--verify] <file> <specfile>          (spec lines: key<TAB>verdict)
//	emit-keys <file> <lineno> [<lineno>...]            (paste-ready N@substring keys)
//	check-rows <file>...                               (exit 1 on PARTIAL table rows;
//	                                                   a <!-- check-rows:ledger --> line
//	                                                   above a table exempts it)
//	self-test
//
// Marker kinds (shared vocabulary, docs-health SKILL.md ANNOTATE):
// h = done at `hash`   v = done — <evidence>   p = done (docs-health pass <date>)
// w = **Won't implement — <reason>.**   n = **NOT-DO — <reason>.**
// r = **→ <verdict>** (routed, NO strike — 2026-09-29+ house grammar)
//
// Invariants carried over from the Python originals: all specs must match
// exactly once before anything is written (atomic); already-annotated guards
// ignore tildes inside inline code spans; annotate-rows reads the file back
// after writing and restores the original on any shape mismatch (the
// 2026-08-27 newline-collapse guard).
package main

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"
)

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(2)
	}
	var err error
	switch os.Args[1] {
	case "rows":
		err = cmdRows(os.Args[2:])
	case "prose":
		err = cmdProse(os.Args[2:])
	case "status-items":
		err = cmdStatusItems(os.Args[2:])
	case "emit-keys":
		err = cmdEmitKeys(os.Args[2:])
	case "check-rows":
		err = cmdCheckRows(os.Args[2:])
	case "repair":
		err = cmdRepair(os.Args[2:])
	case "unwrap":
		err = cmdUnwrap(os.Args[2:])
	case "self-test":
		err = selfTest()
	case "-h", "--help", "help":
		usage()
	default:
		fmt.Fprintf(os.Stderr, "unknown subcommand %q\n", os.Args[1])
		usage()
		os.Exit(2)
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func usage() {
	fmt.Fprint(os.Stderr, `annotate — docs-health annotation toolkit
usage: go run annotate.go <subcommand> ...
  rows [--dry-run] [--section <prefix>] <file> <row-id>:<kind>:<value>...
  prose [--dry-run] <file> <section-prefix> <row-id>:<kind>:<value>...
  status-items [--verify] <file> <specfile>
  emit-keys <file> <lineno> [<lineno>...]
  check-rows [--normalize] <file>...   (<!-- check-rows:ledger --> above a table exempts it)
  repair [--dry-run] <specfile>        (spec: path<TAB>lines<TAB>kind[<TAB>value])
  unwrap [--dry-run] <file>:<lines>...  (rebuild formatter-wrapped struck rows)
  self-test
kinds: h hashes | v evidence | p pass-date ('-' = today) | w wont-implement
       | n NOT-DO | r routed verdict (no strike)
`)
}

func fail(format string, args ...any) error {
	return fmt.Errorf(format, args...)
}

// ---------- shared helpers ----------

var splitKeepEnds = func(s string) []string {
	if s == "" {
		return nil
	}
	return strings.SplitAfter(s, "\n")
}

func readLines(path string) (string, []string, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return "", nil, err
	}
	return string(raw), splitKeepEnds(string(raw)), nil
}

func withNewline(new, orig string) string {
	if strings.HasSuffix(orig, "\n") {
		return new + "\n"
	}
	return new
}

// ---------- marker vocabulary (annotate-markers.py) ----------

var reStripDone = regexp.MustCompile(`^done\b[\s:—-]*`)
var reStripArrow = regexp.MustCompile(`^→\s*`)

func markerFor(kind, value string) (string, error) {
	switch kind {
	case "h":
		parts := strings.Split(value, ",")
		for i, h := range parts {
			parts[i] = "`" + h + "`"
		}
		return "done at " + strings.Join(parts, ", "), nil
	case "v":
		evidence := reStripDone.ReplaceAllString(strings.TrimSpace(value), "")
		if evidence == "" {
			return "done", nil
		}
		return "done — " + evidence, nil
	case "p":
		date := value
		if date == "-" {
			date = time.Now().UTC().Format("2006-01-02")
		}
		return "done (docs-health pass " + date + ")", nil
	case "w":
		return "**Won't implement — " + value + ".**", nil
	case "n":
		return "**NOT-DO — " + value + ".**", nil
	case "r":
		verdict := reStripArrow.ReplaceAllString(strings.TrimSpace(value), "")
		if verdict == "" {
			return "**→ resolved**", nil
		}
		return "**→ " + verdict + "**", nil
	default:
		return "", fail("bad kind %q (use h/v/p/w/n/r)", kind)
	}
}

// ---------- annotate-rows ----------

var (
	reDoubledSpanRows  = regexp.MustCompile("``.+?``")
	reSingleSpan       = regexp.MustCompile("`[^`]*`")
	reTableRowShape    = regexp.MustCompile(`^(\|\s*)([A-Za-z]?[A-Za-z0-9.]*)(\s*\|)(.*)(\|)\s*$`)
	reRowID            = regexp.MustCompile(`^[A-Za-z]?[A-Za-z0-9.]*$`)
	reHeading          = regexp.MustCompile(`^(#{1,6})\s`)
	reOccurrenceSuffix = regexp.MustCompile(`#(\d+)$`)
	reProseItemHead    = regexp.MustCompile(`^(\s*)(?:\d+\.|\*\*\d+\.\*\*)\s`)
	reProseItemBody    = regexp.MustCompile(`^(\s*)((?:\*\*)?\d+\.(?:\*\*)?\s*)(.*)$`)
	reNumItem          = regexp.MustCompile(`^(\s*)(?:[-*]\s*)?([A-Za-z]{0,3}\d{1,3}[a-z]?|[A-Za-z]+#\d+|\d+)\.\s`)
	reTableRowKey      = regexp.MustCompile(`^\|\s*\*{0,2}([A-Za-z]{0,3}\d{1,3}[a-z]?)\*{0,2}\s*\|`)
	reCheckbox         = regexp.MustCompile(`^(\s*)- \[ \] (.*)$`)
	reTableSepCell     = regexp.MustCompile(`^:?-{2,}:?$`)
	reDoubledSpanCheck = regexp.MustCompile("``[^`]+``")
	reIndentRest       = regexp.MustCompile(`^(\s*)(.*)$`)
)

// outsideCodeSpansRows is the annotate-rows variant (“.+?“); check-rows
// uses the “[^`]+“ variant below — kept byte-faithful to both originals.
func outsideCodeSpansRows(line string) string {
	return reSingleSpan.ReplaceAllString(reDoubledSpanRows.ReplaceAllString(line, ""), "")
}

func outsideCodeSpansCheck(text string) string {
	return reSingleSpan.ReplaceAllString(reDoubledSpanCheck.ReplaceAllString(text, ""), "")
}

func alreadyAnnotated(line string) bool {
	bare := outsideCodeSpansRows(line)
	return strings.Contains(bare, "~~") || strings.Contains(bare, "**→")
}

func strikeRow(line, row, marker string) (string, error) {
	m := reTableRowShape.FindStringSubmatch(line)
	if m == nil || m[2] != row {
		return "", fail("row %s: line does not match table-row shape: %.80q", row, line)
	}
	cells := strings.Split(m[4], "|")
	for i, c := range cells {
		cells[i] = " ~~" + strings.TrimSpace(c) + "~~ "
	}
	cells[0] = strings.TrimRight(cells[0], " ") + " " + marker + " "
	return m[1] + "~~" + m[2] + "~~" + m[3] + strings.Join(cells, "|") + m[5], nil
}

func routeRow(line, row, marker string) (string, error) {
	m := reTableRowShape.FindStringSubmatch(line)
	if m == nil || m[2] != row {
		return "", fail("row %s: line does not match table-row shape: %.80q", row, line)
	}
	cells := strings.Split(m[4], "|")
	cells[0] = strings.TrimRight(cells[0], " ") + " " + marker + " "
	return m[1] + m[2] + m[3] + strings.Join(cells, "|") + m[5], nil
}

func headingLevel(line string) int {
	if m := reHeading.FindStringSubmatch(line); m != nil {
		return len(m[1])
	}
	return 0
}

// scopedLines returns the [start, end) index range for a section heading.
// Level-aware: the section ends at the next heading of the same or higher
// level (upstreamed 2026-09-14). An occurrence suffix ("### a)#2") picks
// among repeated headings.
func scopedLines(lines []string, section *string) (int, int, error) {
	auto := "## f)"
	var prefix string
	if section == nil {
		found := false
		for _, l := range lines {
			if strings.HasPrefix(l, auto) {
				found = true
				break
			}
		}
		if !found {
			return 0, len(lines), nil
		}
		prefix = auto
	} else {
		prefix = *section
	}

	occurrence := 1
	if m := reOccurrenceSuffix.FindStringSubmatchIndex(prefix); m != nil {
		occurrence, _ = strconv.Atoi(prefix[m[2]:m[3]])
		prefix = prefix[:m[0]]
	}

	var matches []int
	for i, l := range lines {
		if strings.HasPrefix(l, prefix) {
			matches = append(matches, i)
		}
	}
	if len(matches) < occurrence {
		return 0, 0, fail("section %q occurrence %d not found (found %d)", prefix, occurrence, len(matches))
	}
	start := matches[occurrence-1]
	level := headingLevel(lines[start])
	if level == 0 {
		return 0, 0, fail("section start %q is not a heading", lines[start])
	}
	for i := start + 1; i < len(lines); i++ {
		if lv := headingLevel(lines[i]); lv > 0 && lv <= level {
			return start, i, nil
		}
	}
	return start, len(lines), nil
}

type rowEdit struct {
	lineNo int
	new    string
}

func cmdRows(argv []string) error {
	dryRun := false
	var section *string
	var rest []string
	for i := 0; i < len(argv); i++ {
		switch argv[i] {
		case "--dry-run":
			dryRun = true
		case "--section":
			if i+1 >= len(argv) {
				return fail("--section needs a heading-prefix argument")
			}
			i++
			s := argv[i]
			section = &s
		default:
			rest = append(rest, argv[i])
		}
	}
	if len(rest) < 2 {
		usage()
		os.Exit(2)
	}
	targetPath := rest[0]
	original, lines, err := readLines(targetPath)
	if err != nil {
		return err
	}
	target := baseName(targetPath)
	start, end, err := scopedLines(lines, section)
	if err != nil {
		return err
	}
	edits := map[int]string{}
	var order []int
	for _, spec := range rest[1:] {
		parts := strings.SplitN(spec, ":", 3)
		if len(parts) != 3 {
			return fail("bad spec %q — expected <row-id>:<kind>:<value>; quote values containing spaces", spec)
		}
		row, kind, value := parts[0], parts[1], parts[2]
		if !reRowID.MatchString(row) {
			return fail("bad row id %q (digits, M1/B1-style, or dotted F1.1-style)", row)
		}
		marker, err := markerFor(kind, value)
		if err != nil {
			return err
		}
		rowPat := regexp.MustCompile(`^\|\s*` + regexp.QuoteMeta(row) + `\s*\|`)
		var hits []int
		for i := start; i < end; i++ {
			if rowPat.MatchString(lines[i]) {
				hits = append(hits, i)
			}
		}
		if len(hits) != 1 {
			where := ""
			if section != nil {
				where = fmt.Sprintf(" in section %q", *section)
			}
			return fail("row %s: expected 1 match%s, found %d", row, where, len(hits))
		}
		i := hits[0]
		if alreadyAnnotated(lines[i]) {
			return fail("row %s: already annotated", row)
		}
		transform := strikeRow
		if kind == "r" {
			transform = routeRow
		}
		new, err := transform(strings.TrimRight(lines[i], "\n"), row, marker)
		if err != nil {
			return err
		}
		new = withNewline(new, lines[i])
		if dryRun {
			fmt.Printf("DRY %s row %s:\n  - %s\n  + %s\n", target, row, strings.TrimRight(lines[i], "\n"), strings.TrimRight(new, "\n"))
		}
		if _, seen := edits[i]; !seen {
			order = append(order, i)
		}
		edits[i] = new
	}
	if dryRun {
		sort.Ints(order)
		fmt.Printf("%s: would annotate %d rows -> %v\n", target, len(edits), order)
		return nil
	}
	for i, new := range edits {
		lines[i] = new
	}
	if err := os.WriteFile(rest[0], []byte(strings.Join(lines, "")), 0o644); err != nil {
		return err
	}

	// Shape check: read back, same line count, every annotated row present.
	reread := splitKeepEnds(mustRead(rest[0]))
	origCount := len(splitKeepEnds(original))
	var problems []string
	if len(reread) != origCount {
		problems = append(problems, fmt.Sprintf("line count changed: %d -> %d", origCount, len(reread)))
	}
	for _, i := range order {
		if i >= len(reread) || !strings.Contains(reread[i], strings.TrimSpace(edits[i])) {
			problems = append(problems, fmt.Sprintf("line %d: annotated row missing or mangled after write", i+1))
		}
	}
	if len(problems) > 0 {
		if err := os.WriteFile(rest[0], []byte(original), 0o644); err != nil {
			problems = append(problems, "restore failed: "+err.Error())
		}
		return fail("SHAPE CHECK FAILED (original restored):\n  %s", strings.Join(problems, "\n  "))
	}
	sort.Ints(order)
	fmt.Printf("%s: annotated %d rows -> %v (shape verified)\n", target, len(edits), order)
	return nil
}

func mustRead(path string) string {
	raw, err := os.ReadFile(path)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	return string(raw)
}

// ---------- annotate-prose ----------

func cmdProse(argv []string) error {
	dryRun := false
	var rest []string
	for _, a := range argv {
		if a == "--dry-run" {
			dryRun = true
			continue
		}
		rest = append(rest, a)
	}
	if len(rest) < 3 {
		usage()
		os.Exit(2)
	}
	return proseRun(rest[0], rest[1], rest[2:], dryRun, os.Stdout)
}

func proseRun(targetPath, prefix string, specs []string, dryRun bool, out io.Writer) error {
	_, lines, err := readLines(targetPath)
	if err != nil {
		return err
	}
	targetName := baseName(targetPath)
	start, end := 0, len(lines)
	if prefix != "" {
		found := -1
		for i, l := range lines {
			if strings.HasPrefix(l, prefix) {
				found = i
				break
			}
		}
		if found < 0 {
			return fail("section %q not found", prefix)
		}
		start = found
		end = len(lines)
		for i := found + 1; i < len(lines); i++ {
			if strings.HasPrefix(lines[i], "## ") {
				end = i
				break
			}
		}
	}
	var done []int
	for _, spec := range specs {
		parts := strings.SplitN(spec, ":", 3)
		if len(parts) != 3 {
			return fail("bad spec %q — expected <number>:<kind>:<value>; quote values containing spaces", spec)
		}
		num, err := strconv.Atoi(parts[0])
		if err != nil {
			return fail("bad item number %q in spec %q", parts[0], spec)
		}
		kind, value := parts[1], parts[2]
		marker, err := markerFor(kind, value)
		if err != nil {
			return err
		}
		numPat := regexp.MustCompile(`^\s*(?:\*\*)?` + strconv.Itoa(num) + `\.(?:\*\*)?\s`)
		var hits []int
		for i := start; i < end; i++ {
			if reProseItemHead.MatchString(lines[i]) && numPat.MatchString(lines[i]) {
				hits = append(hits, i)
			}
		}
		if len(hits) != 1 {
			return fail("item %d: expected 1 match in section, found %d", num, len(hits))
		}
		i := hits[0]
		outsideCode := reSingleSpan.ReplaceAllString(lines[i], "")
		if strings.Contains(outsideCode, "~~") || strings.Contains(outsideCode, "**→") {
			return fail("item %d: already annotated", num)
		}
		spanEnd := i + 1
		for spanEnd < end {
			line := lines[spanEnd]
			if reProseItemHead.MatchString(line) || strings.TrimSpace(line) == "" {
				break
			}
			spanEnd++
		}
		raw := strings.TrimRight(lines[i], "\n")
		m := reProseItemBody.FindStringSubmatch(raw)
		if m == nil {
			return fail("item %d: line does not match numbered-item shape: %.80q", num, raw)
		}
		var new string
		if kind == "r" {
			new = m[1] + m[2] + m[3] + " " + marker
		} else {
			new = m[1] + m[2] + "~~" + m[3] + "~~ " + marker
		}
		if dryRun {
			fmt.Fprintf(out, "DRY %s item %d (lines %d-%d):\n  - %s\n  + %s\n", targetName, num, i+1, spanEnd, raw, new)
		} else {
			lines[i] = withNewline(new, lines[i])
		}
		for j := i + 1; j < spanEnd; j++ {
			cont := strings.TrimRight(lines[j], "\n")
			if strings.Contains(cont, "~~") {
				return fail("item %d: continuation line %d already annotated", num, j+1)
			}
			if kind == "r" {
				continue
			}
			cm := reIndentRest.FindStringSubmatch(cont)
			struck := cm[1] + "~~" + cm[2] + "~~"
			if dryRun {
				fmt.Fprintf(out, "  - %s\n  + %s\n", cont, struck)
			} else {
				lines[j] = withNewline(struck, lines[j])
			}
		}
		done = append(done, num)
	}
	if !dryRun {
		if err := os.WriteFile(targetPath, []byte(strings.Join(lines, "")), 0o644); err != nil {
			return err
		}
	}
	verb := "annotated"
	if dryRun {
		verb = "would annotate"
	}
	sort.Ints(done)
	fmt.Fprintf(out, "%s: %s %d items -> %v\n", targetName, verb, len(done), done)
	return nil
}

func baseName(path string) string {
	if i := strings.LastIndexByte(path, '/'); i >= 0 {
		return path[i+1:]
	}
	return path
}

// ---------- annotate-status-items ----------

var bannedVerdicts = map[string]bool{
	"open": true, "todo": true, "pending": true, "later": true, "tbd": true,
}

type specSet struct {
	verdicts map[string]string
	order    []string
	lines    map[string]int
}

func loadSpecs(specPath string) (*specSet, error) {
	specs := &specSet{verdicts: map[string]string{}, lines: map[string]int{}}
	raw, err := os.ReadFile(specPath)
	if err != nil {
		return nil, err
	}
	for lineno, line := range strings.Split(strings.TrimRight(string(raw), "\n"), "\n") {
		trimmed := strings.TrimSpace(line)
		if trimmed == "" || strings.HasPrefix(line, "#") {
			continue
		}
		parts := strings.SplitN(line, "\t", 2)
		key := strings.TrimSpace(parts[0])
		verdict := ""
		if len(parts) == 2 {
			verdict = strings.TrimSpace(parts[1])
		}
		if prev, dup := specs.lines[key]; dup {
			return nil, fail("%s:%d: duplicate spec key %q (first defined at line %d); a repeated key silently overwrites in dict-based specs — disambiguate with `@substring` or merge the verdicts",
				baseName(specPath), lineno+1, key, prev)
		}
		if bannedVerdicts[strings.ToLower(strings.Trim(verdict, " ."))] {
			return nil, fail("%s: spec %q has verdict %q; open items stay BARE (absence is the open signal) — omit the key instead",
				baseName(specPath), key, verdict)
		}
		specs.verdicts[key] = verdict
		specs.order = append(specs.order, key)
		specs.lines[key] = lineno + 1
	}
	if len(specs.verdicts) == 0 {
		return nil, fail("%s: specfile has no key lines", baseName(specPath))
	}
	return specs, nil
}

// resolve maps every spec key to its line index (first-unstruck-match-wins)
// or reports the missing keys.
func resolve(lines []string, specs *specSet) (map[string]int, []string) {
	hits := map[string]int{}
	for i, rawLine := range lines {
		if strings.Contains(rawLine, "~~") {
			continue
		}
		line := strings.TrimSuffix(rawLine, "\n")
		matched := false
		tok := ""
		if m := reNumItem.FindStringSubmatch(line); m != nil {
			tok = m[2]
		} else if m := reTableRowKey.FindStringSubmatch(line); m != nil {
			tok = m[1]
		}
		if tok != "" && !strings.Contains(tok, "@") {
			for _, key := range specs.order {
				if _, ok := hits[key]; ok {
					continue
				}
				if strings.Contains(key, "@") {
					tokReq, substr, _ := strings.Cut(key, "@")
					if tok == tokReq && strings.Contains(line, substr) {
						hits[key] = i
						matched = true
						break
					}
				} else if tok == key {
					hits[key] = i
					matched = true
					break
				}
			}
		}
		if matched {
			continue
		}
		if m := reCheckbox.FindStringSubmatch(line); m != nil {
			for _, key := range specs.order {
				if _, ok := hits[key]; ok {
					continue
				}
				if strings.Contains(m[2], key) {
					hits[key] = i
					matched = true
					break
				}
			}
		}
		if matched {
			continue
		}
		for _, key := range specs.order {
			if _, ok := hits[key]; ok {
				continue
			}
			if rest, isAny := strings.CutPrefix(key, "any:"); isAny && strings.Contains(line, rest) {
				hits[key] = i
				break
			}
		}
	}
	var missing []string
	for _, key := range specs.order {
		if _, ok := hits[key]; !ok {
			missing = append(missing, key)
		}
	}
	return hits, missing
}

func cmdStatusItems(argv []string) error {
	verify := false
	if len(argv) > 0 && argv[0] == "--verify" {
		verify = true
		argv = argv[1:]
	}
	if len(argv) != 2 {
		usage()
		os.Exit(2)
	}
	path := argv[0]
	specs, err := loadSpecs(argv[1])
	if err != nil {
		return err
	}
	_, lines, err := readLines(path)
	if err != nil {
		return err
	}
	hits, missing := resolve(lines, specs)
	if len(missing) > 0 {
		return fail("%s: unmatched specs: %v", baseName(path), missing)
	}
	if verify {
		type kv struct {
			key string
			idx int
		}
		var sorted []kv
		for k, i := range hits {
			sorted = append(sorted, kv{k, i})
		}
		sort.Slice(sorted, func(a, b int) bool { return sorted[a].idx < sorted[b].idx })
		for _, e := range sorted {
			fmt.Printf("%d: %s\n", e.idx+1, strings.TrimRight(lines[e.idx], "\n"))
		}
		fmt.Printf("VERIFY OK %s: %d keys resolved (nothing written)\n", baseName(path), len(hits))
		return nil
	}
	for key, idx := range hits {
		stripped := strings.TrimRight(lines[idx], "\n")
		verdict := specs.verdicts[key]
		new := "~~" + stripped + "~~ " + verdict
		lines[idx] = withNewline(strings.TrimRight(new, " \t"), lines[idx])
	}
	if err := os.WriteFile(path, []byte(strings.Join(lines, "")), 0o644); err != nil {
		return err
	}
	fmt.Printf("OK %s: annotated %d items\n", baseName(path), len(hits))
	return nil
}

func cmdEmitKeys(argv []string) error {
	if len(argv) < 2 {
		return fail("usage: --emit-keys <file> <lineno> [<lineno> ...]")
	}
	path := argv[0]
	_, lines, err := readLines(path)
	if err != nil {
		return err
	}
	for _, arg := range argv[1:] {
		no, err := strconv.Atoi(arg)
		if err != nil {
			return fail("--emit-keys: line number %q is not an integer", arg)
		}
		if no < 1 || no > len(lines) {
			return fail("--emit-keys: line %d out of range (file has %d lines)", no, len(lines))
		}
		line := strings.TrimSuffix(lines[no-1], "\n")

		key, ok, kerr := emitKeyFor(line)
		if kerr != nil {
			return fail("--emit-keys: line %d: %v", no, kerr)
		}

		if !ok {
			fmt.Fprintf(os.Stderr, "--emit-keys: line %d is not a numbered row, table row, or checkbox; use an `any:` key manually if warranted\n", no)

			continue
		}

		fmt.Println(key)
		fmt.Fprintf(os.Stderr, "%d: %.100s\n", no, strings.TrimSpace(line))
	}

	return nil
}

// emitKeyFor builds one paste-ready key from a line: "<tok>@<substr>" (or a
// bare substr). ok=false when the line is not a numbered row, table row, or
// checkbox. Extracted so the self-test can pin the 2026-10-15 07-21 lesson
// (spec line numbers must come from emit-keys, never from a hand-typed
// view): every emitted key must match back into the EXACT line it was
// emitted from.
func emitKeyFor(line string) (string, bool, error) {
	var tok, rest string

	switch {
	case reNumItem.MatchString(line):
		m := reNumItem.FindStringSubmatchIndex(line)
		tok = line[m[4]:m[5]]
		rest = strings.TrimSpace(line[m[1]:])
	case reTableRowKey.MatchString(line):
		m := reTableRowKey.FindStringSubmatchIndex(line)
		tok = line[m[2]:m[3]]
		rest = strings.TrimSpace(line[m[1]:])
	case reCheckbox.MatchString(line):
		m := reCheckbox.FindStringSubmatch(line)
		rest = strings.TrimSpace(m[2])
	default:
		return "", false, nil
	}

	rest = strings.TrimSpace(strings.SplitN(rest, "\t", 2)[0])

	runes := []rune(rest)
	if len(runes) > 32 {
		runes = runes[:32]
	}

	substr := strings.TrimSpace(string(runes))
	if substr == "" {
		return "", true, fail("line has no text after its marker")
	}

	if tok == "" {
		return substr, true, nil
	}

	return tok + "@" + substr, true, nil
}

// ---------- check-rows ----------

// ledgerMarker exempts exactly the NEXT table from the completeness gate.
// A ledger table intentionally mixes struck-resolved and open rows
// (per-row inline verdicts are the point of a ledger — the 2026-10-14
// go-credentials-store decision). The marker line sits above the table;
// blank lines in between are allowed; any other non-blank non-table line
// cancels it.
const ledgerMarker = "<!-- check-rows:ledger -->"

// splitCells splits a table row into cells on UNESCAPED pipes: `\|` inside
// a cell (escaped-pipe code spans showing table syntax — the 2026-10-13
// 20-17 report carried one) must not become a cell boundary. The sentinel
// is restored after the split so cell text stays byte-faithful.
func splitCells(line string) []string {
	const sentinel = "\x00"

	masked := strings.ReplaceAll(strings.TrimSpace(line), "\\|", sentinel)
	parts := strings.Split(strings.Trim(masked, "|"), "|")

	for i, p := range parts {
		parts[i] = strings.TrimSpace(strings.ReplaceAll(p, sentinel, "\\|"))
	}

	return parts
}

func isSeparator(line string) bool {
	for _, c := range splitCells(line) {
		if !reTableSepCell.MatchString(c) {
			return false
		}
	}

	return true
}

// reRoutedArrow matches the routed-verdict convention: the tool's own
// r-marker renders `**→ verdict**`, and hand-routed rows carry a plain
// `→ routed` arrow (2026-10-13 20-17 §f18). A routed row is INTENTIONALLY
// unstruck — a completeness gate must count it as resolved.
var reRoutedArrow = regexp.MustCompile(`\*\*→[^*]+\*\*`)

func isRouted(line string) bool {
	stripped := outsideCodeSpansCheck(strings.TrimSpace(line))

	return strings.Contains(stripped, "→ routed") || reRoutedArrow.MatchString(stripped)
}

func classifyRow(line string) string {
	cells := splitCells(line)
	states := make([]bool, len(cells))
	for i, c := range cells {
		states[i] = strings.Contains(outsideCodeSpansCheck(c), "~~")
	}
	all := true
	any := false
	for _, s := range states {
		all = all && s
		any = any || s
	}
	switch {
	case all:
		return "STRUCK"
	case isRouted(line):
		return "ROUTED"
	case !any:
		return "CLEAN"
	default:
		return "PARTIAL"
	}
}

func checkFile(path string) (int, error) {
	_, lines, err := readLines(path)
	if err != nil {
		return 1, err
	}
	name := baseName(path)
	var problems []string
	var notes []string
	pendingLedger := false
	blockLedger := false
	var block []struct {
		no  int
		str string
	}
	flush := func() {
		if len(block) == 0 {
			return
		}
		wasLedger := blockLedger
		blockLedger = false
		var data []struct {
			no  int
			str string
		}
		for _, e := range block {
			if !isSeparator(e.str) {
				data = append(data, e)
			}
		}
		block = nil
		if len(data) < 2 {
			return
		}
		headerNo := data[0].no
		if wasLedger {
			notes = append(notes, fmt.Sprintf(
				"%s: table at line %d LEDGER-EXEMPT (check-rows:ledger marker)",
				name, headerNo))
			return
		}
		type cls struct {
			no    int
			state string
		}
		var classified []cls
		struckRows := 0
		routedRows := 0
		for _, e := range data[1:] {
			state := classifyRow(e.str)
			classified = append(classified, cls{e.no, state})
			if state == "STRUCK" {
				struckRows++
			}
			if state == "ROUTED" {
				routedRows++
			}
		}
		var partial []struct {
			no  int
			str string
		}
		for i, e := range data[1:] {
			if classified[i].state == "PARTIAL" {
				partial = append(partial, e)
			}
		}
		mixedTable := struckRows > 0 && struckRows+routedRows < len(classified)
		if len(partial) > 0 || mixedTable {
			problems = append(problems, fmt.Sprintf("%s: table at line %d INCOMPLETE (%d/%d rows struck)",
				name, headerNo, struckRows, len(classified)))
			for _, e := range partial {
				snippet := e.str
				if len(snippet) > 100 {
					snippet = snippet[:100]
				}
				problems = append(problems, fmt.Sprintf("  line %d: PARTIAL row: %s", e.no, snippet))
			}
			if mixedTable && len(partial) == 0 {
				for _, c := range classified {
					if c.state != "STRUCK" && c.state != "ROUTED" {
						problems = append(problems, fmt.Sprintf("  line %d: %s row in a struck table", c.no, c.state))
					}
				}
			}
		}
	}
	for i, line := range lines {
		if strings.HasPrefix(strings.TrimLeft(line, " \t"), "|") {
			if len(block) == 0 && pendingLedger {
				blockLedger = true
				pendingLedger = false
			}
			block = append(block, struct {
				no  int
				str string
			}{i + 1, strings.TrimRight(line, "\n")})
			continue
		}
		flush()
		switch t := strings.TrimSpace(line); {
		case t == ledgerMarker:
			pendingLedger = true
		case t != "":
			pendingLedger = false
		}
	}
	flush()
	for _, n := range notes {
		fmt.Println(n)
	}
	for _, p := range problems {
		fmt.Println(p)
	}
	if len(problems) > 0 {
		return 1, nil
	}
	return 0, nil
}

func cmdCheckRows(argv []string) error {
	normalize := false

	var files []string

	for _, a := range argv {
		if a == "--normalize" {
			normalize = true

			continue
		}

		files = append(files, a)
	}

	if len(files) < 1 {
		usage()
		os.Exit(2)
	}

	failures := 0
	incomplete := 0
	for _, arg := range files {
		if normalize {
			if err := normalizeFile(arg); err != nil {
				return err
			}
		}

		f, err := checkFile(arg)
		if err != nil {
			return err
		}

		failures |= f
		if f != 0 {
			incomplete++
		}
	}

	if failures != 0 {
		// The documented contract is "exit 1 on PARTIAL table rows" — the
		// problems were already printed by checkFile; carry the verdict to
		// the exit code so gate callers can rely on it (silent-exit-0 was
		// the 2026-10-13 sweep-wiring discovery: consumers archived files
		// the tool had just flagged).
		return fmt.Errorf("check-rows: %d/%d file(s) incomplete", incomplete, len(files))
	}

	fmt.Printf("check-rows: %d file(s) complete\n", len(files))

	return nil
}

// normalizeFile repairs the formatter-damage class that made check-rows and
// `dprint`-style formatters fight (2026-10-15 go-aichat discovery): the
// formatter re-aligns a struck table and APPENDS empty cells to some rows,
// so those rows carry more cells than the table's separator and classify
// PARTIAL (an empty trailing cell has no strike). The repair is
// conservative — trailing empty cells beyond the separator's column count
// are dropped; nothing else is touched. Atomic; no-op when clean.
func normalizeFile(path string) error {
	_, lines, err := readLines(path)
	if err != nil {
		return err
	}

	type block struct {
		start int
		rows  []int
	}

	var (
		blocks  []block
		inBlock bool
		changed int
	)

	for i, line := range lines {
		bare := strings.TrimRight(line, "\n")
		if strings.HasPrefix(strings.TrimLeft(bare, " \t"), "|") {
			if !inBlock {
				blocks = append(blocks, block{start: i + 1})
				inBlock = true
			}

			blocks[len(blocks)-1].rows = append(blocks[len(blocks)-1].rows, i)

			continue
		}

		inBlock = false
	}

	for _, b := range blocks {
		cols := -1

		for _, ri := range b.rows {
			if isSeparator(strings.TrimRight(lines[ri], "\n")) {
				cols = len(splitCells(strings.TrimRight(lines[ri], "\n")))

				break
			}
		}

		if cols < 1 {
			continue
		}

		for _, ri := range b.rows {
			bare := strings.TrimRight(lines[ri], "\n")
			if isSeparator(bare) {
				continue
			}

			cs := splitCells(bare)
			if len(cs) <= cols {
				continue
			}

			excess := cs[cols:]
			extraEmpty := true
			for _, c := range excess {
				if strings.TrimSpace(c) != "" {
					extraEmpty = false

					break
				}
			}

			if !extraEmpty {
				continue
			}

			trimmed := cs[:cols]
			out := "| " + strings.Join(trimmed, " | ") + " |"
			lines[ri] = withNewline(out, lines[ri])
			changed++

			fmt.Printf("normalize: %s:%d dropped %d trailing empty cell(s)\n", path, ri+1, len(excess))
		}
	}

	if changed == 0 {
		return nil
	}

	tmp := path + ".normalize-tmp"
	if err := os.WriteFile(tmp, []byte(strings.Join(lines, "")), 0o644); err != nil {
		return err
	}

	if err := os.Rename(tmp, path); err != nil {
		return err
	}

	fmt.Printf("normalize: %s: %d row(s) repaired\n", path, changed)

	return nil
}

// ---------- repair (spec-driven batch annotate) ----------

// repairSpec is one line of a repair spec file:
//
//	<path><TAB><linespec><TAB><kind>[<TAB><value>]
//
// linespec is "18" or "18-27". Kinds share the marker vocabulary (h/v/p/w/n/r
// via markerFor), so the batch pass cannot drift from the single-line
// commands. Ranges annotate every action line inside them; a later spec for
// the same line overrides earlier ones (specific lines override ranges).
// Table rows get per-cell strikes; a malformed "| ~~ |" placeholder first
// cell (the 2026-10-15 go-aichat corpus had them) is dropped, not struck.
// Prose action lines are wrapped whole: ~~line~~ verdict.
//
// The command exists because per-line `rows`/`prose` invocations don't scale
// to a 26-file corpus pass, and hand-rolled session scripts (the
// 2026-10-15 /tmp/docrepair throwaway) don't survive reboot or review.
func cmdRepair(argv []string) error {
	return repairRun(argv, os.Stdout)
}

// repairRun applies a repair spec file. Spec line: path<TAB>lines<TAB>kind[<TAB>value];
// --dry-run inside argv reports without writing. out receives the per-file
// report (self-test passes a buffer).
func repairRun(argv []string, out io.Writer) error {
	dry := false

	var files []string

	for _, a := range argv {
		if a == "--dry-run" {
			dry = true

			continue
		}

		files = append(files, a)
	}

	if len(files) != 1 {
		return fail("usage: repair [--dry-run] <specfile>")
	}

	raw, err := os.ReadFile(files[0])
	if err != nil {
		return err
	}

	byFile := map[string][]repairSpec{}

	for _, ln := range strings.Split(strings.TrimSpace(string(raw)), "\n") {
		if strings.TrimSpace(ln) == "" || strings.HasPrefix(ln, "#") {
			continue
		}

		parts := strings.Split(ln, "\t")
		if len(parts) < 3 {
			return fail("repair: bad spec line %q (want path\\tlines\\tkind[\\tvalue])", ln)
		}

		spec := repairSpec{path: parts[0], kind: parts[2]}
		if len(parts) > 3 {
			spec.value = parts[3]
		}

		if strings.Contains(parts[1], "-") {
			if _, err := fmt.Sscanf(parts[1], "%d-%d", &spec.lo, &spec.hi); err != nil {
				return fail("repair: bad linespec %q", parts[1])
			}
		} else {
			if _, err := fmt.Sscanf(parts[1], "%d", &spec.lo); err != nil {
				return fail("repair: bad linespec %q", parts[1])
			}

			spec.hi = spec.lo
		}

		if spec.lo < 1 || spec.hi < spec.lo {
			return fail("repair: linespec %q out of range", parts[1])
		}

		byFile[spec.path] = append(byFile[spec.path], spec)
	}

	names := make([]string, 0, len(byFile))
	for p := range byFile {
		names = append(names, p)
	}

	sort.Strings(names)

	total := 0

	for _, p := range names {
		n, err := repairFile(p, byFile[p], dry)
		if err != nil {
			return err
		}

		total += n

		verb := "annotated"
		if dry {
			verb = "would annotate"
		}

		fmt.Fprintf(out, "repair: %s: %s %d action line(s)\n", p, verb, n)
	}

	return nil
}

type repairSpec struct {
	path   string
	lo, hi int
	kind   string
	value  string
}

// repairFile applies one file's specs. Returns the number of lines changed
// (or that would change). Atomic per file: write to a temp sibling, rename.
func repairFile(path string, specs []repairSpec, dry bool) (int, error) {
	abs := path

	if !filepath.IsAbs(abs) {
		abs = filepath.Join(cwdOrDot(), path)
	}

	_, lines, err := readLines(abs)
	if err != nil {
		return 0, err
	}

	apply := map[int]repairSpec{}
	for _, s := range specs {
		for i := s.lo; i <= s.hi; i++ {
			apply[i] = s
		}
	}

	changed := 0

	for i, l := range lines {
		s, ok := apply[i+1]
		if !ok || !repairActionLine(l) || repairAlreadyDone(l) {
			continue
		}

		verdict, err := markerFor(s.kind, s.value)
		if err != nil {
			return 0, fail("repair %s line %d: %v", path, i+1, err)
		}

		bare := strings.TrimRight(l, "\n")
		strike := s.kind != "r"

		var out string
		if strings.HasPrefix(strings.TrimSpace(bare), "|") {
			out = strikeRepairRow(bare, verdict, strike)
		} else {
			out = repairProse(bare, verdict, strike)
		}

		out = withNewline(out, l)
		if out != l {
			lines[i] = out
			changed++
		}
	}

	if dry || changed == 0 {
		return changed, nil
	}

	out := strings.Join(lines, "")

	tmp := abs + ".repair-tmp"
	if err := os.WriteFile(tmp, []byte(out), 0o644); err != nil {
		return 0, err
	}

	written, writtenLines, err := readLines(tmp)
	if err != nil {
		return 0, err
	}

	// Like-for-like counting: both sides are splitKeepEnds (the raw-content
	// Split(TrimSuffix(...)) variant counts one fewer on files ending in a
	// newline — the 2026-10-15 self-test finding).
	if len(writtenLines) != len(lines) {
		return 0, fail("repair %s: read-back line count mismatch (newline-collapse guard): wrote %d bytes, read back %d", path, len(out), len(written))
	}

	if err := os.Rename(tmp, abs); err != nil {
		return 0, err
	}

	return changed, nil
}

func cwdOrDot() string {
	cwd, err := os.Getwd()
	if err != nil {
		return "."
	}

	return cwd
}

// strikeRepairRow per-cell strikes a table row and appends the verdict in
// the first cell. A malformed placeholder first cell ("~~" alone — the
// pre-repair corpus shape) is dropped: striking it would produce the
// "| ~~~~ |" noise check-rows then flags as PARTIAL. With strike=false
// (the routed kind) the verdict is appended and no cell is struck —
// routed rows are INTENTIONALLY unstruck (the house ROUTED grammar).
func strikeRepairRow(line, verdict string, strike bool) string {
	cs := splitCells(line)
	if strings.TrimSpace(cs[0]) == "~~" {
		cs = cs[1:]
	}

	if !strike {
		cs[0] = strings.TrimSpace(cs[0]) + " " + verdict

		return "| " + strings.Join(cs, " | ") + " |"
	}

	for i := range cs {
		cs[i] = "~~" + strings.TrimSpace(cs[i]) + "~~"
	}

	cs[0] = cs[0] + " " + verdict

	return "| " + strings.Join(cs, " | ") + " |"
}

// repairProse wraps a whole prose line: ~~line~~ verdict. With strike=false
// (routed) the verdict is appended, nothing is struck.
func repairProse(line, verdict string, strike bool) string {
	if !strike {
		return strings.TrimRight(line, " ") + " " + verdict
	}

	return "~~" + strings.TrimRight(line, " ") + "~~ " + verdict
}

// repairActionLine decides which lines a repair spec may touch: table data
// rows (never the header or separator) and numbered/bulleted list items.
// Header-shape first cells (#, ID, B#, Item, Task) are never action lines.
func repairActionLine(l string) bool {
	t := strings.TrimSpace(l)
	if t == "" {
		return false
	}

	if strings.HasPrefix(t, "|") {
		if isSeparator(t) {
			return false
		}

		first := strings.Trim(strings.TrimPrefix(strings.TrimSpace(splitCells(t)[0]), "~~"), "~~")
		first = strings.TrimSpace(first)

		switch first {
		case "#", "ID", "B#", "T#", "Item", "Task", "ID  ", "Task  ":
			return false
		}

		return true
	}

	return reNumItem.MatchString(l)
}

// repairAlreadyDone skips lines the pass must not re-annotate. It defers
// to the house alreadyAnnotated guard (~~ or **→ outside code spans) —
// EXCEPT for the malformed "| ~~ |" placeholder row, whose only tildes are
// the placeholder itself and which the pass exists to strike (the
// 2026-10-15 corpus shape). Without the exception the pass would skip its
// own target; without the deferral a second pass double-strikes (the
// self-test caught exactly that).
func repairAlreadyDone(l string) bool {
	t := strings.TrimSpace(l)
	if strings.HasPrefix(t, "|") && strings.TrimSpace(splitCells(t)[0]) == "~~" {
		return false
	}

	return alreadyAnnotated(l)
}

// ---------- unwrap (formatter-damage repair) ----------

// cmdUnwrap repairs struck table rows that a formatter re-wrapped: the
// verdict text spilled from the first cell into following cells, so
// check-rows classifies the row PARTIAL (unstruck fragment cells). For
// each flagged line, rebuild: cell 1 carries "~~N~~ <verdict...>";
// subsequent cells that do NOT start with ~~ are wrap fragments of the
// verdict; the first ~~-starting cell begins the struck content cells
// (kept as-is); empty cells are dropped.
//
// Args are path:lines pairs, lines comma-separated: report.md:14,15 other.md:3
func cmdUnwrap(argv []string) error {
	return unwrapRun(argv, os.Stdout)
}

// unwrapRun repairs formatter-wrapped struck rows; out receives the
// per-file report (self-test passes a buffer).
func unwrapRun(argv []string, out io.Writer) error {
	dry := false

	var targets []string

	for _, a := range argv {
		if a == "--dry-run" {
			dry = true

			continue
		}

		targets = append(targets, a)
	}

	if len(targets) == 0 {
		return fail("usage: unwrap [--dry-run] <file>:<lines>... (lines comma-separated)")
	}

	for _, arg := range targets {
		i := strings.LastIndex(arg, ":")

		path := arg
		lineList := ""

		if i >= 0 {
			path, lineList = arg[:i], arg[i+1:]
		}

		var lns []int

		for _, n := range strings.Split(lineList, ",") {
			v, err := strconv.Atoi(strings.TrimSpace(n))
			if err != nil {
				return fail("unwrap: bad line %q in %q", n, arg)
			}

			lns = append(lns, v)
		}

		n, err := unwrapFile(path, lns, dry)
		if err != nil {
			return err
		}

		verb := "rebuilt"
		if dry {
			verb = "would rebuild"
		}

		fmt.Fprintf(out, "unwrap: %s: %s %d row(s)\n", path, verb, n)
	}

	return nil
}

func unwrapFile(path string, lns []int, dry bool) (int, error) {
	_, lines, err := readLines(path)
	if err != nil {
		return 0, err
	}

	rebuilt := 0

	for _, ln := range lns {
		if ln < 1 || ln > len(lines) {
			return 0, fail("unwrap %s: line %d out of range (file has %d lines)", path, ln, len(lines))
		}

		out, ok := unwrapRow(strings.TrimRight(lines[ln-1], "\n"))
		if !ok {
			fmt.Printf("unwrap: %s:%d: not a wrapped struck row, skip\n", path, ln)

			continue
		}

		lines[ln-1] = withNewline(out, lines[ln-1])
		rebuilt++
	}

	if dry || rebuilt == 0 {
		return rebuilt, nil
	}

	tmp := path + ".unwrap-tmp"
	if err := os.WriteFile(tmp, []byte(strings.Join(lines, "")), 0o644); err != nil {
		return 0, err
	}

	if err := os.Rename(tmp, path); err != nil {
		return 0, err
	}

	return rebuilt, nil
}

// unwrapRow rebuilds one wrapped struck row; ok=false when the line is not
// a table row or cell 1 carries no strike to rebuild around.
func unwrapRow(line string) (string, bool) {
	t := strings.TrimSpace(line)
	if !strings.HasPrefix(t, "|") {
		return "", false
	}

	cs := splitCells(t)
	c1 := cs[0]

	end := strings.Index(c1[2:], "~~")
	if !strings.HasPrefix(c1, "~~") || end < 0 {
		return "", false
	}

	rowid := c1[:end+4]

	verdict := strings.TrimSpace(c1[end+4:])

	var content []string

	for _, c := range cs[1:] {
		switch {
		case c == "" || strings.Trim(c, " ") == "" || c == "~~~~":
			continue
		case strings.HasPrefix(c, "~~"):
			content = append(content, c)
		default:
			verdict = strings.TrimSpace(verdict + " " + c)
		}
	}

	nb := "| " + rowid + " " + verdict + " "
	for _, c := range content {
		nb += "| " + c + " "
	}

	return nb + "|", true
}

// ---------- self-test (ports of annotate-rows_test.py + annotate-prose_test.py) ----------

func selfTest() error {
	failures := []string{}
	check := func(name string, got, want any) {
		if got != want {
			failures = append(failures, fmt.Sprintf("%s: got %q, want %q", name, got, want))
		}
	}
	mustMarker := func(kind, value string) string {
		m, err := markerFor(kind, value)
		if err != nil {
			failures = append(failures, fmt.Sprintf("marker(%s,%q): unexpected error %v", kind, value, err))
		}
		return m
	}

	// outside-code-span stripping (rows variant)
	check("code-span tildes stripped",
		outsideCodeSpansRows("| x | skip guard when `~~...~~` occurs |"),
		"| x | skip guard when  occurs |")
	check("plain text kept", outsideCodeSpansRows("a ~~b~~ c"), "a ~~b~~ c")
	check("doubled-backtick span stripped", outsideCodeSpansRows("x ``a`b`` y"), "x  y")

	// already_annotated: quoted marker syntax must not trip; real markers must
	check("code-span tildes are not annotation",
		alreadyAnnotated("| F12.1 | skip already-annotated guard when `~~` occurs in code spans | High |"), false)
	check("struck row trips", alreadyAnnotated("| M1 | ~~task~~ done at `abc` |"), true)
	check("clean row passes", alreadyAnnotated("| M1 | task | High |"), false)
	check("routed row trips", alreadyAnnotated("| M1 | task **→ open — owner lane** | High |"), true)
	check("prose arrow passes", alreadyAnnotated("| M19 | rewrite `x` → new `--flag` arg | High |"), false)

	// marker vocabulary
	check("v plain", mustMarker("v", "verified live 2026-08-29"), "done — verified live 2026-08-29")
	check("v strips leading done", mustMarker("v", "done — some evidence"), "done — some evidence")
	check("v strips 'done:'", mustMarker("v", "done: x"), "done — x")
	check("v strips 'done '", mustMarker("v", "done at the site"), "done — at the site")
	check("v empty", mustMarker("v", ""), "done")
	check("v bare", mustMarker("v", "done"), "done")
	check("v evidence", mustMarker("v", "live curl check"), "done — live curl check")
	check("h", mustMarker("h", "abc123"), "done at `abc123`")
	check("h single", mustMarker("h", "abc1234"), "done at `abc1234`")
	check("h multi", mustMarker("h", "a1,b2"), "done at `a1`, `b2`")
	check("p explicit date", mustMarker("p", "2026-09-24"), "done (docs-health pass 2026-09-24)")
	check("p UTC default", mustMarker("p", "-"), "done (docs-health pass "+time.Now().UTC().Format("2006-01-02")+")")
	check("w", mustMarker("w", "gated upstream"), "**Won't implement — gated upstream.**")
	check("w user decision", mustMarker("w", "user decision"), "**Won't implement — user decision.**")
	check("r open", mustMarker("r", "open — owner lane (TODO_LIST row)"), "**→ open — owner lane (TODO_LIST row)**")
	check("r done", mustMarker("r", "done — landed at 4cea337"), "**→ done — landed at 4cea337**")
	check("r strips leading arrow", mustMarker("r", "→ routed to ROADMAP"), "**→ routed to ROADMAP**")
	check("r empty", mustMarker("r", ""), "**→ resolved**")
	if _, err := markerFor("x", "y"); err == nil {
		failures = append(failures, "bad kind: no error raised")
	}

	// row transforms
	got, err := routeRow("| M02 | host check | Critical |", "M02", "**→ done — live**")
	check("route_row err", err, nil)
	check("route_row appends in task cell", got, "| M02 | host check **→ done — live** | Critical |")
	got, err = strikeRow("| 3 | tail | S |", "3", "done at `a1b2c3`")
	check("strike_row err", err, nil)
	check("strike_row still strikes", got, "| ~~3~~ | ~~tail~~ done at `a1b2c3` | ~~S~~ |")

	// prose annotation: end-to-end on a scratch file
	dir, err := os.MkdirTemp("", "annotate-selftest")
	if err != nil {
		return err
	}
	defer os.RemoveAll(dir)
	target := dir + "/sample.md"
	sample := "# Report\n\n## f) Next\n\n1. First item\n   continued line\n2. Second item\n\n3. After a blank line (own item)\n\n## g) Tail\n\n1. Different section, same number\n"
	if err := os.WriteFile(target, []byte(sample), 0o644); err != nil {
		return err
	}
	err = proseRun(target, "## f)", []string{
		"1:h:abc1234",
		"2:w:never wanted",
		"3:r:open — owner lane (TODO_LIST row)",
	}, false, io.Discard)
	check("prose run err", err, nil)
	outBytes, _ := os.ReadFile(target)
	out := string(outBytes)
	check("item 1 struck", strings.Contains(out, "~~First item~~ done at `abc1234`"), true)
	check("item 1 continuation struck", strings.Contains(out, "   ~~continued line~~"), true)
	check("item 2 struck", strings.Contains(out, "~~Second item~~ **Won't implement — never wanted.**"), true)
	check("blank line not struck", strings.Contains(out, "\n\n3. After a blank line"), true)
	check("routed item NOT struck",
		strings.Contains(out, "3. After a blank line (own item) **→ open — owner lane (TODO_LIST row)**"), true)
	check("section g untouched", strings.Contains(out, "1. Different section, same number"), true)

	// guards: re-running a struck item and a routed item must fail loudly
	err = proseRun(target, "## f)", []string{"1:v:again"}, false, io.Discard)
	if err == nil {
		failures = append(failures, "already-annotated guard: no error raised")
	}
	err = proseRun(target, "## f)", []string{"3:r:again"}, false, io.Discard)
	if err == nil {
		failures = append(failures, "routed already-annotated guard: no error raised")
	}

	// dry-run writes nothing
	dir2, _ := os.MkdirTemp("", "annotate-selftest-dry")
	defer os.RemoveAll(dir2)
	dry := dir2 + "/dry.md"
	_ = os.WriteFile(dry, []byte(sample), 0o644)
	var buf bytes.Buffer
	if err := proseRun(dry, "## f)", []string{"1:h:deadbee"}, true, &buf); err != nil {
		failures = append(failures, "dry-run: unexpected error "+err.Error())
	}
	dryOut, _ := os.ReadFile(dry)
	check("dry-run wrote nothing", string(dryOut), sample)
	check("dry-run reported", strings.Contains(buf.String(), "would annotate 1 items"), true)

	// check-rows conventions (2026-10-14 fixes, both found on the
	// go-credentials-store archived set): escaped pipes stay INSIDE one
	// cell, and a routed row counts as resolved in a struck table.
	check("escaped pipe keeps one cell",
		len(splitCells("| x | example: `\\| - \\| --- \\|` inline |")), 2)
	check("plain separator still detected", isSeparator("| --- | --- |"), true)
	check("routed row is ROUTED", classifyRow("| ~~2~~ | **→ routed** to TODO | `x.md` |"), "ROUTED")
	check("plain routed arrow is ROUTED", classifyRow("| 3 | item — → routed | `x.md` |"), "ROUTED")
	check("open row stays CLEAN", classifyRow("| 4 | still open | `x.md` |"), "CLEAN")
	check("partial row stays PARTIAL", classifyRow("| 5 | ~~half~~ rest open | `x.md` |"), "PARTIAL")

	// ----- check-rows ledger exemption (2026-10-15): a
	// <!-- check-rows:ledger --> line above a table exempts exactly that
	// table — blank lines between marker and table are allowed, and the
	// exemption never leaks to a following table. -----
	ledDir, mkErr := os.MkdirTemp("", "annotate-ledger")
	if mkErr != nil {
		return mkErr
	}
	defer os.RemoveAll(ledDir)

	ledFile := ledDir + "/ledger.md"
	ledSample := "# R\n\n" +
		"<!-- check-rows:ledger -->\n\n" +
		"| ID | Verdict |\n| --- | --- |\n" +
		"| ~~1~~ | ~~resolved~~ |\n| 2 | open ledger row |\n\n" +
		"| ID | Verdict |\n| --- | --- |\n" +
		"| ~~3~~ | ~~resolved~~ |\n| 4 | open in a plain table |\n"
	if err := os.WriteFile(ledFile, []byte(ledSample), 0o644); err != nil {
		return err
	}

	ledCode, ledErr := checkFile(ledFile)
	if ledErr != nil {
		return ledErr
	}
	check("ledger table exempt, following mixed table still flagged", ledCode, 1)

	ledOnly := ledDir + "/ledger-only.md"
	ledOnlySample := "<!-- check-rows:ledger -->\n\n" +
		"| ID | Verdict |\n| --- | --- |\n" +
		"| ~~1~~ | ~~resolved~~ |\n| 2 | open ledger row |\n"
	if err := os.WriteFile(ledOnly, []byte(ledOnlySample), 0o644); err != nil {
		return err
	}

	ledOnlyCode, ledOnlyErr := checkFile(ledOnly)
	if ledOnlyErr != nil {
		return ledOnlyErr
	}
	check("sole ledger-marked table passes", ledOnlyCode, 0)

	// ----- repair: spec-driven batch pass (2026-10-15 corpus class) -----
	repairDir, err := os.MkdirTemp("", "annotate-repair")
	if err != nil {
		return err
	}
	defer os.RemoveAll(repairDir)

	rTarget := repairDir + "/report.md"
	rSample := "# Report\n\n## f) Next\n\n| ID | Task | Prio |\n| --- | --- | --- |\n| F1 | ship the thing | High |\n| ~~ | malformed placeholder | Low |\n\n1. prose item one\n2. prose item two\n"
	if err := os.WriteFile(rTarget, []byte(rSample), 0o644); err != nil {
		return err
	}

	specFile := repairDir + "/specs.tsv"
	specContent := strings.Join([]string{
		"# path\tlines\tkind\tvalue",
		rTarget + "\t7-7\th\tabc1234",
		rTarget + "\t8-8\tn\tnever wanted",
		rTarget + "\t10-10\tr\towner lane",
		rTarget + "\t11-11\tv\tshipped",
	}, "\n")
	if err := os.WriteFile(specFile, []byte(specContent), 0o644); err != nil {
		return err
	}

	var rbuf bytes.Buffer
	if err := repairRun([]string{specFile, "--dry-run"}, &rbuf); err != nil {
		failures = append(failures, "repair dry-run: unexpected error "+err.Error())
	}

	rDry, _ := os.ReadFile(rTarget)
	check("repair dry-run wrote nothing", string(rDry), rSample)

	if err := repairRun([]string{specFile}, io.Discard); err != nil {
		failures = append(failures, "repair run: unexpected error "+err.Error())
	}

	rOut, _ := os.ReadFile(rTarget)
	rOutS := string(rOut)
	check("repair struck table row", strings.Contains(rOutS, "| ~~F1~~ done at `abc1234` | ~~ship the thing~~ | ~~High~~ |"), true)
	check("repair dropped placeholder cell", strings.Contains(rOutS, "| ~~malformed placeholder~~ **NOT-DO — never wanted.** | ~~Low~~ |"), true)
	check("repair routed prose unstruck", strings.Contains(rOutS, "1. prose item one **→ owner lane**"), true)
	check("repair struck prose", strings.Contains(rOutS, "~~2. prose item two~~ done — shipped"), true)

	rAgain, _ := os.ReadFile(rTarget)
	if err := repairRun([]string{specFile}, io.Discard); err != nil {
		failures = append(failures, "repair re-run: unexpected error "+err.Error())
	}

	rAfter, _ := os.ReadFile(rTarget)
	check("repair re-run is a no-op (already-done guard)", string(rAfter), string(rAgain))

	// ----- unwrap: formatter-wrapped struck rows -----
	uTarget := repairDir + "/wrapped.md"
	uSample := "| ~~M7~~ | done — evidence spilled | into this cell | ~~task~~ | ~~High~~ |\n"
	if err := os.WriteFile(uTarget, []byte(uSample), 0o644); err != nil {
		return err
	}

	if err := unwrapRun([]string{uTarget + ":1"}, io.Discard); err != nil {
		failures = append(failures, "unwrap run: unexpected error "+err.Error())
	}

	uOut, _ := os.ReadFile(uTarget)
	check("unwrap rebuilt the wrapped row",
		string(uOut), "| ~~M7~~ done — evidence spilled into this cell | ~~task~~ | ~~High~~ |\n")

	// ----- check-rows --normalize: trailing empty cells from formatter alignment -----
	nTarget := repairDir + "/padded.md"
	nSample := "| A | B |\n| --- | --- |\n| ~~x~~ | ~~y~~ | | |\n| ~~keep~~ | ~~me~~ | |\n"
	if err := os.WriteFile(nTarget, []byte(nSample), 0o644); err != nil {
		return err
	}

	if err := normalizeFile(nTarget); err != nil {
		failures = append(failures, "normalize: unexpected error "+err.Error())
	}

	nOut, _ := os.ReadFile(nTarget)
	check("normalize trimmed padded struck rows",
		string(nOut), "| A | B |\n| --- | --- |\n| ~~x~~ | ~~y~~ |\n| ~~keep~~ | ~~me~~ |\n")

	// ----- emit-keys: every emitted key must match back into its own line
	// (the 2026-10-15 07-21 off-by-one lesson, as a regression pin) -----
	kFixture := []string{
		"1. first prose item",
		"",
		"| T3 | table row text | Low |",
		"",
		"- [ ] checkbox item here",
	}
	for i, l := range kFixture {
		key, ok, kerr := emitKeyFor(l)
		if kerr != nil {
			failures = append(failures, fmt.Sprintf("emitKeyFor(%d): unexpected error %v", i+1, kerr))

			continue
		}

		if !ok {
			continue
		}

		tok := key
		substr := key

		if at := strings.Index(key, "@"); at >= 0 {
			tok, substr = key[:at], key[at+1:]
		}

		if !strings.Contains(l, tok) || !strings.Contains(l, substr) {
			failures = append(failures, fmt.Sprintf("emitKeyFor line %d: key %q does not round-trip into %q", i+1, key, l))
		}
	}

	if _, ok, _ := emitKeyFor("plain paragraph line"); ok {
		failures = append(failures, "emitKeyFor: plain paragraph reported ok")
	}

	if len(failures) > 0 {
		return fail("self-test FAILED (%d):\n  %s", len(failures), strings.Join(failures, "\n  "))
	}
	fmt.Println("self-tests: all passed (markers + rows guards + prose strikes + atomic dry-run)")
	return nil
}
