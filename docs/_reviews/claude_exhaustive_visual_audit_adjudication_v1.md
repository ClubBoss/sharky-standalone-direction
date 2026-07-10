# Claude Exhaustive Visual Audit Adjudication / Canonical Repair Ledger v1

Status: source-inspection adjudication only. No product repair, capture, or route work was performed.

## 1. Terminal verdict

`docs_and_evidence_only__no_executable_visual_repair_admitted`.

The supplied C2 package is useful static-review input, but it cannot safely
admit its proposed combined Wave 1. Current source proves that its highest-EV
items span multiple owners and that several visible defects may be capture or
fixture-state artifacts. The safe next step is a narrow current-evidence packet,
then one owner-bounded implementation prompt. Human QA has not started and no
public, investor, product-readiness, or 10/10 claim is made here.

## 2. Main branch / head verified

| Check | Result |
| --- | --- |
| Branch | `main` |
| `HEAD` | `447cdefbc4f29ec786b0f30b5950584d368dac1f` |
| `origin/main` | `447cdefbc4f29ec786b0f30b5950584d368dac1f` |
| Relation | equal; expected baseline confirmed |
| Worktree | tracked-clean; only untracked `output/**` directories, preserved |

## 3. Inputs inspected

- Supplied external report: `/Users/elmarsalimzade/Downloads/SHARKY_EXHAUSTIVE_VISUAL_AUDIT_C2_v1.md`; external and deliberately not copied into the repository.
- Active source owners under `lib/ui_v2/act0_shell/`, `lib/ui_v2/runner/`, and `lib/campaign/`.
- Active route, visual-proof, and worktree/evidence capsules; the first two are older than current `main`, so live source and this task’s verified head govern where they differ.
- Scoped graph ownership (`graphify query`) and `graphify hook-check`.

## 4. Audit-quality assessment

Claude did well to retain lower-priority debt, separate unavailable evidence,
call out teaching-string damage, and avoid a redesign recommendation. It also
correctly treats mascot and motion as separately gated.

Its method still has material limits:

- The report conflates a static crop with a runtime defect in several scroll,
  sticky-header, and safe-area calls.
- It assigns a Worlds/progression score while declaring the World map/switch
  unavailable. That category is **NOT SCORED**.
- Its 72-item arithmetic is a declared deduplication, not a machine-auditable
  mapping from the 131 screen instances: aliases such as LR-A..G and repeated
  systemic instances are not enumerated as a reversible membership table.
- “One component-level fix” for SYS-01 and SYS-02 is not source-proven.
  Feedback clue pill, table context, flag callout, Home row, and terminal
  content are distinct consumers; table overlays use independent positioned
  layers.
- No native-device, interactive, motion, or fresh-current screenshot packet
  was supplied, so static findings cannot prove clipping, initial scroll offset,
  or notched-safe-area behavior.

## 5. Corrected current scorecard

The external **7.8/10** remains a report-derived static-evidence estimate only,
not a current-main certification. Corrected static scorecard: Entry/onboarding
7.5; Home 7.8; Learn 7.8; Learn detail 8.0; Practice 7.9; Review 8.0; Profile
7.7; W1 decision 7.9; late-route tables 7.7; feedback 8.0; repair result 8.2;
session closure 8.2; W12 payoff 7.8; No-W13 7.9; Sharky 5.5 (external gate);
motion **NOT SCORED**; Worlds/path-map/world-switch **NOT SCORED**; overall
static estimate **7.8 (external, unrefreshed)**.

This is not Human-QA, learning-effect, public, investor, or release readiness.

## 6. P1 adjudication

| External family | External P1 | Canonical severity | Status | Evidence / source owner | Next action |
| --- | --- | --- | --- | --- | --- |
| WF-01 / W1CF-01 / RR-01 / ORS-01 / LR-B / VT-01 | clipped clue/context strings | P1 if reproduced | NEEDS FRESH EVIDENCE | Runner feedback clue pill is `_FeedbackCluePillV1` in `act0_lesson_runner_shell_v1.dart`; table callout is separate `_TableRepairCalloutV1`; terminal text is source-owned pack/terminal data. | Capture longest current strings at supported phone widths, then split by owner. |
| HOM-02 / RH-01 | clipped Review row subtitle | P1 if reproduced | ACCEPT WITH MODIFIED SCOPE | `act0_home_shell_v1.dart` owns the full fallback string; row layout must be inspected separately. | One Home-row-only width/overflow audit; do not bundle with runner pills. |
| WH-01 | welcome handoff empty upper region | P1 candidate | NEEDS FRESH EVIDENCE | `act0_welcome_shell_v1.dart` owns the fixed handoff composition, but no current device capture proves a defect rather than intended envelope/capture position. | Tall + short current-main captures before layout work. |
| SS-01 | session-summary safe-area clipping | P1 candidate | NEEDS FRESH EVIDENCE | Runner uses a scrollable completion shell and `SafeArea(top: false)`/bottom padding path. Source does not prove runtime clipping. | Native notched-device top/bottom and initial-scroll captures; classify A–D below. |
| LR-A / SYS-07 | `1/4` scope | P1 comprehension candidate | NEEDS SOURCE VALIDATION | No global literal/owner was found; progress is composed from route/session data and runner presentation. | Trace each capture fixture to its world/task data before any semantic label change. |
| LR-C / SYS-02 | flag/context/table collisions | P1 if reproduced | NEEDS FRESH EVIDENCE | `_Act0TableV1` stacks seat, chip, center, repair, and late-route overlays with independent `Positioned` anchors. | Capture W8/W9/W12 at 320–430pt; map anchor rectangles and z-order. |
| NW13-01 | terminal hierarchy | P1 candidate | ACCEPT WITH MODIFIED SCOPE | `_TerminalCompletionPayoffV1` / `_WorldMilestoneCardV1` are dedicated terminal/milestone owners; registry copy explicitly says later worlds remain locked. | Terminal-only layout/copy wave after current capture proves hierarchy failure; no W13 route change. |

## 7. Full declared 72-item adjudication ledger

The external report declares 14 systemic + 58 unique-local items. This ledger
preserves that declared 72-item shape; each systemic row retains all repeated
screen instances (including late-route aliases) in its member note instead of
pretending they are separate root causes.

Legend: A = ACCEPT; AMS = ACCEPT WITH MODIFIED SCOPE; NSV = NEEDS SOURCE
VALIDATION; NFE = NEEDS FRESH EVIDENCE; D = DEFER; R = REJECT; S = ALREADY
CLOSED / STALE.

| # | ID | Canonical status | Canonical disposition |
| ---: | --- | --- | --- |
| 1 | SYS-01 | AMS | Repeated text risk, but multiple owners; split feedback pill, table context/callout, flag tooltip, Home row, terminal. |
| 2 | SYS-02 | NFE | Independent table stack exists; collision requires current-width proof. |
| 3 | SYS-03 | AMS | Repeated feedback wording is source-backed; preserve receipt/repair semantics. |
| 4 | SYS-04 | NSV | Clue naming has multiple source contracts; write no spec until data-owner trace. |
| 5 | SYS-05 | NFE | Visual-token judgment needs current evidence; no broad design-system wave admitted. |
| 6 | SYS-06 | D | Sharky identity remains externally gated. |
| 7 | SYS-07 | NSV | `1/4` meaning and data owner not yet isolated; no progression-semantic change. |
| 8 | SYS-08 | NFE | Card-back luminance is visual-only and needs current comparison capture. |
| 9 | SYS-09 | NFE | State distinction may be static/motion dependent; verify actual transition states. |
| 10 | SYS-10 | NSV | Some duplication is intentional proof redundancy; source/claim audit first. |
| 11 | SYS-11 | NFE | Scroll shell and safe-area logic exist; native evidence required to call clipping. |
| 12 | SYS-12 | D | Content/fixture variety is outside this paused visual-repair task. |
| 13 | SYS-13 | AMS | Session secondary actions have a bounded presentation owner; preserve navigation truth. |
| 14 | SYS-14 | AMS | Terminal has a dedicated milestone owner; terminal-only proof may justify a later bounded change. |
| 15 | PLC-01 | NFE | Static composition preference; validate short height. |
| 16 | PLC-03 | NSV | Copy hierarchy, not visual emergency. |
| 17 | PLC-04 | NSV | Verify localized variants and source copy contract. |
| 18 | PLC-05 | NFE | Width/layout evidence required. |
| 19 | WD-04 | NFE | Pressed state cannot be judged from static capture. |
| 20 | WD-05 | NSV | Copy editorial candidate only. |
| 21 | WH-01 | NFE | See P1 table; fixed-envelope versus capture position unresolved. |
| 22 | WH-03 | D | Depends on Sharky art-direction gate. |
| 23 | WH-05 | NSV | Editorial candidate. |
| 24 | HOM-01 | NFE | Sticky-header/initial-offset capture artifact remains plausible. |
| 25 | HOM-06 | NSV | Copy hierarchy candidate. |
| 26 | HOM-08 | NFE | Preference; no evidence of comprehension failure. |
| 27 | LRN-04 | NFE | Alignment needs current layout proof. |
| 28 | LRN-05 | NSV | Copy placement candidate. |
| 29 | LRN-06 | NSV | Numbering meaning is progression-owned. |
| 30 | LRN-07 | NFE | Token preference, not a regression. |
| 31 | LD-01 | NSV | Copy compression candidate. |
| 32 | LD-02 | S | Current source explicitly scrolls expanded detail into comfort when clipped; fresh capture can reopen only if it regresses. |
| 33 | LD-03 | NFE | Low-priority visual consistency. |
| 34 | LD-04 | NSV | Vocabulary normalization must follow source ownership. |
| 35 | PRA-01 | S | Source intentionally `.take(allTopicGroupsLocked ? 2 : 4)`; report’s four locked cards is stale/fixture-specific. |
| 36 | PRA-02 | NSV | Copy editorial candidate. |
| 37 | PRA-05 | NFE | Preference only. |
| 38 | RE-01 | NFE | Static visual-weight judgment. |
| 39 | RE-02 | NSV | Copy/component intent needs source review. |
| 40 | RE-04 | NSV | Copy duplication candidate. |
| 41 | REV-03 | NSV | Review-copy reduction must preserve repair receipt semantics. |
| 42 | REV-04 | NFE | Accent preference. |
| 43 | REV-05 | NFE | Single-item scroll composition needs current capture. |
| 44 | PRO-01 | NFE | Current capture needed. |
| 45 | PRO-02 | NFE | Interaction/legend concern needs current state. |
| 46 | PRO-03 | NSV | Counter delta requires fixture/time-state trace, not visual repair. |
| 47 | PRO-05 | NFE | Static affordance candidate. |
| 48 | PRO-06 | NFE | Visual token candidate. |
| 49 | PPE-01 | NFE | Static hierarchy candidate. |
| 50 | PPE-03 | NSV | Copy duplication candidate. |
| 51 | W1D-03 | NFE | Current capture/layout proof required. |
| 52 | W1D-04 | NFE | Interaction state missing. |
| 53 | W1D-05 | NSV | Editorial candidate. |
| 54 | W1CF-03 | NFE | Table visual comparison needed. |
| 55 | W1CF-04 | NFE | Layout candidate. |
| 56 | W1WF-03 | NFE | Motion/static state distinction unresolved. |
| 57 | RF-02 | NFE | Table-marker visual standard requires source/evidence trace. |
| 58 | RF-03 | NFE | Typography candidate. |
| 59 | RR-03 | NSV | Copy compression must preserve repair outcome. |
| 60 | RR-04 | NSV | Possible intentional success reinforcement. |
| 61 | ORS-03 | NFE | State-tone evidence required. |
| 62 | PRT-01 | NSV | Route-proof copy is claim-sensitive. |
| 63 | PRT-02 | NSV | Copy duplication candidate. |
| 64 | PRT-03 | NSV | Editorial candidate. |
| 65 | RC-03 | NFE | Same capture-sensitive dead-band family as REV-05. |
| 66 | SS-02 | NSV | Session copy is evidence-contract-owned. |
| 67 | SS-05 | NSV | Preserve exact run/repair facts before compaction. |
| 68 | SS-07 | NSV | Progress/read proof semantics require source owner. |
| 69 | SS-09 | AMS | “Local” is implementation-facing copy; change only with summary copy-guard coverage. |
| 70 | RH-02 | NSV | Return acknowledgement is progression/fixture dependent. |
| 71 | RH-03 | NFE | Same sticky-header/offset uncertainty as HOM-01. |
| 72 | PR-02 | NSV | Post-session proof display must retain source-backed claim limits. |

Raw members intentionally retained under systemic rows: WF-01/W1CF-01/RR-01/
ORS-01/LR-B/VT-01 (SYS-01); WD-01/W1D-01/LR-C/W9T-01 (SYS-02); LR-A and the
No-W13 `1/4` instance (SYS-07); SS-01/HOM-05/PRO-04/PPE-02/LRN-02/03
(SYS-11); W7T-01/02, W8T-01, W9T-01, W11T-01, W12T-01, W12P-01, W12PC-01,
VT-02, and NW13-01/02/03 (SYS-01/02/07/14 by root cause). They remain in the
accepted debt queue and are not dismissed by this declared-dedup format.

## 8. Source-owner map

| Concern | Current owner map | Decision |
| --- | --- | --- |
| Feedback clue pill | `_FeedbackCluePillV1`, runner copy formatter, `act0_repair_intent_copy_guard_v1.dart` | Separate feedback primitive/copy budget. |
| Table context pill | `_CenterPotV1` / table-state context in `act0_lesson_runner_shell_v1.dart` | Separate table consumer. |
| Flag tooltip/callout | `_TableRepairCalloutV1` and late-route signal data | Separate overlay owner. |
| Home/return subtitle | `act0_home_shell_v1.dart` copy + sequence-row layout | Separate hub owner. |
| Terminal context / CTA | campaign registry plus `_TerminalCompletionPayoffV1`, `_WorldMilestoneCardV1`, completion contract | Separate terminal owner; keep W13 blocked. |
| Table collision stack | `_Act0TableV1`, `_BetChipPlacementV1`, `_SeatPlacementV1`, center/callout overlays | Multiple anchored layers; no shared collision engine proven. |
| Progress `1/4` | route/session fixture data plus runner presentation; no global literal found | Trace fixture and UI separately. |
| Safe-area / scroll | runner stage `SingleChildScrollView`, bottom dock `SafeArea`, completion padding | Native evidence first. |

## 9. Mandatory-question outcomes

1. **PRA-01:** **STALE / fixture-specific.** Current source intentionally limits
all-locked topic preview to two representative cards. No Practice change is
admitted.
2. **Worlds:** **NOT SCORED.** The source has a Learn path surface, but the
audit’s claimed map/world-switch evidence was unavailable; retain this as an
evidence gap.
3. **Session Summary:** **D — unresolved native-device evidence gap.** Source
proves a separate scrollable completion shell and safe-area/bottom-padding
paths, not A runtime clipping, B initial-position failure, or C inadequate
padding. Do not change source without native proof.
4. **SYS-01:** **multiple unrelated owners**, not one component owner.
5. **SYS-02:** multiple positioned anchor/z-order owners; no generic shared
collision rule is proven.
6. **SYS-07:** `1/4` is not yet source-traced. It may be micro-set scope,
fixture state, or incorrect presentation; it is not authorized as a semantic
bug.
7. **No-W13:** separate the clipped context, terminal hierarchy, CTA truth,
and progress from one another. Smallest possible future wave is terminal-only
layout/copy after fresh evidence, with no new World, route, or semantics.
8. **Welcome handoff:** source proves a fixed composition owner, not whether
the empty upper region is intentional or current; fresh tall/short captures
required.
9. **Artifact risks:** segmented scroll/sticky headers (HOM-01/RH-03), partial
scroll landings (SS-01/PRO-04/PPE-02/LRN), fixture deltas (PRA-01/PRO-03), and
static-only motion/pressed-state assessments all remain active risks.
10. **SSOT compatibility:** broad Modern Table work conflicts with maintenance
mode; progression relabeling cannot change semantics; mascot is externally
gated; motion and route expansion are out of scope; public/Human-QA claims are
blocked.

## 10. Stale / incorrect findings

- PRA-01: stale/fixture-specific; current locked-topic source intentionally
  displays two, not four, representative cards.
- Worlds/progression 6.5: incorrect scoring method; canonical value is NOT
  SCORED pending actual map/switch evidence.
- LD-02: stale unless a fresh capture disproves the existing comfort-scroll
  path.
- Any asserted single SYS-01 or SYS-02 “shared primitive” owner: incorrect;
  source maps multiple independent consumers/layers.

## 11. Fresh-evidence-required queue

- 320/375/430pt current-main screenshots for feedback clues, table context,
  late-route flag/collision, and terminal copy.
- Native notched-device Session Summary top, bottom, and initial-scroll state.
- Welcome handoff on short and tall devices.
- Home/return initial-load plus scroll position; do not use stitched crop as
  proof.
- W7–W12 fixture trace for each `1/4`, including terminal/no-W13.
- Profile counter captures with stable fixture/time identity.
- Pressed/selected/motion states where the report makes interactive claims.

## 12. Accepted debt ledger

Accepted or conditionally accepted debt remains queued: feedback/header
deduplication (SYS-03); terminal hierarchy/CTA presentation (SYS-14/NW13);
secondary-action affordance (SYS-13); Home subtitle integrity if reproduced;
and removal of implementation-facing “Local” wording only under the existing
summary-copy guards. P2–P4 items remain preserved in the 72-row ledger; none
is discarded. Sharky (SYS-06) and content variety (SYS-12) are deferred, not
rejected.

## 13. Dependency-aware bounded waves

1. **Evidence packet only (first):** current captures and fixture trace listed
above. No source edits.
2. **If reproduced — feedback clue-pill integrity:** runner feedback pill and
its longest-string tests only. Excludes table, terminal, Home, progression,
motion, and mascot.
3. **If reproduced — table overlay integrity:** `_Act0TableV1` anchor/z-order
work plus W8/W9/W12 narrow regression captures. Excludes Modern Table redesign.
4. **If reproduced — terminal truth hierarchy:** terminal completion/card copy
and CTA presentation only. Excludes W13, new route, semantics, and content.
5. **If native proof identifies C:** Session Summary scroll-padding only.

## 14. Recommended first implementation wave

**Option F — Docs/evidence only.**

Exact scope: produce the evidence packet and fixture-to-owner trace. Non-scope:
all product code, Modern Table, progression semantics, W13, routes, content,
motion, telemetry, assets, and screenshot-driven iteration. Likely future files
only after the packet: `act0_lesson_runner_shell_v1.dart`,
`act0_home_shell_v1.dart`, and the exact W7–W12 source/fixture owner identified
by trace. Future tests: focused widget/guard tests per selected owner; evidence:
current deterministic captures and native proof where required. Stop if an item
does not reproduce, owner crosses the bounded family, fixture truth is unclear,
or a claim-safe copy guard would be altered without its tests.

## 15. Updated gates and non-claims

**Human QA:** remains blocked. It requires a fresh evidence packet, closure of
any reproduced P1 teaching-text/table-interpenetration defect, native safe-area
proof, and the existing product/Human-QA admission requirements. Static report
counts alone do not start Human QA.

**Public/investor:** remains blocked by Human QA and existing public-readiness
authority; also by the Sharky external gate, unscored Worlds evidence, and any
reproducible teaching-text/overlay defect. This ledger does not claim launch,
public readiness, learning effect, 10/10 quality, fixed-forever behavior, or
Worlds/route completion.

**Explicit status:** Sharky = external identity gate; motion = not adjudicated
without motion evidence; Worlds/map/switch = NOT SCORED evidence gap; W13 =
blocked and not implied by terminal CTA or copy.

## Validation / handoff

- `git diff --check`: pass after this documentation artifact is added.
- `graphify hook-check`: pass.
- No source tests run: docs/source-inspection-only task.
- No screenshot generation performed; existing evidence was insufficient to
  resolve contradictions without a dedicated future evidence packet.
