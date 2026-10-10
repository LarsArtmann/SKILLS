// check-draft — mechanical second pass of the github-voice skill: catches
// AI-tell phrases, wrong register, greeting/sign-off boilerplate,
// double-hedging, emoji overuse, and AI-attribution inconsistency.
// Port of check-draft.py (same ban lists, same exit codes: 0 = no FAIL,
// 1 = at least one FAIL, 2 = usage error). The third pass (human re-read
// against the profile's Do/Never table) stays with the agent — this is
// grep, not judgment.
//
// Ban lists are empirical: every FAIL phrase has 0 hits across 555
// external texts (>= 2024) in Lars's corpus, verified 2026-09-12. Do not
// add phrases on vibes — re-verify against the corpus first.
//
// Run: go run check-draft.go --kind <kind> [--ai-drafted] [--unsolicited] <file|'-'>
//      go run check-draft.go --list
//      go run check-draft.go --self-test
package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"regexp"
	"strings"
)

var failPhrases = []string{
	"i hope this helps",
	"hope this helps",
	"please let me know",
	"let me know if",
	"thank you for bringing this to our attention",
	"great question",
	"i'd be happy to",
	"i would be happy to",
	"happy to help",
	"as an ai",
	"don't hesitate",
	"do not hesitate",
	"thanks for your patience",
	"thank you for your patience",
	"apologies for the delay",
	"sorry for the delay",
	"amazing project",
	"great project",
	"awesome project",
	"first of all",
	"dear maintainers",
	"dear team",
	"hi team",
	"hello team",
	"thanks in advance",
	"thank you in advance",
	"unfortunately,",
	"furthermore,",
	"moreover,",
	"of course!",
	"absolutely!",
	"sure thing",
	"delve into",
	"please note that",
	"it's worth noting",
	"kindly",
	"that being said",
	"with that said",
	"going forward,",
}

// warnPhrases: present in the corpus only rarely or in natural technical
// use (note in parentheses) — warn, never fail.
var warnPhrases = []struct {
	phrase string
	note   string
}{
	{"feel free to", "1"},
	{"in summary", "technical noun 'summary' in crush context"},
	{"to summarize", "technical verb in crush context"},
	{"additionally,", "1"},
	{"best regards", "1 formal 2024 email signature"},
	{"certainly!", "0"},
	{"leverage", "2"},
	{"utilize", "2"},
	{"seamless", "2"},
}

var (
	signoffRe = regexp.MustCompile(`(?i)^(thanks!?|thank you!?$|best regards.*|kind regards.*|` +
		`cheers!?$|sincerely.*|regards,?.*)\s*$`)
	greetingRe    = regexp.MustCompile(`(?i)^\s*(hi|hello|hey|dear|greetings)\b`)
	dearGreetRe   = regexp.MustCompile(`(?i)^\s*(dear|greetings)\b`)
	doubleHedgeRe = regexp.MustCompile(`(?i)\b(i think|i believe|maybe|might|perhaps)\b[^.!?]{0,60}` +
		`\b(i think|i believe|maybe|might|perhaps)\b`)
	emojiRe       = regexp.MustCompile(`[\x{1F000}-\x{1FAFF}\x{2600}-\x{27BF}\x{2B00}-\x{2BFF}\x{2139}\x{FE0F}]`)
	emojiHeaderRe = regexp.MustCompile(`(?m)^#+.*[\x{1F000}-\x{1FAFF}\x{2600}-\x{27BF}]`)
	headerRe      = regexp.MustCompile(`(?m)^#{1,6} `)
	footerRe      = regexp.MustCompile(`(?i)(generated with|co-authored-by|assisted-by)`)
	evidenceRe    = regexp.MustCompile(`(?mi)(\x60\x60\x60|\]\(|https?://|^\s*\|)`)

	bannerBody        = `> \[!NOTE\]\s*\n>[^\n]*via Crush[^\n]*\n>(?:[^\n]*\n>)?[^\n]*MANUALLY REVIEWED`
	unsolicitedBanner = regexp.MustCompile(`(?i)` + bannerBody)
	unsolicitedTop    = regexp.MustCompile(`(?i)\A\s*` + bannerBody)
)

type finding struct {
	level string
	name  string
	msg   string
}

func contentLines(text string) []string {
	var out []string
	for _, line := range strings.Split(text, "\n") {
		s := strings.TrimSpace(line)
		if s == "" || strings.HasPrefix(s, ">") {
			continue
		}
		out = append(out, s)
	}
	return out
}

func check(kind, text string, aiDrafted, unsolicited bool) []finding {
	var findings []finding
	low := strings.ToLower(text)
	lines := contentLines(text)

	for _, phrase := range failPhrases {
		if strings.Contains(low, phrase) {
			findings = append(findings, finding{"FAIL", "ai-tell phrase",
				fmt.Sprintf("%q — 0 hits in corpus", phrase)})
		}
	}
	for _, w := range warnPhrases {
		if strings.Contains(low, w.phrase) {
			findings = append(findings, finding{"WARN", "rare phrase",
				fmt.Sprintf("%q (%s) — usually AI", w.phrase, w.note)})
		}
	}

	if doubleHedgeRe.MatchString(text) {
		findings = append(findings, finding{"FAIL", "double hedge",
			"two hedges in one sentence — corpus has zero"})
	}

	if len(lines) > 0 {
		first := lines[0]
		if kind != "announcement" && !strings.Contains(first, "@") {
			if dearGreetRe.MatchString(first) {
				findings = append(findings, finding{"FAIL", "greeting opener",
					"\"Dear/Greetings\" openers: 0 hits in corpus — open with the problem instead"})
			} else if greetingRe.MatchString(first) {
				findings = append(findings, finding{"WARN", "greeting opener",
					"hi/hey openers are rare (10/555 corpus texts) and real when addressed: " +
						"'Hey guys,' / 'Hi @name' — otherwise open with the problem"})
			}
		}
		last := lines[len(lines)-1]
		if signoffRe.MatchString(last) {
			findings = append(findings, finding{"FAIL", "sign-off",
				fmt.Sprintf("%q — never signs off", last)})
		}
	}

	emojiCount := len(emojiRe.FindAllString(text, -1))
	if kind != "announcement" && emojiHeaderRe.MatchString(text) {
		findings = append(findings, finding{"FAIL", "emoji header",
			"emoji in headers is agent-era style (allowed only in announcement kind)"})
	}

	if kind == "comment" || kind == "review" {
		if headerRe.MatchString(text) {
			findings = append(findings, finding{"FAIL", "headers in comment",
				"comments are plain text — if this is a release announcement or an " +
					"AI-assisted review report, use --kind announcement"})
		}
		if emojiCount >= 3 {
			findings = append(findings, finding{"FAIL", "emoji overuse",
				fmt.Sprintf("%d emoji — quick comments carry 0-1 (2+ only in the announcement genre)", emojiCount)})
		} else if emojiCount == 2 {
			findings = append(findings, finding{"WARN", "emoji count", "2 emoji — quick comments carry 0-1"})
		}
		if len(text) > 600 && !evidenceRe.MatchString(text) {
			findings = append(findings, finding{"WARN", "long comment without evidence",
				"long comments in the corpus are evidence dumps (code fence, link, or table) — this is just prose"})
		}
		if footerRe.MatchString(text) {
			findings = append(findings, finding{"FAIL", "footer on comment",
				"AI-attribution footers never appear on quick comments"})
		}
	} else {
		emojiCap := 4
		if kind == "announcement" {
			emojiCap = 24
		}
		if emojiCount > emojiCap {
			findings = append(findings, finding{"WARN", "emoji overuse",
				fmt.Sprintf("%d emoji — beyond anything in the corpus for this kind", emojiCount)})
		}
		if len(text) < 200 {
			findings = append(findings, finding{"WARN", "thin body",
				fmt.Sprintf("%d chars — 2026 body register is long+structured (median ~1,050)", len(text))})
		}
		if aiDrafted && !footerRe.MatchString(text) {
			findings = append(findings, finding{"FAIL", "missing attribution",
				"AI-drafted bodies carry a footer (e.g. \"💘 Generated with Crush\")"})
		}
		if !aiDrafted && footerRe.MatchString(text) {
			findings = append(findings, finding{"WARN", "footer without --ai-drafted",
				"footer present but flag not set — pass --ai-drafted or remove the footer " +
					"if you wrote it unaided"})
		}
		if unsolicited && !unsolicitedTop.MatchString(text) {
			findings = append(findings, finding{"FAIL", "missing provenance banner",
				"unsolicited AI-found filings open with the \"> [!IMPORTANT] ... found and " +
					"reported by ... MANUALLY REVIEWED\" banner (box unchecked)"})
		}
		if !unsolicited && unsolicitedBanner.MatchString(text) {
			findings = append(findings, finding{"WARN", "banner without --unsolicited",
				"provenance banner present but flag not set — pass --unsolicited for " +
					"AI-initiated findings, or drop the banner if Lars requested this filing"})
		}
	}
	return findings
}

// selfTest asserts the provenance-banner regex accepts both banner layouts:
// the compact 3-line form shipped by earlier filings and the documented
// 4-line form from the SKILL.md quick rules (blank `>` line between). A
// body without the banner must fail. Wording corrected 2026-10-03.
func selfTest() int {
	compact := "> [!NOTE]\n" +
		"> This filing was drafted by GLM-5.3 via Crush from an AI-run investigation, not at my request.\n" +
		"> - [ ] MANUALLY REVIEWED by `@Lars Artmann` at `[<date-time>]`\n\n" +
		"## Symptom\n\n" + strings.Repeat("x", 300)
	documented := "> [!NOTE]\n" +
		"> This filing was drafted by GLM-5.3 via Crush from an AI-run investigation, not at my request.\n" +
		">\n" +
		"> - [ ] MANUALLY REVIEWED by `@Lars Artmann` at `[<date-time>]`\n\n" +
		"## Symptom\n\n" + strings.Repeat("x", 300)
	missing := "## Symptom\n\n" + strings.Repeat("x", 300)
	cases := []struct {
		name     string
		body     string
		expected bool
	}{
		{"compact 3-line banner accepted", compact, true},
		{"documented 4-line banner accepted", documented, true},
		{"missing banner rejected", missing, false},
	}
	failures := 0
	for _, c := range cases {
		got := unsolicitedTop.MatchString(c.body)
		if got != c.expected {
			fmt.Printf("SELF-TEST FAIL: %s (banner detected=%v, want=%v)\n", c.name, got, c.expected)
			failures++
		}
	}
	if failures > 0 {
		return 1
	}
	fmt.Println("SELF-TEST PASSED: banner regex accepts both documented layouts")
	return 0
}

const usageText = `usage: go run check-draft.go --kind <kind> [--ai-drafted] [--unsolicited] <file|'-'>

kinds: body-issue | body-pr | comment | review | announcement
  announcement = release posts / AI-assisted review reports: headers, emoji
  headers, 'Hi,' openers, and AI footers are allowed there
  --ai-drafted  bodies then REQUIRE an attribution footer
  --unsolicited bodies then REQUIRE the provenance banner up top
other: --list (show all checks and phrase lists), --self-test
`

func main() {
	var kind, file string
	aiDrafted, unsolicited, list, selfTestFlag := false, false, false, false
	args := os.Args[1:]
	for i := 0; i < len(args); i++ {
		a := args[i]
		switch a {
		case "--ai-drafted":
			aiDrafted = true
		case "--unsolicited":
			unsolicited = true
		case "--list":
			list = true
		case "--self-test":
			selfTestFlag = true
		case "--kind":
			if i+1 >= len(args) {
				fmt.Fprintln(os.Stderr, "usage error: --kind needs a value")
				os.Exit(2)
			}
			i++
			kind = args[i]
		default:
			if file == "" {
				file = a
			} else {
				fmt.Fprintln(os.Stderr, "usage error: multiple file arguments")
				os.Exit(2)
			}
		}
	}

	if selfTestFlag {
		os.Exit(selfTest())
	}

	if list {
		fmt.Println("FAIL phrases (0 hits in corpus, verified 2026-09-12):")
		for _, p := range failPhrases {
			fmt.Printf("  %s\n", p)
		}
		fmt.Println("\nWARN phrases (rare or technical in corpus):")
		for _, w := range warnPhrases {
			fmt.Printf("  %s  (%s)\n", w.phrase, w.note)
		}
		fmt.Println("\nStructural checks: ai-tell grep, double-hedge, greeting " +
			"opener (unless @mention), sign-off, emoji headers, " +
			"comment: no headers / max 1 emoji / no footer, body: " +
			"attribution footer iff --ai-drafted, provenance banner " +
			"iff --unsolicited, thin-body warn.")
		os.Exit(0)
	}

	if kind == "" || !validKind(kind) {
		fmt.Fprintln(os.Stderr, usageText)
		os.Exit(2)
	}
	if file == "" {
		fmt.Fprintln(os.Stderr, "usage error: file required (or use --list)")
		os.Exit(2)
	}
	var text string
	if file == "-" {
		raw, err := io.ReadAll(bufio.NewReader(os.Stdin))
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(2)
		}
		text = string(raw)
	} else {
		raw, err := os.ReadFile(file)
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(2)
		}
		text = string(raw)
	}

	findings := check(kind, text, aiDrafted, unsolicited)
	fails, warns := 0, 0
	for _, f := range findings {
		if f.level == "FAIL" {
			fails++
		} else {
			warns++
		}
		fmt.Printf("%s: [%s] %s\n", f.level, f.name, f.msg)
	}
	verdict := "FIX THE FAILS"
	if fails == 0 {
		verdict = "VOICE CHECK PASSED"
	}
	fmt.Printf("== %d FAIL, %d WARN (%s)\n", fails, warns, verdict)
	if fails > 0 {
		os.Exit(1)
	}
}

func validKind(k string) bool {
	switch k {
	case "body-issue", "body-pr", "comment", "review", "announcement":
		return true
	}
	return false
}
