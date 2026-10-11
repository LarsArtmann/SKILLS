// collect-corpus — collect LarsArtmann's GitHub issues, PRs, comments, and
// edit history into a markdown corpus for voice/tone analysis. Port of
// collect-corpus.py (same flags, same resume files, same API strategy).
//
// Run: go run collect-corpus.go [--user LarsArtmann] [--out ~/.cache/github-voice-corpus]
//
//	[--own-owners LarsArtmann,Artmann-Games] [--year-start 2016]
//	[--own-followup-sample 1500] [--own-edit-bodies 800]
//	[--skip-discover] [--skip-hydrate]
//
// Requires: gh CLI, authenticated. ~45 min for a full run (rate-limit aware).
//
// API strategy (empirically verified 2026-09-12):
//   - Discovery: REST search/issues windowed by created date (search caps at
//     1000 results per query; the user has 9000+ items).
//   - Comment hydration: REST per item (GraphQL connections cost node points;
//     REST is 1 point per call).
//   - Edit history: GraphQL nodes(ids:) with userContentEdits — the REST
//     .../versions endpoints 404. Diffs are fetched only for edited items.
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"
)

type ghItem struct {
	NodeID        string `json:"node_id"`
	URL           string `json:"url"`
	Repo          string `json:"repo"`
	Number        int    `json:"number"`
	Title         string `json:"title"`
	Body          string `json:"body"`
	Created       string `json:"created"`
	Updated       string `json:"updated"`
	State         string `json:"state"`
	IsPR          bool   `json:"is_pr"`
	Author        string `json:"author"`
	Reactions     int    `json:"reactions"`
	CommentsTotal int    `json:"comments_total"`
	Authored      bool   `json:"authored"`
	Commented     bool   `json:"commented"`
}

type ghComment struct {
	Kind        string  `json:"kind"`
	NodeID      string  `json:"node_id"`
	HTMLURL     string  `json:"html_url"`
	Body        string  `json:"body"`
	Created     string  `json:"created"`
	Reactions   int     `json:"reactions"`
	ReviewState string  `json:"review_state,omitempty"`
	ParentURL   string  `json:"parent_url,omitempty"`
	Parent      *ghItem `json:"-"`
}

type collector struct {
	user              string
	out               string
	ownOwners         map[string]bool
	ownFollowupSample int
	ownEditBodies     int
	items             map[string]*ghItem
	itemOrder         []string
	comments          []*ghComment
	edits             map[string]*editInfo
	editOrder         []string
	restCalls         int
	glCalls           int
}

type editInfo struct {
	EditCount int           `json:"edit_count"`
	Versions  []editVersion `json:"versions"`
	Truncated bool          `json:"truncated"`
}

type editVersion struct {
	EditedAt string `json:"editedAt"`
	Diff     string `json:"diff"`
}

const glCostQuery = `query($ids: [ID!]!, $ef: Int!) {
	rateLimit { cost remaining resetAt }
	nodes(ids: $ids) {
		__typename
		... on Issue { url userContentEdits(first: $ef) { totalCount } }
		... on PullRequest { url userContentEdits(first: $ef) { totalCount } }
		... on IssueComment { url userContentEdits(first: $ef) { totalCount } }
	}
}`

const glDiffQuery = `query($ids: [ID!]!, $ef: Int!) {
	rateLimit { cost remaining resetAt }
	nodes(ids: $ids) {
		__typename
		... on Issue { url userContentEdits(first: $ef) { totalCount nodes { editedAt diff } } }
		... on PullRequest { url userContentEdits(first: $ef) { totalCount nodes { editedAt diff } } }
		... on IssueComment { url userContentEdits(first: $ef) { totalCount nodes { editedAt diff } } }
	}
}`

// gh runs `gh api` with retries: rate-limit sleeps (Retry-After aware) and
// backoff on transient 5xx/timeouts.
func (c *collector) gh(inputText string, args ...string) (json.RawMessage, error) {
	var lastErr error
	for attempt := 0; attempt < 6; attempt++ {
		cmd := exec.Command("gh", append([]string{"api"}, args...)...)
		if inputText != "" {
			cmd.Stdin = strings.NewReader(inputText)
		}
		var stdout, stderr strings.Builder
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		if err == nil {
			c.restCalls++
			out := strings.TrimSpace(stdout.String())
			if out == "" {
				return nil, nil
			}
			return json.RawMessage(out), nil
		}
		lastErr = fmt.Errorf("gh api %s failed:\n%s", strings.Join(args, " "), stderr.String())
		errLower := strings.ToLower(stderr.String())
		if strings.Contains(errLower, "rate limit") {
			wait := 60
			if m := regexp.MustCompile(`retry after (\d+)`).FindStringSubmatch(errLower); m != nil {
				n, _ := strconv.Atoi(m[1])
				if n+2 < 300 {
					wait = n + 2
				} else {
					wait = 300
				}
			}
			fmt.Printf("  rate limited; sleeping %ds\n", wait)
			time.Sleep(time.Duration(wait) * time.Second)
			continue
		}
		if attempt < 5 && (strings.Contains(errLower, "502") || strings.Contains(errLower, "504") ||
			strings.Contains(errLower, "server error") || strings.Contains(errLower, "timed out")) {
			time.Sleep(time.Duration(5*(attempt+1)) * time.Second)
			continue
		}
		return nil, lastErr
	}
	return nil, fmt.Errorf("gh api %s: retries exhausted", strings.Join(args, " "))
}

func (c *collector) graphql(query string, ids []string, ef int) (map[string]any, error) {
	body, err := json.Marshal(map[string]any{
		"query":     query,
		"variables": map[string]any{"ids": ids, "ef": ef},
	})
	if err != nil {
		return nil, err
	}
	var lastErr error
	for attempt := 0; attempt < 10; attempt++ {
		cmd := exec.Command("gh", "api", "graphql", "--input", "-")
		cmd.Stdin = strings.NewReader(string(body))
		var stdout, stderr strings.Builder
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		if err == nil {
			var parsed struct {
				Data   map[string]any `json:"data"`
				Errors []struct {
					Message string `json:"message"`
				} `json:"errors"`
			}
			if err := json.Unmarshal([]byte(stdout.String()), &parsed); err != nil {
				return nil, err
			}
			if len(parsed.Errors) > 0 {
				msgs := make([]string, 0, len(parsed.Errors))
				for _, e := range parsed.Errors {
					msgs = append(msgs, e.Message)
				}
				joined := strings.ToLower(strings.Join(msgs, "; "))
				if strings.Contains(joined, "rate limit") {
					time.Sleep(60 * time.Second)
					continue
				}
				return nil, fmt.Errorf("GraphQL errors: %s", strings.Join(msgs, "; "))
			}
			c.glCalls++
			if rl, _ := parsed.Data["rateLimit"].(map[string]any); rl != nil {
				if rem, ok := rl["remaining"].(float64); ok && rem < 300 {
					fmt.Printf("  GraphQL budget low (%.0f); sleeping 90s (resets %v)\n", rem, rl["resetAt"])
					time.Sleep(90 * time.Second)
				}
			}
			return parsed.Data, nil
		}
		lastErr = fmt.Errorf("graphql failed: %s", stderr.String())
		if strings.Contains(strings.ToLower(stderr.String()), "rate limit") {
			time.Sleep(60 * time.Second)
			continue
		}
		if attempt < 9 {
			time.Sleep(time.Duration(5*(attempt+1)) * time.Second)
			continue
		}
		return nil, lastErr
	}
	return nil, fmt.Errorf("graphql: retries exhausted: %v", lastErr)
}

func (c *collector) restCheckBudget() {
	if c.restCalls == 0 || c.restCalls%100 != 0 {
		return
	}
	cmd := exec.Command("gh", "api", "rate_limit/resource/core", "--jq", ".resources.core.remaining")
	var stdout, stderr strings.Builder
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	if err := cmd.Run(); err == nil {
		if remaining, err := strconv.Atoi(strings.TrimSpace(stdout.String())); err == nil && remaining < 300 {
			fmt.Printf("  REST budget low (%d); sleeping 120s\n", remaining)
			time.Sleep(120 * time.Second)
		}
	}
}

func (c *collector) searchWindow(qbase, start, end string) ([]map[string]any, error) {
	q := fmt.Sprintf("%s created:%s..%s", qbase, start, end)
	probeRaw, err := c.gh("", "-X", "GET", "search/issues", "-f", "q="+q, "-f", "per_page=1")
	if err != nil {
		return nil, err
	}
	var probe struct {
		TotalCount int `json:"total_count"`
	}
	_ = json.Unmarshal(probeRaw, &probe)
	total := probe.TotalCount
	if total == 0 {
		return nil, nil
	}
	if total > 1000 {
		sdate, _ := time.Parse("2006-01-02", start)
		edate, _ := time.Parse("2006-01-02", end)
		if int(edate.Sub(sdate).Hours()/24) >= 2 {
			mid := sdate.Add(edate.Sub(sdate) / 2).UTC()
			mids := mid.Format("2006-01-02")
			fmt.Printf("  split %s..%s (%d hits) at %s\n", start, end, total, mids)
			left, err := c.searchWindow(qbase, start, mids)
			if err != nil {
				return nil, err
			}
			right, err := c.searchWindow(qbase, mids, end)
			if err != nil {
				return nil, err
			}
			return append(left, right...), nil
		}
		fmt.Printf("  WARNING: %d hits in tiny window %s..%s; taking first 1000\n", total, start, end)
	}
	time.Sleep(2100 * time.Millisecond)
	var found []map[string]any
	for page := 1; page <= 10; page++ {
		dataRaw, err := c.gh("", "-X", "GET", "search/issues", "-f", "q="+q,
			"-f", "per_page=100", "-f", fmt.Sprintf("page=%d", page))
		if err != nil {
			return nil, err
		}
		var data struct {
			Items []map[string]any `json:"items"`
		}
		if json.Unmarshal(dataRaw, &data) != nil {
			break
		}
		found = append(found, data.Items...)
		if len(data.Items) < 100 {
			break
		}
		time.Sleep(2100 * time.Millisecond)
	}
	return found, nil
}

var repoPrefix = "https://api.github.com/repos/"

func normalizeItem(raw map[string]any) ghItem {
	repoURL, _ := raw["repository_url"].(string)
	it := ghItem{
		Repo:     strings.TrimPrefix(repoURL, repoPrefix),
		Title:    str(raw, "title"),
		Body:     str(raw, "body"),
		Created:  str(raw, "created_at"),
		Updated:  str(raw, "updated_at"),
		State:    str(raw, "state"),
		IsPR:     raw["pull_request"] != nil,
		Author:   "?",
		Authored: false,
	}
	if raw["number"] != nil {
		if f, ok := raw["number"].(float64); ok {
			it.Number = int(f)
		}
	}
	if u, ok := raw["user"].(map[string]any); ok {
		if l := str(u, "login"); l != "" {
			it.Author = l
		}
	}
	if r, ok := raw["reactions"].(map[string]any); ok {
		it.Reactions = intOf(r["total_count"])
	}
	it.CommentsTotal = intOf(raw["comments"])
	it.URL = str(raw, "html_url")
	it.NodeID = str(raw, "node_id")
	return it
}

func str(m map[string]any, key string) string {
	s, _ := m[key].(string)
	return s
}

func intOf(v any) int {
	f, _ := v.(float64)
	return int(f)
}

func (c *collector) merge(raw map[string]any, authored, commented bool) {
	item := normalizeItem(raw)
	if prev, ok := c.items[item.URL]; ok {
		prev.Authored = prev.Authored || authored
		prev.Commented = prev.Commented || commented
		return
	}
	stored := item
	stored.Authored = authored
	stored.Commented = commented
	c.items[item.URL] = &stored
	c.itemOrder = append(c.itemOrder, item.URL)
}

func (c *collector) discover(yearStart int) error {
	nowYear := time.Now().UTC().Year()
	var windows [][2]string
	for y := yearStart; y <= nowYear; y++ {
		windows = append(windows, [2]string{fmt.Sprintf("%d-01-01", y), fmt.Sprintf("%d-01-01", y+1)})
	}
	queries := []struct {
		qbase               string
		authored, commented bool
	}{
		{fmt.Sprintf("author:%s is:issue", c.user), true, false},
		{fmt.Sprintf("author:%s is:pr", c.user), true, false},
		{fmt.Sprintf("commenter:%s -author:%s", c.user, c.user), false, true},
		{fmt.Sprintf("author:%s commenter:%s", c.user, c.user), true, true},
	}
	for _, q := range queries {
		fmt.Printf("[discover] %s\n", q.qbase)
		for _, w := range windows {
			found, err := c.searchWindow(q.qbase, w[0], w[1])
			if err != nil {
				return err
			}
			for _, raw := range found {
				c.merge(raw, q.authored, q.commented)
			}
		}
		fmt.Printf("  total unique items: %d\n", len(c.items))
	}
	return nil
}

func (c *collector) ownRepo(repo string) bool {
	parts := strings.SplitN(repo, "/", 2)
	return c.ownOwners[parts[0]]
}

func agentSuspect(body string) bool {
	runes := []rune(body)
	head := body
	if len(runes) > 800 {
		head = string(runes[:800])
	}
	markers := []string{
		"Task ID:", "Impact Score", "**Phase:**", "ISSUE TYPE", "Priority: 🔥",
		"TECHNICAL DEBT:", "## 🚨", "### 🎯", "- **Effort", "**Effort:**",
	}
	hits := 0
	for _, m := range markers {
		if strings.Contains(head, m) {
			hits++
		}
	}
	return hits >= 2
}

func (c *collector) paginate(path string) ([]map[string]any, error) {
	var out []map[string]any
	for page := 1; page <= 20; page++ {
		dataRaw, err := c.gh("", fmt.Sprintf("%s?per_page=100&page=%d", path, page))
		if err != nil {
			return nil, err
		}
		var data []map[string]any
		if json.Unmarshal(dataRaw, &data) != nil {
			break
		}
		out = append(out, data...)
		if len(data) < 100 {
			break
		}
		c.restCheckBudget()
	}
	return out, nil
}

func (c *collector) hydrateItem(item *ghItem) error {
	comments, err := c.paginate(fmt.Sprintf("repos/%s/issues/%d/comments", item.Repo, item.Number))
	if err != nil {
		return err
	}
	for _, cm := range comments {
		user, _ := cm["user"].(map[string]any)
		if str(user, "login") != c.user {
			continue
		}
		if strings.TrimSpace(str(cm, "body")) == "" {
			continue
		}
		c.comments = append(c.comments, &ghComment{
			Kind:      "comment",
			NodeID:    str(cm, "node_id"),
			HTMLURL:   str(cm, "html_url"),
			Body:      str(cm, "body"),
			Created:   str(cm, "created_at"),
			Reactions: reactionsOf(cm),
			Parent:    item,
		})
	}
	if !item.IsPR {
		return nil
	}
	reviews, err := c.paginate(fmt.Sprintf("repos/%s/pulls/%d/reviews", item.Repo, item.Number))
	if err != nil {
		return err
	}
	for _, r := range reviews {
		user, _ := r["user"].(map[string]any)
		if str(user, "login") != c.user {
			continue
		}
		if strings.TrimSpace(str(r, "body")) == "" {
			continue
		}
		created := str(r, "submitted_at")
		if created == "" {
			created = str(r, "created_at")
		}
		c.comments = append(c.comments, &ghComment{
			Kind:        "review",
			NodeID:      str(r, "node_id"),
			HTMLURL:     str(r, "html_url"),
			Body:        str(r, "body"),
			Created:     created,
			ReviewState: str(r, "state"),
			Parent:      item,
		})
	}
	inline, err := c.paginate(fmt.Sprintf("repos/%s/pulls/%d/comments", item.Repo, item.Number))
	if err != nil {
		return err
	}
	for _, cm := range inline {
		user, _ := cm["user"].(map[string]any)
		if str(user, "login") != c.user {
			continue
		}
		if strings.TrimSpace(str(cm, "body")) == "" {
			continue
		}
		c.comments = append(c.comments, &ghComment{
			Kind:      "review-inline",
			NodeID:    str(cm, "node_id"),
			HTMLURL:   str(cm, "html_url"),
			Body:      str(cm, "body"),
			Created:   str(cm, "created_at"),
			Reactions: reactionsOf(cm),
			Parent:    item,
		})
	}
	return nil
}

func reactionsOf(m map[string]any) int {
	r, _ := m["reactions"].(map[string]any)
	if r == nil {
		return 0
	}
	return intOf(r["total_count"])
}

func (c *collector) hydrate() error {
	var commentedOther, authComm []*ghItem
	for _, url := range c.itemOrder {
		i := c.items[url]
		if i.Commented && !i.Authored {
			commentedOther = append(commentedOther, i)
		}
		if i.Commented && i.Authored {
			authComm = append(authComm, i)
		}
	}
	var extFollowup, ownFollowup []*ghItem
	for _, i := range authComm {
		if !c.ownRepo(i.Repo) {
			extFollowup = append(extFollowup, i)
		} else {
			ownFollowup = append(ownFollowup, i)
		}
	}
	sort.Slice(ownFollowup, func(a, b int) bool { return ownFollowup[a].Updated > ownFollowup[b].Updated })
	if len(ownFollowup) > c.ownFollowupSample {
		ownFollowup = ownFollowup[:c.ownFollowupSample]
	}
	ownFollowupRepos := map[string]bool{}
	for _, i := range ownFollowup {
		ownFollowupRepos[i.Repo] = true
	}
	var authoredPRs []*ghItem
	for _, url := range c.itemOrder {
		i := c.items[url]
		if i.Authored && i.IsPR && !i.Commented && !ownFollowupRepos[i.Repo] {
			authoredPRs = append(authoredPRs, i)
		}
	}
	seen := map[string]bool{}
	var plan []*ghItem
	for _, i := range commentedOther {
		plan = append(plan, i)
	}
	plan = append(plan, extFollowup...)
	plan = append(plan, ownFollowup...)
	plan = append(plan, authoredPRs...)
	deduped := plan[:0]
	for _, i := range plan {
		if !seen[i.URL] {
			seen[i.URL] = true
			deduped = append(deduped, i)
		}
	}
	fmt.Printf("[hydrate] %d items (threads-by-others %d, ext-followup %d, own-followup %d, authored-pr %d)\n",
		len(deduped), len(commentedOther), len(extFollowup), len(ownFollowup), len(authoredPRs))
	for n, item := range deduped {
		if n > 0 && n%100 == 0 {
			fmt.Printf("  %d/%d (%d comments so far)\n", n, len(deduped), len(c.comments))
		}
		if err := c.hydrateItem(item); err != nil {
			msg := err.Error()
			if len(msg) > 120 {
				msg = msg[:120]
			}
			fmt.Printf("  SKIP %s: %s\n", item.URL, msg)
		}
		c.restCheckBudget()
	}
	return nil
}

func (c *collector) fetchEdits() error {
	var extBodies, ownBodies []*ghItem
	for _, url := range c.itemOrder {
		i := c.items[url]
		if !i.Authored {
			continue
		}
		if c.ownRepo(i.Repo) {
			ownBodies = append(ownBodies, i)
		} else {
			extBodies = append(extBodies, i)
		}
	}
	sort.Slice(ownBodies, func(a, b int) bool { return ownBodies[a].Updated > ownBodies[b].Updated })
	if len(ownBodies) > c.ownEditBodies {
		ownBodies = ownBodies[:c.ownEditBodies]
	}
	bodies := append(append([]*ghItem(nil), extBodies...), ownBodies...)
	var comments []*ghComment
	for _, cm := range c.comments {
		if cm.Kind == "comment" || cm.Kind == "review" {
			comments = append(comments, cm)
		}
	}
	node2url := map[string]string{}
	for _, i := range bodies {
		node2url[i.NodeID] = i.URL
	}
	for _, cm := range comments {
		node2url[cm.NodeID] = cm.HTMLURL
	}
	var checkIDs []string
	for id := range node2url {
		checkIDs = append(checkIDs, id)
	}
	sort.Strings(checkIDs)
	fmt.Printf("[edits] checking %d nodes (%d bodies, %d comments)\n", len(checkIDs), len(bodies), len(comments))

	var editedIDs []string
	for n := 0; n < len(checkIDs); n += 50 {
		end := n + 50
		if end > len(checkIDs) {
			end = len(checkIDs)
		}
		data, err := c.graphql(glCostQuery, checkIDs[n:end], 1)
		if err != nil {
			return err
		}
		nodes, _ := data["nodes"].([]any)
		for _, nv := range nodes {
			node, _ := nv.(map[string]any)
			if node == nil {
				continue
			}
			conn, _ := node["userContentEdits"].(map[string]any)
			if conn == nil || intOf(conn["totalCount"]) <= 0 {
				continue
			}
			url := str(node, "url")
			editedIDs = append(editedIDs, url)
			c.edits[url] = &editInfo{EditCount: intOf(conn["totalCount"])}
			c.editOrder = append(c.editOrder, url)
		}
		if n > 0 && n%500 == 0 {
			fmt.Printf("  checked %d/%d, %d edited\n", n, len(checkIDs), len(editedIDs))
		}
	}
	fmt.Printf("[edits] %d items have edits; fetching diffs\n", len(editedIDs))
	url2node := map[string]string{}
	for id, u := range node2url {
		url2node[u] = id
	}
	for n := 0; n < len(editedIDs); n += 25 {
		end := n + 25
		if end > len(editedIDs) {
			end = len(editedIDs)
		}
		var ids []string
		for _, u := range editedIDs[n:end] {
			if id, ok := url2node[u]; ok {
				ids = append(ids, id)
			}
		}
		if len(ids) == 0 {
			continue
		}
		data, err := c.graphql(glDiffQuery, ids, 10)
		if err != nil {
			return err
		}
		nodes, _ := data["nodes"].([]any)
		for _, nv := range nodes {
			node, _ := nv.(map[string]any)
			if node == nil {
				continue
			}
			conn, _ := node["userContentEdits"].(map[string]any)
			if conn == nil {
				continue
			}
			info, ok := c.edits[str(node, "url")]
			if !ok {
				continue
			}
			var versions []editVersion
			nodesList, _ := conn["nodes"].([]any)
			for _, vn := range nodesList {
				v, _ := vn.(map[string]any)
				if v == nil {
					continue
				}
				versions = append(versions, editVersion{EditedAt: str(v, "editedAt"), Diff: str(v, "diff")})
			}
			sort.Slice(versions, func(i, j int) bool { return versions[i].EditedAt < versions[j].EditedAt })
			info.Versions = versions
			info.Truncated = intOf(conn["totalCount"]) > 10
		}
	}
	return nil
}

func jsonMarshal(v any) ([]byte, error) {
	var b strings.Builder
	enc := json.NewEncoder(&b)
	enc.SetEscapeHTML(false)
	enc.SetIndent("", " ")
	if err := enc.Encode(v); err != nil {
		return nil, err
	}
	return []byte(strings.TrimSuffix(b.String(), "\n")), nil
}

func (c *collector) saveJSON(name string, v any) error {
	data, err := jsonMarshal(v)
	if err != nil {
		return err
	}
	return os.WriteFile(filepath.Join(c.out, "raw", name), data, 0o644)
}

func (c *collector) loadItems() error {
	raw, err := os.ReadFile(filepath.Join(c.out, "raw", "items.json"))
	if err != nil {
		return err
	}
	var items []*ghItem
	if err := json.Unmarshal(raw, &items); err != nil {
		return err
	}
	for _, i := range items {
		c.items[i.URL] = i
		c.itemOrder = append(c.itemOrder, i.URL)
	}
	return nil
}

func (c *collector) loadComments() error {
	raw, err := os.ReadFile(filepath.Join(c.out, "raw", "comments.json"))
	if err != nil {
		return err
	}
	var data []*ghComment
	if err := json.Unmarshal(raw, &data); err != nil {
		return err
	}
	for _, cm := range data {
		if parent, ok := c.items[cm.ParentURL]; ok {
			cm.Parent = parent
		}
		c.comments = append(c.comments, cm)
	}
	return nil
}

func (c *collector) render() error {
	for _, sub := range []string{"bodies", "comments"} {
		if err := os.MkdirAll(filepath.Join(c.out, "markdown", sub), 0o755); err != nil {
			return err
		}
	}
	for _, url := range c.itemOrder {
		i := c.items[url]
		if !i.Authored {
			continue
		}
		slug := strings.ReplaceAll(i.Repo, "/", "--") + fmt.Sprintf("--%d", i.Number)
		kind := "body-issue"
		if i.IsPR {
			kind = "body-pr"
		}
		front := []string{
			"kind: " + kind,
			"repo: " + i.Repo,
			fmt.Sprintf("own_repo: %v", c.ownRepo(i.Repo)),
			"url: " + i.URL,
			"title: " + pyJSONString(i.Title),
			"created: " + i.Created,
			fmt.Sprintf("reactions: %d", i.Reactions),
			fmt.Sprintf("agent_suspect: %v", agentSuspect(i.Body)),
		}
		if edit, ok := c.edits[i.URL]; ok {
			front = append(front, fmt.Sprintf("edits: %d", edit.EditCount))
		}
		text := "---\n" + strings.Join(front, "\n") + "\n---\n\n"
		text += fmt.Sprintf("# %s\n\n%s\n", i.Title, i.Body)
		if edit, ok := c.edits[i.URL]; ok {
			if len(edit.Versions) > 0 {
				text += "\n## Revisions\n\n"
				for _, v := range edit.Versions {
					text += fmt.Sprintf("### edited %s\n```diff\n%s\n```\n", v.EditedAt, v.Diff)
				}
			}
		}
		if err := os.WriteFile(filepath.Join(c.out, "markdown", "bodies", slug+".md"), []byte(text), 0o644); err != nil {
			return err
		}
	}
	for _, cm := range c.comments {
		p := cm.Parent
		if p == nil {
			continue
		}
		slug := strings.ReplaceAll(p.Repo, "/", "--") + fmt.Sprintf("--%d--%s", p.Number, lastN(cm.NodeID, 10))
		front := []string{
			"kind: " + cm.Kind,
			"repo: " + p.Repo,
			fmt.Sprintf("own_repo: %v", c.ownRepo(p.Repo)),
			fmt.Sprintf("item: %d", p.Number),
			"item_title: " + pyJSONString(p.Title),
			"item_author: " + p.Author,
			"url: " + cm.HTMLURL,
			"created: " + cm.Created,
			fmt.Sprintf("reactions: %d", cm.Reactions),
		}
		if cm.Kind == "review" {
			front = append(front, "review_state: "+cm.ReviewState)
		}
		if edit, ok := c.edits[cm.HTMLURL]; ok {
			front = append(front, fmt.Sprintf("edits: %d", edit.EditCount))
		}
		context := strings.ReplaceAll(truncate(p.Body, 400), "\n", " ")
		text := "---\n" + strings.Join(front, "\n") + "\n---\n\n"
		text += fmt.Sprintf("> On **%s** (by %s):\n> %s\n\n---\n\n%s\n", p.Title, p.Author, context, cm.Body)
		if edit, ok := c.edits[cm.HTMLURL]; ok && len(edit.Versions) > 0 {
			text += "\n## Revisions\n\n"
			for _, v := range edit.Versions {
				text += fmt.Sprintf("### edited %s\n```diff\n%s\n```\n", v.EditedAt, v.Diff)
			}
		}
		if err := os.WriteFile(filepath.Join(c.out, "markdown", "comments", slug+".md"), []byte(text), 0o644); err != nil {
			return err
		}
	}
	return nil
}

func lastN(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[len(s)-n:]
}

func truncate(s string, n int) string {
	runes := []rune(s)
	if len(runes) > n {
		return string(runes[:n])
	}
	return s
}

// pyJSONString mirrors Python's json.dumps default (ensure_ascii=True):
// non-ASCII escapes to \uXXXX (surrogate pairs above BMP), quotes escape.
func pyJSONString(s string) string {
	var b strings.Builder
	b.WriteByte('"')
	for _, r := range s {
		switch r {
		case '"':
			b.WriteString("\\\"")
			continue
		case '\\':
			b.WriteString("\\\\")
			continue
		case '\n':
			b.WriteString("\\n")
			continue
		case '\r':
			b.WriteString("\\r")
			continue
		case '\t':
			b.WriteString("\\t")
			continue
		}
		if r < 0x20 {
			fmt.Fprintf(&b, "\\u%04x", r)
			continue
		}
		if r > 0x7e {
			if r > 0xffff {
				r -= 0x10000
				hi := 0xd800 + (r >> 10)
				lo := 0xdc00 + (r & 0x3ff)
				fmt.Fprintf(&b, "\\u%04x\\u%04x", hi, lo)
			} else {
				fmt.Fprintf(&b, "\\u%04x", r)
			}
			continue
		}
		b.WriteRune(r)
	}
	b.WriteByte('"')
	return b.String()
}

type summary struct {
	Generated               string          `json:"generated"`
	User                    string          `json:"user"`
	ItemsTotal              int             `json:"items_total"`
	BodiesAuthored          int             `json:"bodies_authored"`
	BodiesAuthoredIssue     int             `json:"bodies_authored_issue"`
	BodiesAuthoredPR        int             `json:"bodies_authored_pr"`
	BodiesExternal          int             `json:"bodies_external"`
	AgentSuspectBodies      int             `json:"agent_suspect_bodies"`
	ThreadsCommentedNotAuth int             `json:"threads_commented_not_authored"`
	Comments                int             `json:"comments"`
	CommentsByKind          json.RawMessage `json:"comments_by_kind"`
	CommentsExternalRepo    int             `json:"comments_external_repo"`
	ItemsWithEdits          int             `json:"items_with_edits"`
	RestCalls               int             `json:"rest_calls"`
	GraphqlCalls            int             `json:"graphql_calls"`
	TopReposBodies          json.RawMessage `json:"top_repos_bodies"`
	TopReposComments        json.RawMessage `json:"top_repos_comments"`

	kindCounts map[string]int
	KindOrder  []string
}

// orderedCountJSON renders {key: count} with Python-dict semantics:
// mostCommon sorts count desc (stable by first appearance), otherwise
// first-appearance order.
func orderedCountJSON(order []string, counts map[string]int, mostCommon bool) json.RawMessage {
	type kv struct {
		k string
		v int
	}
	entries := make([]kv, 0, len(order))
	for _, k := range order {
		entries = append(entries, kv{k, counts[k]})
	}
	if mostCommon {
		sort.SliceStable(entries, func(i, j int) bool { return entries[i].v > entries[j].v })
	}
	var b strings.Builder
	b.WriteString("{")
	for i, e := range entries {
		if i > 0 {
			b.WriteString(", ")
		}
		b.WriteString(fmt.Sprintf("%q: %d", e.k, e.v))
	}
	b.WriteString("}")
	return json.RawMessage(b.String())
}

func (c *collector) summary() summary {
	s := summary{
		Generated:  time.Now().UTC().Format("2006-01-02T15:04:05.000000-07:00"),
		User:       c.user,
		ItemsTotal: len(c.items),
		kindCounts: map[string]int{},
	}
	repoBodyCounts := map[string]int{}
	repoCommentCounts := map[string]int{}
	var repoBodyOrder, repoCommentOrder []string
	for _, url := range c.itemOrder {
		i := c.items[url]
		if !i.Authored {
			if i.Commented {
				s.ThreadsCommentedNotAuth++
			}
			continue
		}
		s.BodiesAuthored++
		if i.IsPR {
			s.BodiesAuthoredPR++
		} else {
			s.BodiesAuthoredIssue++
		}
		if !c.ownRepo(i.Repo) {
			s.BodiesExternal++
		}
		if agentSuspect(i.Body) {
			s.AgentSuspectBodies++
		}
		if _, seen := repoBodyCounts[i.Repo]; !seen {
			repoBodyOrder = append(repoBodyOrder, i.Repo)
		}
		repoBodyCounts[i.Repo]++
	}
	s.KindOrder = nil
	for _, cm := range c.comments {
		s.Comments++
		if _, seen := s.kindCounts[cm.Kind]; !seen {
			s.KindOrder = append(s.KindOrder, cm.Kind)
		}
		s.kindCounts[cm.Kind]++
		if cm.Parent != nil && !c.ownRepo(cm.Parent.Repo) {
			s.CommentsExternalRepo++
		}
		if cm.Parent != nil {
			if _, seen := repoCommentCounts[cm.Parent.Repo]; !seen {
				repoCommentOrder = append(repoCommentOrder, cm.Parent.Repo)
			}
			repoCommentCounts[cm.Parent.Repo]++
		}
	}
	s.ItemsWithEdits = len(c.edits)
	s.RestCalls = c.restCalls
	s.GraphqlCalls = c.glCalls
	if len(repoBodyOrder) > 15 {
		repoBodyOrder = repoBodyOrder[:15]
	}
	if len(repoCommentOrder) > 15 {
		repoCommentOrder = repoCommentOrder[:15]
	}
	s.TopReposBodies = orderedCountJSON(repoBodyOrder, repoBodyCounts, true)
	s.TopReposComments = orderedCountJSON(repoCommentOrder, repoCommentCounts, true)
	s.CommentsByKind = orderedCountJSON(s.KindOrder, s.kindCounts, false)
	return s
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

func main() {
	user := flag.String("user", "LarsArtmann", "GitHub user")
	out := flag.String("out", "~/.cache/github-voice-corpus", "output directory")
	ownOwners := flag.String("own-owners", "LarsArtmann,Artmann-Games", "comma-separated own owners")
	yearStart := flag.Int("year-start", 2016, "first year to search")
	ownFollowupSample := flag.Int("own-followup-sample", 1500, "own-repo follow-up threads to hydrate")
	ownEditBodies := flag.Int("own-edit-bodies", 800, "own-repo bodies to check for edits")
	skipDiscover := flag.Bool("skip-discover", false, "reload raw/items.json from a previous run")
	skipHydrate := flag.Bool("skip-hydrate", false, "reload raw/comments.json from a previous run")
	flag.Parse()

	dir, err := expandHome(*out)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if err := os.MkdirAll(filepath.Join(dir, "raw"), 0o755); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	owners := map[string]bool{}
	for _, o := range strings.Split(*ownOwners, ",") {
		owners[strings.TrimSpace(o)] = true
	}
	c := &collector{
		user:              *user,
		out:               dir,
		ownOwners:         owners,
		ownFollowupSample: *ownFollowupSample,
		ownEditBodies:     *ownEditBodies,
		items:             map[string]*ghItem{},
		edits:             map[string]*editInfo{},
	}
	t0 := time.Now()
	if *skipDiscover {
		if err := c.loadItems(); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		fmt.Printf("[resume] loaded %d items\n", len(c.items))
	} else {
		if err := c.discover(*yearStart); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		items := make([]*ghItem, 0, len(c.itemOrder))
		for _, url := range c.itemOrder {
			items = append(items, c.items[url])
		}
		if err := c.saveJSON("items.json", items); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		fmt.Printf("[done-discover] %d items (%.0fs)\n", len(c.items), time.Since(t0).Seconds())
	}
	if *skipHydrate {
		if err := c.loadComments(); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		fmt.Printf("[resume] loaded %d comments\n", len(c.comments))
	} else {
		if err := c.hydrate(); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		save := make([]*ghComment, 0, len(c.comments))
		for _, cm := range c.comments {
			saved := *cm
			saved.Parent = nil
			if cm.Parent != nil {
				saved.ParentURL = cm.Parent.URL
			}
			save = append(save, &saved)
		}
		if err := c.saveJSON("comments.json", save); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		fmt.Printf("[done-hydrate] %d comments (%.0fs)\n", len(c.comments), time.Since(t0).Seconds())
	}
	if err := c.fetchEdits(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if err := c.saveJSON("edits.json", c.edits); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if err := c.render(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	stats := c.summary()
	statsJSON, err := jsonMarshal(stats)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if err := os.WriteFile(filepath.Join(dir, "summary.json"), statsJSON, 0o644); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(string(statsJSON))
	fmt.Printf("[done] corpus at %s (%.0fs)\n", dir, time.Since(t0).Seconds())
}
