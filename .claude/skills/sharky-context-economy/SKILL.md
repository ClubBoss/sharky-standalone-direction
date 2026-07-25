---
name: sharky-context-economy
description: Token-efficient working recipes for this repository - orientation order, evidence-run log filtering, targeted reads, graphify boundaries, and per-packet model routing. Use when starting a campaign packet, when about to read several authority documents, when about to run a broad test suite or inspect a large log, or when a session is spending heavily on orientation rather than work.
---

# Sharky Context Economy

Measured on 2026-07-25 across two full planning sessions. Every number here is
observed, not estimated from theory.

**Where the tokens actually went:** orientation (~50K), not work. The same facts
("F-16 closed", "Modern Table in Maintenance Mode") were read 4-5 times across
different authority documents, because each document restates history.

## 1. Orientation order

1. `docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md` — one screen; canonical HEAD, umbrella stage, active packet, finding statuses, what is authorized.
2. The packet definition in `docs/plan/PRE_HUMAN_AND_HUMAN_PROVEN_CAMPAIGN_v1.md` — read **only** your packet's subsection plus §7 rows for your finding IDs.
3. Escalate to capsule / Master Plan / topology map **only** when the task needs authority the state file does not carry, or when its facts conflict with live source or tests.

Never read the authority stack "for context". If a fact matters, it belongs in
the state file — put it there instead of re-reading five documents next session.

**Supersession trap:** a `docs/_reviews/*.md` document can be fully superseded
and still read as authoritative — status is stated inside the prose, not in
metadata. Use `tools/docs_authority_index_v1.sh` to see status/date/verdict
lines across the corpus without opening files.

## 2. Evidence runs — never let a log into context

The full `test/ui_v2` + `test/guards` run produces a **2.6 MB** log. Extracted
correctly it costs about **1 KB**.

```bash
SCRATCH="$CLAUDE_SCRATCHPAD"   # or the session scratchpad path
LOG="$SCRATCH/broad_suite.log"

# run detached; never stream a big suite into the transcript
flutter test test/ui_v2 test/guards -r compact > "$LOG" 2>&1

# 1. headline counts
grep -oE '\+[0-9]+ ~?[0-9]* ?-[0-9]+:' "$LOG" | tail -1

# 2. compile failures are file-scoped
grep -c 'Failed to load' "$LOG"

# 3. assertion-failing files ONLY (exclude 'loading' reruns, which are compile failures)
grep -oE "dart test [^ ]+\.dart -p vm --plain-name '[^']*'" "$LOG" \
  | grep -v "plain-name 'loading" \
  | sed "s#.*/test/#test/#; s# -p vm.*##" | sort -u

# 4. one specific failure's detail, bounded
awk '/<test file>: <test name>/,/To run this test again/' "$LOG" | head -40
```

Critical decomposition rule: `flutter test`'s failure count mixes **compile
failures** (1 per file) with **assertion failures** (1 per test). Reporting the
raw total as "defects" is wrong. Split them before drawing any conclusion — the
2026-07-25 measurement was 239 = 128 compile + 111 assertion, and a prior audit
had mis-attributed the same class as "238 compile + 12 canonical".

## 3. Reading recipes

| Instead of | Do | Saving observed |
| --- | --- | --- |
| `Read` an 81 KB plan | `sed -n '1,60p;120,200p'` on the sections you need | 81 KB → 15 KB |
| `Read` a diff | `git diff --numstat` / `--name-only`, then read only what matters | ~95% |
| `cat` a log | filter in bash, print ≤50 lines | 2.6 MB → 1 KB |
| `Read` 460 test files | `grep -l` for the marker, classify by path | ~100% |
| Sequential dependent calls | batch independent calls in one block | fewer turns |

Ask before every whole-file read: **which 40 lines answer the question?**

## 4. Graphify boundaries

Measured graph coverage: `lib/` 61,946 nodes · `docs/` 6,128 · **`test/` 22** ·
`tools/` 16.

- **Good for:** `lib/` ownership, consumers, symbol relationships. `graphify affected "<symbol>"` (reverse traversal) is the most under-used command.
- **Useless for:** "which test owns which contract", doc authority, contract ownership. Grep directly; do not spend a call proving it cannot answer.
- **Always check freshness:** `graphify-out/graph.json` carries `built_at_commit`. It was found **750 commits stale**, which silently produced junk results in two sessions. Compare to HEAD before trusting anything; run `graphify update .` or skip and say so.

```bash
python3 -c "import json;g=json.load(open('graphify-out/graph.json'));print(g.get('built_at_commit'))"
git rev-parse HEAD
```

## 5. Model routing per packet class

A precise DoD is what makes a cheaper model safe. Route on **decision content**,
never on packet size.

| Packet class | Model | Why |
| --- | --- | --- |
| Adjudication, contract verdicts, severity, causation, admission | top | a wrong verdict is expensive and propagates into closure claims |
| Bounded repair with an owner already named | mid | the decision is made; execution is bounded |
| Mechanical batch (file-by-file disposition, lane wiring, formatting, publication) | cheapest that follows the DoD | no judgement left in the work |

If a packet still needs a judgement call, it is not mechanical — do not route it
down.

## 6. Subagents

Default is **do not spawn** — a fresh agent re-derives the context this session
already paid for, so planning and authority work is cheaper inline.

The one genuine use is **fan-out reading where only the conclusion is needed**:
classify N files, return a table. Give it the exact label vocabulary and forbid
prose. Never use one for orientation, adjudication, or anything whose output you
must trust without re-checking.

## 7. Two-pass discipline (the biggest single win)

- **Pass 1** — read the minimum sufficient authority. Produce a provisional map plus an explicit list of *unresolved questions that would change packet existence, owner, order, severity, or evidence requirements*.
- **Pass 2** — verify **only** those questions against source, tests, or workflows.

Observed result: ~85% input saving, and it **removed three speculative packets**
(an F-16 repair, a W6 content wave, a Sharky-removal recovery) while the one
deliberately expensive check — the full suite — found the two findings that
document reading could never have found.

Spend the saving on the check that only execution can answer. That is the whole
trade: cheap on reading, expensive on measurement.
