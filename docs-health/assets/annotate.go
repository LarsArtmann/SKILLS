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
//	check-rows <file>...                               (exit 1 on PARTIAL table rows)
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
  check-rows <file>...
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
			fmt.Fprintf(os.Stderr, "--emit-keys: line %d is not a numbered row, table row, or checkbox; use an `any:` key manually if warranted\n", no)
			continue
		}
		rest = strings.TrimSpace(strings.SplitN(rest, "\t", 2)[0])
		runes := []rune(rest)
		if len(runes) > 32 {
			runes = runes[:32]
		}
		substr := strings.TrimSpace(string(runes))
		if substr == "" {
			return fail("--emit-keys: line %d has no text after its marker", no)
		}
		key := substr
		if tok != "" {
			key = tok + "@" + substr
		}
		fmt.Println(key)
		fmt.Fprintf(os.Stderr, "%d: %.100s\n", no, strings.TrimSpace(line))
	}
	return nil
}

// ---------- check-rows ----------

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
	var block []struct {
		no  int
		str string
	}
	flush := func() {
		if len(block) == 0 {
			return
		}
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
			block = append(block, struct {
				no  int
				str string
			}{i + 1, strings.TrimRight(line, "\n")})
			continue
		}
		flush()
	}
	flush()
	for _, p := range problems {
		fmt.Println(p)
	}
	if len(problems) > 0 {
		return 1, nil
	}
	return 0, nil
}

func cmdCheckRows(argv []string) error {
	if len(argv) < 1 {
		usage()
		os.Exit(2)
	}
	failures := 0
	incomplete := 0
	for _, arg := range argv {
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
		return fmt.Errorf("check-rows: %d/%d file(s) incomplete", incomplete, len(argv))
	}
	fmt.Printf("check-rows: %d file(s) complete\n", len(argv))
	return nil
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

	if len(failures) > 0 {
		return fail("self-test FAILED (%d):\n  %s", len(failures), strings.Join(failures, "\n  "))
	}
	fmt.Println("self-tests: all passed (markers + rows guards + prose strikes + atomic dry-run)")
	return nil
}
