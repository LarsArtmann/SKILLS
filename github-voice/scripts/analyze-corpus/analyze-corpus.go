// analyze-corpus — analyze the collected GitHub corpus and emit stats for
// the voice profile. Port of analyze-corpus.py: reads raw/items.json,
// raw/comments.json, raw/edits.json from the collect-corpus output
// directory and writes analysis{-since}.json plus a human-readable
// ANALYSIS{-since}.md. Segments the corpus by own/external repo and
// artifact kind so the voice profile can weight external-repo writing
// (the natural voice) over own-repo automation noise.
//
// Run: go run analyze-corpus.go [--out ~/.cache/github-voice-corpus]
//
//	[--own-owners LarsArtmann,Artmann-Games] [--since 2024-01-01]
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"math"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"time"
)

var emojiRe = regexp.MustCompile(`[\x{1F300}-\x{1FAFF}\x{2700}-\x{27BF}\x{2600}-\x{26FF}\x{2B00}-\x{2BFF}\x{1F000}-\x{1F02F}\x{2139}\x{FE0F}]`)

type record = map[string]any

func pct(part, whole int) float64 {
	if whole == 0 {
		return 0
	}
	return math.Round(100*float64(part)/float64(whole)*10) / 10
}

type quantiles struct {
	present       bool
	p10, p50, p90 int
}

func take(sv []int, q float64) int {
	return sv[min(int(q*float64(len(sv))), len(sv)-1)]
}

func quantile(values []int) quantiles {
	if len(values) == 0 {
		return quantiles{}
	}
	sv := append([]int(nil), values...)
	sort.Ints(sv)
	return quantiles{present: true, p10: take(sv, 0.10), p50: take(sv, 0.50), p90: take(sv, 0.90)}
}

type feats struct {
	chars, words                 int
	codeFence, inlineCode, link  bool
	bullets, header, bold, emoji bool
	mention, question            bool
}

func featurize(body string) feats {
	return feats{
		chars:      len([]rune(body)),
		words:      len(strings.Fields(body)),
		codeFence:  strings.Contains(body, "```"),
		inlineCode: strings.Contains(body, "`"),
		link:       strings.Contains(body, "](") || strings.Contains(body, "http"),
		bullets:    regexp.MustCompile(`(?m)^(\*|-|\d+\.) `).MatchString(body),
		header:     regexp.MustCompile(`(?m)^#+ `).MatchString(body),
		bold:       strings.Contains(body, "**"),
		emoji:      emojiRe.MatchString(body),
		mention:    strings.Contains(body, "@"),
		question:   strings.Contains(body, "?"),
	}
}

func openingBucket(body string) string {
	firstLine := strings.Split(strings.TrimSpace(body), "\n")[0]
	runes := []rune(firstLine)
	if len(runes) > 60 {
		runes = runes[:60]
	}
	first := strings.ToLower(string(runes))
	if regexp.MustCompile(`^(hey|hi|hello)\b`).MatchString(first) {
		return "greeting"
	}
	if regexp.MustCompile(`^(thanks|thank you|ty)\b`).MatchString(first) {
		return "thanks-first"
	}
	if regexp.MustCompile(`^sorry\b`).MatchString(first) {
		return "sorry-first"
	}
	if strings.HasSuffix(first, "?") {
		return "question-first"
	}
	if strings.HasPrefix(first, "#") {
		return "header-first"
	}
	return "direct"
}

// counted is an ordered key→count map that marshals in insertion order
// (mirroring Python's dict(Counter(...)) JSON shape).
type counted struct {
	keys   []string
	counts map[string]int
}

func newCounted() *counted { return &counted{counts: map[string]int{}} }

func (c *counted) add(k string) {
	if _, seen := c.counts[k]; !seen {
		c.keys = append(c.keys, k)
	}
	c.counts[k]++
}

func (c *counted) marshal() []byte {
	type kv struct {
		k string
		v int
	}
	entries := make([]kv, 0, len(c.keys))
	for _, k := range c.keys {
		entries = append(entries, kv{k, c.counts[k]})
	}
	// most_common: count desc, stable by first encounter.
	sort.SliceStable(entries, func(i, j int) bool { return entries[i].v > entries[j].v })
	var b strings.Builder
	b.WriteString("{")
	for i, e := range entries {
		if i > 0 {
			b.WriteString(", ")
		}
		kb, _ := json.Marshal(e.k)
		b.WriteString(fmt.Sprintf("%s: %d", kb, e.v))
	}
	b.WriteString("}")
	return []byte(b.String())
}

func (c *counted) repr() string {
	type kv struct {
		k string
		v int
	}
	entries := make([]kv, 0, len(c.keys))
	for _, k := range c.keys {
		entries = append(entries, kv{k, c.counts[k]})
	}
	sort.SliceStable(entries, func(i, j int) bool { return entries[i].v > entries[j].v })
	parts := make([]string, 0, len(entries))
	for _, e := range entries {
		parts = append(parts, fmt.Sprintf("'%s': %d", e.k, e.v))
	}
	return "{" + strings.Join(parts, ", ") + "}"
}

func ngrams(texts []string, n, top int) [][2]any {
	counts := newCounted()
	re := regexp.MustCompile(`[a-zA-Z']+`)
	for _, t := range texts {
		tokens := re.FindAllString(strings.ToLower(t), -1)
		for i := 0; i+n <= len(tokens); i++ {
			counts.add(strings.Join(tokens[i:i+n], " "))
		}
	}
	type kv struct {
		k string
		v int
	}
	var entries []kv
	for _, k := range counts.keys {
		entries = append(entries, kv{k, counts.counts[k]})
	}
	sort.SliceStable(entries, func(i, j int) bool { return entries[i].v > entries[j].v })
	if len(entries) > top {
		entries = entries[:top]
	}
	out := make([][2]any, 0, len(entries))
	for _, e := range entries {
		out = append(out, [2]any{e.k, e.v})
	}
	return out
}

var agentMarkers = []string{
	"Task ID:", "Impact Score", "**Phase:**", "ISSUE TYPE", "Priority: 🔥",
	"TECHNICAL DEBT:", "## 🚨", "### 🎯", "- **Effort", "**Effort:**",
}

func isAgent(body string) bool {
	runes := []rune(body)
	head := body
	if len(runes) > 800 {
		head = string(runes[:800])
	}
	hits := 0
	for _, m := range agentMarkers {
		if strings.Contains(head, m) {
			hits++
		}
	}
	return hits >= 2
}

// segStats mirrors analyze-corpus.py's seg_stats dict, field order included
// so the JSON output shape stays stable for downstream tooling.
type segStats struct {
	Label         string          `json:"label,omitempty"`
	Count         int             `json:"count"`
	Length        *quantilesJSON  `json:"length"`
	Words         *quantilesJSON  `json:"words"`
	CodeFencePct  float64         `json:"code_fence_pct"`
	InlineCodePct float64         `json:"inline_code_pct"`
	LinkPct       float64         `json:"link_pct"`
	BulletsPct    float64         `json:"bullets_pct"`
	HeaderPct     float64         `json:"header_pct"`
	BoldPct       float64         `json:"bold_pct"`
	EmojiPct      float64         `json:"emoji_pct"`
	MentionPct    float64         `json:"mention_pct"`
	QuestionPct   float64         `json:"question_pct"`
	Openings      json.RawMessage `json:"openings"`
	OpeningsRepr  string          `json:"-"`
	Bigrams       [][2]any        `json:"bigrams"`
	Trigrams      [][2]any        `json:"trigrams"`
}

type quantilesJSON struct {
	P10 *int `json:"p10"`
	P50 *int `json:"p50"`
	P90 *int `json:"p90"`
}

func intPtr(v int) *int { return &v }

func quantilesToJSON(q quantiles) *quantilesJSON {
	if !q.present {
		return nil
	}
	return &quantilesJSON{P10: intPtr(q.p10), P50: intPtr(q.p50), P90: intPtr(q.p90)}
}

func segTexts(recs []record, field string) []string {
	var out []string
	for _, r := range recs {
		if s, _ := r[field].(string); strings.TrimSpace(s) != "" {
			out = append(out, s)
		}
	}
	return out
}

func segStatsOf(label string, texts []string) segStats {
	fs := make([]feats, 0, len(texts))
	for _, t := range texts {
		fs = append(fs, featurize(t))
	}
	lengths := []int{}
	for _, f := range fs {
		lengths = append(lengths, f.chars)
	}
	if len(lengths) == 0 {
		lengths = []int{0}
	}
	words := []int{}
	for _, f := range fs {
		words = append(words, f.words)
	}
	if len(words) == 0 {
		words = []int{0}
	}
	n := len(fs)
	openings := newCounted()
	for _, t := range texts {
		openings.add(openingBucket(t))
	}
	sum := func(get func(feats) bool) int {
		c := 0
		for _, f := range fs {
			if get(f) {
				c++
			}
		}
		return c
	}
	return segStats{
		Label:         label,
		Count:         len(texts),
		Length:        quantilesToJSON(quantile(lengths)),
		Words:         quantilesToJSON(quantile(words)),
		CodeFencePct:  pct(sum(func(f feats) bool { return f.codeFence }), n),
		InlineCodePct: pct(sum(func(f feats) bool { return f.inlineCode }), n),
		LinkPct:       pct(sum(func(f feats) bool { return f.link }), n),
		BulletsPct:    pct(sum(func(f feats) bool { return f.bullets }), n),
		HeaderPct:     pct(sum(func(f feats) bool { return f.header }), n),
		BoldPct:       pct(sum(func(f feats) bool { return f.bold }), n),
		EmojiPct:      pct(sum(func(f feats) bool { return f.emoji }), n),
		MentionPct:    pct(sum(func(f feats) bool { return f.mention }), n),
		QuestionPct:   pct(sum(func(f feats) bool { return f.question }), n),
		Openings:      openings.marshal(),
		OpeningsRepr:  openings.repr(),
		Bigrams:       ngrams(texts, 2, 20),
		Trigrams:      ngrams(texts, 3, 15),
	}
}

type agentSeg struct {
	Count int    `json:"count"`
	Note  string `json:"note"`
}

type segments struct {
	BodiesExternal segStats `json:"bodies_external_issues_prs"`
	BodiesOwn      segStats `json:"bodies_own_handwritten"`
	BodiesAgent    agentSeg `json:"bodies_own_agent_suspect"`
	CommentsExt    segStats `json:"comments_external"`
	CommentsOwn    segStats `json:"comments_own"`
}

type editsInfo struct {
	ItemsWithEdits     int            `json:"items_with_edits"`
	EditCountDist      *quantilesJSON `json:"edit_count_dist"`
	WithTwoPlusVersion int            `json:"with_two_plus_versions"`
}

type reactionsInfo struct {
	CommentsMeanReactions float64  `json:"comments_mean_reactions"`
	TopReacted            []record `json:"top_reacted"`
}

type temporalInfo struct {
	FirstItem    string          `json:"first_item"`
	LastItem     string          `json:"last_item"`
	ItemsPerYear json.RawMessage `json:"items_per_year"`
}

type analysis struct {
	Generated string        `json:"generated"`
	Segments  segments      `json:"segments"`
	Edits     editsInfo     `json:"edits"`
	Reactions reactionsInfo `json:"reactions"`
	Temporal  temporalInfo  `json:"temporal"`
}

func loadJSON(path string) (any, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var v any
	if err := json.Unmarshal(raw, &v); err != nil {
		return nil, fmt.Errorf("%s: %w", path, err)
	}
	return v, nil
}

func asRecords(v any) []record {
	list, _ := v.([]any)
	out := make([]record, 0, len(list))
	for _, e := range list {
		if m, ok := e.(map[string]any); ok {
			out = append(out, m)
		}
	}
	return out
}

func str(r record, key string) string {
	s, _ := r[key].(string)
	return s
}

func num(r record, key string) int {
	f, _ := r[key].(float64)
	return int(f)
}

func main() {
	out := flag.String("out", "~/.cache/github-voice-corpus", "corpus directory")
	ownOwners := flag.String("own-owners", "LarsArtmann,Artmann-Games", "comma-separated own owners")
	since := flag.String("since", "", "only analyze created >= this date (YYYY-MM-DD)")
	flag.Parse()

	dir, err := expandHome(*out)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	own := map[string]bool{}
	for _, o := range strings.Split(*ownOwners, ",") {
		own[strings.TrimSpace(o)] = true
	}

	itemsV, err := loadJSON(filepath.Join(dir, "raw", "items.json"))
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	commentsV, err := loadJSON(filepath.Join(dir, "raw", "comments.json"))
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	editsV, err := loadJSON(filepath.Join(dir, "raw", "edits.json"))
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	items := asRecords(itemsV)
	comments := asRecords(commentsV)
	editsMap, _ := editsV.(map[string]any)

	if *since != "" {
		filtered := items[:0]
		for _, i := range items {
			if str(i, "created") >= *since {
				filtered = append(filtered, i)
			}
		}
		items = filtered
		filteredC := comments[:0]
		for _, c := range comments {
			if str(c, "created") >= *since {
				filteredC = append(filteredC, c)
			}
		}
		comments = filteredC
		fmt.Printf("[since] filtering to created >= %s: %d items, %d comments\n", *since, len(items), len(comments))
	}

	ownerOf := func(repo string) string {
		parts := strings.SplitN(repo, "/", 2)
		if len(parts) == 0 {
			return ""
		}
		return parts[0]
	}
	var bodiesExt, bodiesOwn, bodiesAgent []record
	for _, i := range items {
		if !truthy(i["authored"]) {
			continue
		}
		switch {
		case !own[ownerOf(str(i, "repo"))]:
			bodiesExt = append(bodiesExt, i)
		case !isAgent(str(i, "body")):
			bodiesOwn = append(bodiesOwn, i)
		default:
			bodiesAgent = append(bodiesAgent, i)
		}
	}
	var cExt, cOwn []record
	for _, c := range comments {
		parentURL := str(c, "parent_url")
		idx := strings.Index(parentURL, "github.com/")
		owner := ""
		if idx >= 0 {
			owner = ownerOf(parentURL[idx+len("github.com/"):])
		}
		if own[owner] {
			cOwn = append(cOwn, c)
		} else {
			cExt = append(cExt, c)
		}
	}

	analysisJSON := analysis{
		Generated: time.Now().UTC().Format("2006-01-02T15:04:05.000000-07:00"),
		Segments: segments{
			BodiesExternal: segStatsOf("external bodies", segTexts(bodiesExt, "body")),
			BodiesOwn:      segStatsOf("own bodies (non-agent)", segTexts(bodiesOwn, "body")),
			BodiesAgent:    agentSeg{Count: len(bodiesAgent), Note: "flagged agent-generated; excluded from voice"},
			CommentsExt:    segStatsOf("comments in external repos", segTexts(cExt, "body")),
			CommentsOwn:    segStatsOf("comments in own repos", segTexts(cOwn, "body")),
		},
	}

	editCounts := []int{}
	twoPlusCount := 0
	for _, e := range editsMap {
		rec, _ := e.(record)
		editCounts = append(editCounts, num(rec, "edit_count"))
		versions, _ := rec["versions"].([]any)
		if len(versions) >= 2 {
			twoPlusCount++
		}
	}
	analysisJSON.Edits = editsInfo{
		ItemsWithEdits:     len(editsMap),
		EditCountDist:      quantilesToJSON(quantile(editCounts)),
		WithTwoPlusVersion: twoPlusCount,
	}

	mean := 0.0
	if len(comments) > 0 {
		total := 0
		for _, c := range comments {
			total += num(c, "reactions")
		}
		mean = math.Round(float64(total)/float64(len(comments))*100) / 100
	}
	topReacted := append([]record(nil), comments...)
	sort.SliceStable(topReacted, func(i, j int) bool { return num(topReacted[i], "reactions") > num(topReacted[j], "reactions") })
	if len(topReacted) > 15 {
		topReacted = topReacted[:15]
	}
	analysisJSON.Reactions = reactionsInfo{CommentsMeanReactions: mean, TopReacted: topReacted}

	first, last := "", ""
	for _, i := range items {
		c := str(i, "created")
		if first == "" || c < first {
			first = c
		}
		if last == "" || c > last {
			last = c
		}
	}
	years := newCounted()
	for _, i := range items {
		if truthy(i["authored"]) {
			years.add(str(i, "created")[:4])
		}
	}
	var yearEntries []struct {
		k string
		v int
	}
	for _, k := range years.keys {
		yearEntries = append(yearEntries, struct {
			k string
			v int
		}{k, years.counts[k]})
	}
	sort.Slice(yearEntries, func(i, j int) bool { return yearEntries[i].k < yearEntries[j].k })
	var yearsRaw strings.Builder
	yearsRaw.WriteString("{")
	for idx, e := range yearEntries {
		if idx > 0 {
			yearsRaw.WriteString(", ")
		}
		yearsRaw.WriteString(fmt.Sprintf("%q: %d", e.k, e.v))
	}
	yearsRaw.WriteString("}")
	analysisJSON.Temporal = temporalInfo{
		FirstItem:    first,
		LastItem:     last,
		ItemsPerYear: json.RawMessage(yearsRaw.String()),
	}

	suffix := ""
	if *since != "" {
		suffix = "-since-" + *since
	}
	analysisBytes, err := marshalIndent(analysisJSON)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if err := os.WriteFile(filepath.Join(dir, "analysis"+suffix+".json"), analysisBytes, 0o644); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	var lines []string
	lines = append(lines, "# Corpus analysis — "+analysisJSON.Generated, "")
	segLines := func(key string, s segStats) []string {
		return []string{
			fmt.Sprintf("## %s — %s (n=%d)", key, s.Label, s.Count),
			fmt.Sprintf("- length p10/p50/p90: %s/%s/%s chars", qOrNone(s.Length, "p10"), qOrNone(s.Length, "p50"), qOrNone(s.Length, "p90")),
			fmt.Sprintf("- code fence %s%% | inline code %s%% | links %s%% | bullets %s%% | headers %s%% | bold %s%% | emoji %s%% | mentions %s%% | question %s%%",
				pctStr(s.CodeFencePct), pctStr(s.InlineCodePct), pctStr(s.LinkPct), pctStr(s.BulletsPct),
				pctStr(s.HeaderPct), pctStr(s.BoldPct), pctStr(s.EmojiPct), pctStr(s.MentionPct), pctStr(s.QuestionPct)),
			fmt.Sprintf("- openings: %s", s.OpeningsRepr),
			fmt.Sprintf("- top bigrams: %s", tupleRepr(s.Bigrams)),
			"",
		}
	}
	lines = append(lines, segLines("bodies_external_issues_prs", analysisJSON.Segments.BodiesExternal)...)
	lines = append(lines, segLines("bodies_own_handwritten", analysisJSON.Segments.BodiesOwn)...)
	lines = append(lines, fmt.Sprintf("## bodies_own_agent_suspect: %d (%s)", analysisJSON.Segments.BodiesAgent.Count, analysisJSON.Segments.BodiesAgent.Note), "")
	lines = append(lines, segLines("comments_external", analysisJSON.Segments.CommentsExt)...)
	lines = append(lines, segLines("comments_own", analysisJSON.Segments.CommentsOwn)...)
	if err := os.WriteFile(filepath.Join(dir, "ANALYSIS"+suffix+".md"), []byte(strings.Join(lines, "\n")), 0o644); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("[done] analysis%s.json and ANALYSIS%s.md (%d items, %d comments, %d edited)\n",
		suffix, suffix, len(items), len(comments), len(editsMap))
}

func truthy(v any) bool {
	b, _ := v.(bool)
	return b
}

func qOrNone(q *quantilesJSON, key string) string {
	if q == nil {
		return "None"
	}
	var v *int
	switch key {
	case "p10":
		v = q.P10
	case "p50":
		v = q.P50
	case "p90":
		v = q.P90
	}
	if v == nil {
		return "None"
	}
	return fmt.Sprintf("%d", *v)
}

func pctStr(v float64) string {
	return fmt.Sprintf("%.1f", v)
}

func tupleRepr(pairs [][2]any) string {
	parts := make([]string, 0, len(pairs))
	for _, p := range pairs {
		parts = append(parts, fmt.Sprintf("('%s', %d)", p[0], p[1]))
	}
	return "[" + strings.Join(parts, ", ") + "]"
}

func marshalIndent(v any) ([]byte, error) {
	var buf strings.Builder
	enc := json.NewEncoder(&buf)
	enc.SetEscapeHTML(false)
	enc.SetIndent("", " ")
	if err := enc.Encode(v); err != nil {
		return nil, err
	}
	return []byte(strings.TrimSuffix(buf.String(), "\n")), nil
}

func expandHome(path string) (string, error) {
	if strings.HasPrefix(path, "~/") {
		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		return filepath.Join(home, path[2:]), nil
	}
	return path, nil
}
