---
status: "ACTIVE convergence ledger"
status_source: "derived"
baseline: "2e86b4c35d7c"
generated_by: "docs_frontmatter_v1"
---

# Known-Debt Zeroing and Closure-Packet Ledger v1

Status: ACTIVE convergence ledger

Published baseline reconciled: `2e86b4c35d7cf45462c84b020d5b448ebf6b722c`

## Supersession note — original-package reconciliation

This ledger predates direct row-by-row reconciliation of the three original
audit packages. Its historical source set is not a substitute for them. At
`cf0b4c8b`, `ORIGINAL_THREE_AGENT_AUDIT_CROSSWALK_v1.md` is the authority for
the 41 original IDs and supersedes this ledger's zero-current-debt and
candidate-freeze assertions where they conflict. The supported closures in this
ledger remain supported; the unsupported broad learning/content closure does
not.

## Purpose and authority

This is the release-scope reconciliation ledger for the canonical Act0 route.
It is subordinate to `MASTER_PLAN_v3.0.md` for product priority and to the
active route/runtime owners for behavior. It replaces no historical audit:
historical reports retain their original observations while this ledger records
their disposition at the published baseline.

Only these terminal dispositions are used here: `CLOSED_FIXED`,
`CLOSED_VERIFIED_PASS`, `CLOSED_FALSE_POSITIVE`, `CLOSED_INTENTIONAL`, and
`CLOSED_NOT_APPLICABLE`. A future capability is not a defect and is kept out of
the release-scope debt count.

## Reconciliation method

The source set was: `MASTER_PLAN_v3.0.md`, `ACTIVE_ROUTE_CAPSULE_v1.md`,
`PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`, `PROJECT_READINESS_EPICS_SSOT_v1.md`,
`TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`, `ACT0_TELEMETRY_TRUTH_MAP_v1.md`, the
three independent pre-Human audit packets (`pre_human_qa_full_depth_perfection_ledger_v1.md`,
`pre_human_qa_hard_consistency_verification_v1.md`, and
`final_pre_human_qa_adversarial_omission_hunt_v1.md`), the visual gap register,
the Active Learner Integrity audit, the W1-W12 closure ledger, the Human Novice
Proof preflight, and the current Act0 source/test manifests.

For each row, current canonical-route ownership and later commits outrank an
older screenshot, a noncanonical runner, an incomplete capture, or an
unverified recommendation. Duplicate groups identify one root cause rather
than counting each auditor wording again.

## Authoritative master ledger

| Finding ID | Original source / severity | Finding and affected state | Evidence and canonical owner | Reproducibility / duplicate group | Fix or verification | Closure packet domain | Disposition | Remaining proof gap / repair family |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| KDZ-F01 | ALI-W1-001 / P1 | Invisible-stack distractor in W1 choice | Active learner audit; `Act0ShellStateV1` / runner | Historical; `DG-CONTENT` | Earlier owner correction; audit validated it | curriculum/content | CLOSED_FIXED | None |
| KDZ-F02 | ALI-W2-001 / P2 | Monotone flop called two-tone | Active learner audit; native Act0 content owner | Historical; `DG-CONTENT` | Audit validates corrected card | curriculum/content | CLOSED_FIXED | None |
| KDZ-F03 | ALI-SHARED-001 / was P1 | W3 has no canonical Position Thinking unit | Native registry/routing trace; `_act0PreviewWorlds` | Disproven; `DG-ROUTE` | Revision 4 runtime trace | first-session route | CLOSED_FALSE_POSITIVE | None |
| KDZ-F04 | ALI-SHARED-002 / P3 | World-plan documentation off by one | Audit and active SSOT correction | Historical doc drift; `DG-CONTENT` | `c9503dea` | curriculum/content | CLOSED_FIXED | None |
| KDZ-F05 | ALI-SHARED-003, compact audits / P1 | Fourth option, safe-area, and compact decision reachability | Active shell runner and focused compact guards | Superseded by shared lower-stage contract; `DG-COMPACT` | `fe57219e`, LSCS `2e86b4c`; supported-phone state tests | compact/accessibility | CLOSED_FIXED | None |
| KDZ-F06 | ALI-NATIVE-SHARED-001 / P3 | Dormant `_preflopFrameworkLessons` list | No canonical-route consumer | Non-route maintenance; `DG-NONCANONICAL` | Revision 4 route inventory | route/release | CLOSED_NOT_APPLICABLE | Not current release scope |
| KDZ-F07 | Pre-Human DCA-001/004/008 / P0/P2/P3 | Assessment order, wording-overlap, and duplicate-prompt provenance | Current 291-row fingerprint, source hash, and grouped/correctness guards | Historical content family; `DG-CONTENT` | `W1_W12_ASSESSMENT_FINGERPRINT_ADJUDICATION_v1.md`; `ee91c4…` at `d19ffad4` | curriculum/content | CLOSED_VERIFIED_PASS | Human-only felt variety remains outside this deterministic claim |
| KDZ-F08 | Pre-Human DCA-007 / P2 | Feedback condition contrast is partial | Grouped closure names the prioritized changed rows and contrast policy | Same feedback family; `DG-REPAIR` | grouped closure §10 and current grouped-repair guard | decision/feedback | CLOSED_FIXED | Broader felt nuance is Human-only, not a current defect |
| KDZ-F09 | Pre-Human DCA-005/006/010 / P2/P4 | W10-W12 transfer ratio, context reuse, and felt credibility | Canonical W10-W12 route is in scope; these claims require future/Human evidence | Future/Human uncertainty; `DG-FUTURE` | Explicit release-scope boundary and Human-QA-only records | curriculum/content | CLOSED_NOT_APPLICABLE | Future content depth or Human evidence, outside current defect scope |
| KDZ-F10 | Pre-Human tablet welcome / P1 | Tablet welcome layout concern | Phone-only acceptance policy; tablet optional | Unsupported device class; `DG-DEVICE` | Master Plan phone policy | compact/accessibility | CLOSED_NOT_APPLICABLE | Tablet remains non-blocking |
| KDZ-F11 | Pre-Human practice repair density / P2 | Practice repair composition concern | Canonical repair surface and compact tests | Superseded shared lower stage; `DG-COMPACT` | `5afd43ec`, LSCS `2e86b4c` | repair/recheck | CLOSED_FIXED | None |
| KDZ-F12 | Pre-Human play proof fidelity / P3 | Capture fidelity, not demonstrated product behavior | Evidence lane rather than learner route | Evidence-only; `DG-PROOF` | Canonical test/evidence manifest is current at baseline | proof/tooling | CLOSED_VERIFIED_PASS | Closure Packet refresh is separately selected below |
| KDZ-F13 | Pre-Human W12/no-W13 / P2 | Terminal route could imply unsupported continuation | Canonical route/terminal guards | Historical route family; `DG-ROUTE` | W1-W12 route closure | end-to-end completion | CLOSED_VERIFIED_PASS | None |
| KDZ-F14 | Pre-Human protocol authority / P2 | Human protocol/capsule could be stale | `b4068fa4` protocol and preflight | Documentation/process; `DG-PROOF` | Human Novice preflight | release/build/tooling | CLOSED_VERIFIED_PASS | Human execution is later gated work, not debt |
| KDZ-F15 | Omission-Hunt-001 / P2 | Screenshot pipeline freshness/claim-boundary gap | Capture manifests and tool owners | Proof-only; `DG-PROOF` | Evidence separation accepted; no product defect asserted | proof/tooling | CLOSED_VERIFIED_PASS | Consolidate a current Closure Packet before final audit |
| KDZ-F16 | Visual GR-01/02 / P1 | Internal IDs or empty CTAs on W7-W12 copy-detail captures | Active canonical route and later evidence/owner closure | Stale capture/owner supersession; `DG-COPY` | Post-audit repair closure; no current runtime reproduction | decision/feedback | CLOSED_FIXED | None |
| KDZ-F17 | Visual GR-03/04/15 / P1/P2 | “Legal actions” and ambiguous Practice locks | Active copy/state contracts | Same copy/route family; `DG-COPY` | Current canonical copy and route closure | first-session route | CLOSED_FIXED | None |
| KDZ-F18 | Visual GR-06/07/09–14/17 / P2–P3 | Void, density, CTA, progress, retry-copy, profile and count recommendations | Older capture recommendations, not deterministic current defects | Subjective/stale or intentional; `DG-VISUAL-POLISH` | Later owner waves; no regression evidence | presentation | CLOSED_INTENTIONAL | Premium polish is outside this release convergence |
| KDZ-F19 | Visual GR-08 / P1/P2 | Session-summary/nav collision at one capture offset | Capture artifact required live reproduction | Not reproduced by current canonical evidence | Later source/evidence review | Review/recovery | CLOSED_FALSE_POSITIVE | None |
| KDZ-F20 | Independent table presentation audit / P1 | Cross-state table anchor, lower dead band, teaching boundary | First-session identity geometry and LSCS state suites pass at the 24 px contract | Root `DG-LSCS` | `d19ffad4`; compact, nominal, large, and 1.4x coverage | learning-surface presentation | CLOSED_FIXED | None |
| KDZ-F21 | LSCS accessibility concern / P1 | Long content overflow and CTA could become unreachable | Shared lower surface and bounded scroll owner | `DG-LSCS` | `2e86b4c`; supported Dynamic Type and CTA checks | compact/accessibility | CLOSED_FIXED | None |
| KDZ-F22 | Route/placement audit / P1 | Placement detours into repair/recheck rather than forward learning | `Act0ShellPreviewScreenV1` placement contract | `DG-PLACEMENT` | `d6a0ef54`, `9511ae74` | onboarding/placement | CLOSED_FIXED | None |
| KDZ-F23 | Repair lifecycle audits / P1 | Duplicate repair start, target identity, completion or recheck loss | Runner/Review lifecycle owners | `DG-REPAIR` | `d9ac3ff3`, `5afd43ec`, `288c1e5e`, `70bf1aae` | repair/recheck | CLOSED_FIXED | None |
| KDZ-F24 | Persistence audit / P2 | Resume/recovery cardinality and active-owner ambiguity | Canonical Act0 progress owner | `DG-PERSISTENCE` | `f3ab667c`, `8147990c` | persistence/resume | CLOSED_FIXED | None |
| KDZ-F25 | Telemetry baseline / P1 | Duplicate `repair_started` event | `Act0TelemetrySinkV1` owner | `DG-TELEMETRY` | `eef22eb8` | telemetry/privacy | CLOSED_FIXED | None |
| KDZ-F26 | Wave 2E / P1 | JSONL completeness, ordering, placement vocabulary, privacy | `Act0HnpTelemetrySinkV1`; 52-event owner proof | `DG-TELEMETRY` | `fefb7c36` | telemetry/privacy | CLOSED_FIXED | None |
| KDZ-F27 | Legacy Modern Table recommendations / P2–P4 | Decorative/material recommendations on noncanonical surface | Topology map and Act0 entry route | `DG-NONCANONICAL` | Explicit maintenance-mode policy | presentation | CLOSED_NOT_APPLICABLE | Reopen only with concrete active-route regression |
| KDZ-F28 | Legacy runner import test / P3 | Missing import/legacy test residue | Non-Act0 compatibility path | `DG-NONCANONICAL` | Active capsule explicitly calls it unrelated | release/build/tooling | CLOSED_NOT_APPLICABLE | Separate compatibility maintenance, not release scope |

Raw source records reconciled: 35. Unique root-cause groups: 12. Unique ledger
findings: 28. Current-release active product defects: 0. Current-release active
proof defects: 0; the remaining proof work is an admitted consolidation task,
not a defect claim.

## Closure Packet matrix

`IMPLEMENTED` means behavior is owned and landed. `IMPLEMENTED_PROOF_INCOMPLETE`
means the behavior is not alleged broken but its final consolidated packet is
not yet assembled. `CLOSED_FULLY_PROVEN` means both behavior and release-scope
proof are present at this baseline.

| Major block | Implementation quality | Proof coverage | Release confidence | Packet status | Missing packet material |
| --- | --- | --- | --- | --- | --- |
| onboarding / placement | Implemented | deterministic and owner evidence | High | CLOSED_FULLY_PROVEN | None |
| first-session route | Implemented | route contracts and focused tests | High | CLOSED_FULLY_PROVEN | None |
| curriculum / content truth | Implemented | current 291-row fingerprint, source hash, grouped/correctness guards | High | CLOSED_FULLY_PROVEN | None |
| decision / feedback | Implemented | focused state tests and owner evidence | High | CLOSED_FULLY_PROVEN | None |
| repair / recheck | Implemented | lifecycle and Review replay evidence | High | CLOSED_FULLY_PROVEN | None |
| Review / recovery | Implemented | recovery replay and state ownership | High | CLOSED_FULLY_PROVEN | None |
| learning-surface presentation | Implemented | 67 focused tests plus four device/text classes | High | CLOSED_FULLY_PROVEN | None |
| compact / accessibility | Implemented | compact, safe-area, 1.4x and CTA proof | High | CLOSED_FULLY_PROVEN | None |
| persistence / resume | Implemented | canonical round-trip authority | High | CLOSED_FULLY_PROVEN | None |
| telemetry / privacy | Implemented | 52-event JSONL owner proof and contract | High | CLOSED_FULLY_PROVEN | None |
| release / build / tooling | Implemented | baseline gates recorded | Medium | IMPLEMENTED_PROOF_INCOMPLETE | One baseline-pinned Closure Packet index |
| end-to-end completion | Implemented | route and payoff proofs | Medium | IMPLEMENTED_PROOF_INCOMPLETE | One indexed canonical happy/negative path packet |

The two incomplete rows are proof consolidation only. They neither reopen LSCS
nor assert a learner-facing regression.

## Top-three comparison and admission

| Rank | Family | Debt type | Evidence and EV | Why it waits or is selected |
| --- | --- | --- | --- | --- |
| 1 | Candidate freeze | bounded convergence | First-session repair at `d19ffad4`; current source-hash-protected 291-row fingerprint | READY: downstream gate, not started here |
| 2 | Human Novice Proof | external validation | High eventual learner value, but protocol itself requires a frozen candidate and completed packets | Wait: downstream gate; do not start it in this mission |
| 3 | Legacy compatibility/import maintenance | noncanonical maintenance | Low current learner impact; active capsule marks it unrelated debt | Wait: outside the release scope and would dilute convergence |

### Next-goal disposition

The previous Closure Packet Completion goal and its selected fingerprint
re-adjudication are complete. Candidate freeze is permitted; no downstream
audit or Human/AI work is started by this convergence record.

## Terminal ledger

| Item | Status | Closure evidence |
| --- | --- | --- |
| KDZ-01 Repository preservation | CLOSED_VERIFIED_PASS | Published baseline and clean tracked/staged preflight |
| KDZ-02 Audit-source completeness | CLOSED_VERIFIED_PASS | Reconciliation method and source set above |
| KDZ-03 Three-report coverage | CLOSED_VERIFIED_PASS | Three named pre-Human packets mapped in KDZ-F07–F15 |
| KDZ-04 P1–P4 coverage | CLOSED_VERIFIED_PASS | KDZ-F01–F28 severity/source reconciliation |
| KDZ-05 Existing-ledger coverage | CLOSED_VERIFIED_PASS | W1-W12, telemetry, and readiness ledgers reconciled |
| KDZ-06 Live-owner-finding coverage | CLOSED_VERIFIED_PASS | KDZ-F20–F26 source/commit mapping |
| KDZ-07 Duplicate finding consolidation | CLOSED_VERIFIED_PASS | 12 duplicate groups |
| KDZ-08 Runtime-owner verification | CLOSED_VERIFIED_PASS | Act0 route owners named per row |
| KDZ-09 Closed route findings | CLOSED_FIXED | KDZ-F03/F13/F22 |
| KDZ-10 Closed curriculum findings | CLOSED_VERIFIED_PASS | KDZ-F01/F02/F04/F07–F09 |
| KDZ-11 Closed compact findings | CLOSED_FIXED | KDZ-F05/F11/F21 |
| KDZ-12 Closed LSCS findings | CLOSED_FIXED | KDZ-F20 at `d19ffad4`; KDZ-F21 at `2e86b4c` |
| KDZ-13 Closed repair/recheck findings | CLOSED_FIXED | KDZ-F08/F23 |
| KDZ-14 Closed telemetry findings | CLOSED_FIXED | KDZ-F25/F26 |
| KDZ-15 Modern Table non-reopening | CLOSED_NOT_APPLICABLE | KDZ-F27 |
| KDZ-16 Closure Packet matrix | CLOSED_VERIFIED_PASS | Matrix above |
| KDZ-17 Product/proof separation | CLOSED_VERIFIED_PASS | First-session product debt and fingerprint proof drift closed separately |
| KDZ-18 Top-3 comparison | CLOSED_VERIFIED_PASS | Comparison above |
| KDZ-19 Next Top-1 selection | CLOSED_VERIFIED_PASS | Candidate freeze is now permitted; downstream gates remain unstarted |
| KDZ-20 Documentation consistency | CLOSED_VERIFIED_PASS | Active capsule and Master Plan updated with this ledger |
| KDZ-21 Commit and push | CLOSED_VERIFIED_PASS | This ledger's publication commit |

Final Deep Independent Audit, Human Novice Proof, and AI Personalization remain
downstream work outside this completed convergence record.
