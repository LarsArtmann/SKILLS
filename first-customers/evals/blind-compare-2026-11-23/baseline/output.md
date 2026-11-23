# baseline arm output (fresh subagent, NO skill access — general knowledge)

> Persisted 2026-11-23 from the blind-compare run (see ../comparator.md).

Diagnosis: distribution problem before product problem — funnel math says
zero sales at that traffic is expected (good pages convert 1-3%); three
stacked problems: no audience/capture, unclear Pro value ("if you can't
finish 'You pay $19 because Pro does ___', the buyer can't either"; the
real alternatives are dupl, jscpd, or doing nothing — all free), and $19
one-time priced between two buyers (solo dev without $19 of pain vs tech
lead with thousands — "you're pricing between two buyers and getting
neither"). "10 x $19 = $190: the first 10 customers are 10 proofs someone
values this — you hand-sell, you don't funnel-sell."

Research: profile the 40 stargazers/forks/issue-filers (issue filers =
warmest leads); interview 10-15 Go devs with Mom-test rules ("ask about the
LAST time duplicate code hurt, what it cost"); study how adjacent tools
monetize (SonarQube free-CE/paid-team, Semgrep OSS/paid-CI, golangci-lint
sponsor-funded) — "nobody pays for the detector; they pay for the workflow
around it" (PR comments, dashboards, baselines, team reports); instrument
Gumroad/GitHub traffic/module-proxy pulls.

Positioning: narrow the buyer (tech leads on large/legacy Go codebases, or
consultants selling audits); lead with the semantic differentiator concretely
("text-based tools miss duplicates the moment someone renames a variable")
and PROVE it: plant known duplicates, publish a catch-rate table (godup
47/50, dupl 21/50) — "a benchmark table is the most persuasive thing a
static-analysis tool can publish"; sell the outcome (quantifiable tech
debt), not the scan.

Offer: restructure away from $19 Pro — (1) free CLI + team tier $99-$299
for CI: PR comments, baseline/diff mode ("only flag NEW duplication — this
alone kills the noise objection"), HTML trend reports; (2) done-for-you
audit $499+ (fastest honest path to first revenue); (3) dual licensing
(n8n model — forces conversion, chills OSS goodwill). Plus comparison
table, 30-second GIF, email capture with a lead magnet.

Channels: (1) direct outreach first — stargazer emails as conversations not
pitches, convert to design partners; (2) proof-of-work content — scan
famous Go repos, publish findings, Show HN/r/golang/Lobsters/GophersSlack
("single best content format available"); (3) ride existing distribution —
golangci-lint plugin + GitHub Action Marketplace; (4) audit-partner channel
via consultancies.

Next actions: week 1 fix the storefront (one-sentence value prop, rewrite
Gumroad + README, landing page + lead magnet, 30 warm leads); week 2 talk
to humans (15 outreach emails -> 5 conversations; ship the famous-repos
post); weeks 3-4 sell manually (re-scope paid tier from interviews; offer
the $499 audit to the warmest 5; take any deal shape; ask "what almost
stopped you from buying?"). Decision gate: ~30 qualified conversations with
no willingness to pay for anything -> demand problem -> "a great portfolio/
OSS-sponsorship project rather than a business — better to know in six
weeks than a year."
