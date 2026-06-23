# First-Week Content Depth / Term / Drill Coverage Audit v1

- Date: 2026-06-23
- Origin main: `50f094f1ca69a9b57ddfeb1e9c9a596c2c690a54`
- Status: `documented_content_depth_audit_only`

## Scope / non-scope

This is an audit-only follow-up to the accepted first-week learning proof
packet. It checks whether the current first-week and near-premium route has
enough authored depth, term safety, drill repetition, and repair credibility for
product/design/commercial review.

No product code, UI, copy, routes, telemetry, Modern Table, content/glossary,
screenshot tooling, monetization, AI/persona, dashboard/XP/economy, tests, or
generated outputs changed in this wave.

## Method

Inspected:

- `docs/_reviews/first_week_learning_proof_packet_v1.md`
- `docs/_reviews/content_depth_term_drill_coverage_audit_v1.md`
- `docs/_reviews/term_introduction_glossary_safety_fix_v1.md`
- `docs/_reviews/same_signal_drill_expansion_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_agent_context/change_type_matrix_evidence_budget_v1.md`
- `docs/_agent_context/baseline_failure_ledger_v1.md`
- `content/world1_act0_table_literacy/v1/`
- `content/world1_act0_action_literacy/v1/`
- `content/world1_act0_street_flow/v1/`
- `content/worlds/world5/v1/sessions/w5.s01/`
- `content/worlds/world6/v1/sessions/w6.s01/`
- active Act0 runtime copy seams under `lib/ui_v2/act0_shell/`

Evidence commands:

```bash
python3 - <<'PY'
import json, pathlib
paths = [
 ('act0_table', pathlib.Path('content/world1_act0_table_literacy/v1/drills.jsonl')),
 ('act0_actions', pathlib.Path('content/world1_act0_action_literacy/v1/drills.jsonl')),
 ('act0_streets', pathlib.Path('content/world1_act0_street_flow/v1/drills.jsonl')),
]
for name,p in paths:
    rows=[json.loads(line) for line in p.read_text().splitlines() if line.strip()]
    print(name, 'drills', len(rows), 'with explanation', sum(bool(r.get('explanation')) for r in rows), 'with insightText', sum(bool(r.get('insightText')) for r in rows))
for sess in ['content/worlds/world5/v1/sessions/w5.s01','content/worlds/world6/v1/sessions/w6.s01']:
    files=sorted(pathlib.Path(sess,'drills').glob('d.*.json'))
    print(sess, 'drills', len(files))
    kinds={}; why=fb=0
    for f in files:
        d=json.loads(f.read_text())
        kinds[d.get('kind')]=kinds.get(d.get('kind'),0)+1
        why += bool(d.get('why_v1'))
        fb += bool(d.get('feedback_correct_v1') or d.get('feedback_incorrect_v1'))
    print(' kinds', kinds, 'why', why, 'feedback', fb)
PY
dart run tools/term_coverage_scanner.dart
dart run tools/unknown_uppercase_scanner.dart
```

Observed:

- Act0 table literacy: 6 drills, all with `explanation` and `insightText`.
- Act0 action literacy: 3 drills, all with `explanation` and `insightText`.
- Act0 street flow: 3 drills, all with `explanation` and `insightText`.
- W5 s01: 3 `board_texture_classifier_v1` drills, all with `why_v1` and
  feedback.
- W6 s01: 14 drills total, including 6 `range_bucket_classifier_v1` drills,
  all with `why_v1` and feedback.
- Term scanner: PASS across 1578 active learner session files for `EQUITY`,
  `PROBE`, `BLOCKERS`, `SPR`, `EV`, and `EXPLOIT`.
- Unknown uppercase scanner: only `PFA` and `DB`, both under
  `content/_reference/` and already quarantined as reference-only.

## First-week content path audited

The first-week proof path is currently:

`placement -> Welcome micro-win -> W1 decision -> feedback -> repair focus/result/session proof -> Review/Profile proof`

The authored content directly supporting the first open is compact:

- table anchors and seats;
- legal first actions;
- street order;
- one deterministic W1 action decision;
- repair and return proof supplied by the Act0 shell and queue seams.

This is enough to prove the learning loop. It is not enough by itself to prove
deep course breadth or W5+ paid-depth readiness.

## Findings table

| Area / concept | Classification | Evidence / source | Learner risk | Recommended action | Commercial priority |
| --- | --- | --- | --- | --- | --- |
| First-week table anchors | `safe_for_v1` | 6 Act0 table drills; theory expands Button, Small Blind, Big Blind | Low | Keep as proof anchor | Medium |
| First-week legal actions | `safe_for_v1_with_small_copy_fix` | 3 Act0 action drills; all have explanations | `toCall == 0` / `toCall > 0` is programmer-facing if surfaced | Replace with learner-facing wording in a tiny content-copy wave | High |
| First-week street flow | `safe_for_v1` | 3 Act0 street drills; compact theory | Thin repetition, but acceptable for first proof | Defer broader street coverage | Low |
| W5 board texture | `needs_more_drill_coverage` | W5 s01 has 3 board-texture classifier drills | Too thin for premium-depth proof | Add 3-5 same-signal board-texture reps before using W5 as commercial depth proof | High |
| W6 range bucket | `safe_for_v1_after_recent_expansion` | W6 s01 has 6 range-bucket classifiers and 14 total drills | Still one session slice, but credible same-family proof | Keep; do not expand again until W5 catches up | Medium |
| Priority term safety | `safe_for_v1` | Term scanner PASS for six priority terms | Low for audited active terms | Keep scanner as gate | High |
| PFA / DB | `reference_only_quarantined` | Unknown scanner finds only `content/_reference/` usage | None in active learner path | Do not define until active ownership is proven | Low |
| W6 drill index residue | `small_copy_cleanup_candidate` | `content/worlds/world6/v1/sessions/w6.s01/drills/index.md` still contains future/TODO-like entries | Could confuse human commercial/content reviewers if read directly | Clean or mark non-surfaced index residue in a content-doc pass | Medium |
| Repair loop proof | `safe_for_v1` | first-week proof packet and W5/W6 queue seams | Queue resolution still deferred | Keep as mechanism proof; do not claim fully resolved repair lifecycle | High |

## Term introduction findings

The active scanner contract is in good shape for the six priority
learner-facing terms:

- `EQUITY`
- `PROBE`
- `BLOCKERS`
- `SPR`
- `EV`
- `EXPLOIT`

The active-content scan passed. `PFA` and `DB` remain correctly quarantined as
reference-only because their observed uses are under `content/_reference/`.

The main first-week term issue is not scanner coverage. It is plain-language
quality: Act0 action theory still uses `toCall == 0` and `toCall > 0`. That is
technically clear to the system but not ideal learner-facing copy if surfaced.

## Concept depth findings

First-week proof depth is adequate for internal product/design/commercial
review because the route can show:

- one real table decision;
- immediate feedback;
- repair focus;
- repair result;
- session repair;
- Review/Profile proof.

The first-week authored source modules remain intentionally small. This is
acceptable for proof, but not for a broad content-depth claim.

The largest depth gap near the commercial route is W5 board texture. W5 s01 has
only three texture classifier reps. W6 range bucket is now stronger after the
same-signal expansion, so the next content-depth improvement should not expand
W6 again before W5 is brought up to a comparable same-signal floor.

## Drill coverage findings

- Act0 first-week modules: 12 total JSONL drills across table, action, and
  street literacy.
- W5 s01 board texture: 3 classifier drills.
- W6 s01 range bucket: 6 classifier drills and 14 total drills.

This creates a useful proof ladder:

`first-week foundation -> W5 board texture gap -> W6 range bucket stronger slice`

The main drill-coverage risk is unevenness. The product proof now makes repair
and recheck feel credible, but content depth is still thin in the W5 family most
likely to represent early paid-depth value.

## Feedback / repair copy findings

The inspected W5 and W6 drills include `why_v1` and feedback. The first-week
Act0 JSONL drills include explanation/insight fields. Current feedback and
repair proof are therefore not empty shell claims.

The commercial copy risk is overclaiming. The current evidence supports
deterministic repair proof and targeted recheck proof. It does not yet support a
claim that every important concept has broad same-signal repetition or a fully
resolved repair lifecycle.

## Runout comparison notes

Runout remains stronger as a packaged commercial artifact: breadth, polish,
subscription ceremony, and perceived ecosystem scale.

Sharky's current counter-position is narrower and stronger:

`choice -> table signal -> why -> repair -> recheck proof`

The next work should strengthen authored depth behind that proof rather than
copy Runout dashboards, paywall pressure, or broad feature packaging.

## Must-fix list before commercial review

1. Replace learner-facing `toCall == 0` / `toCall > 0` wording in Act0 action
   theory if that theory is part of the reviewed packet.
2. Clean or explicitly mark W6 s01 drill-index TODO/future residue before raw
   content docs are shared externally.
3. Expand W5 board-texture same-signal coverage with a small authored set before
   using W5 as a premium-depth proof point.
4. Keep term scanner green for the six priority terms after any content edits.
5. Keep the proof packet honest: it proves targeted repair and recheck launch,
   not complete queue resolution or mastery.

## Deferred list

- Queue clear / resolution policy.
- One-drill-only recheck result flow.
- Recheck-specific telemetry policy.
- Third repair family.
- Broad W7+ content/term audit.
- Broad glossary UI.
- Russian localization.
- Store-grade screenshot/contact-sheet polish.
- Monetization/paywall/trial work.
- Modern Table visual work.
- AI/persona/dashboard/XP/economy expansion.

## Recommended next wave

Run **W5 Board Texture Same-Signal Coverage v1** next.

Reason: W6 range bucket now has six same-family reps and deterministic repair
support. W5 board texture has only three classifier reps and is closer to the
future W5+ paid-depth boundary. Adding a small 3-5 drill authored board-texture
set would improve commercial trust without changing UI, routes, telemetry, or
monetization.

If the next review will inspect raw content files rather than product packets,
run a smaller `First-Week Content Copy / Index Cleanup v1` first to remove the
`toCall` wording and W6 index residue.

## Validation plan

Required for this docs-only audit:

- `graphify hook-check`
- `flutter analyze`
- `git diff --check`
- `git status --short`

No product tests or screenshot commands are required because this wave changes
only this audit note.
