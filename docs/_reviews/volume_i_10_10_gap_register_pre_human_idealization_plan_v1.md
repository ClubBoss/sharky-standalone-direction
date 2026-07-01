# Volume I 10/10 Gap Register & Pre-Human Idealization Plan v1

Date: 2026-07-01
Scope: audit/planning only; no implementation, no Human QA, no screenshots/output.
Current repair state: `pre_human_repairs_and_p2_adjudication_landed`
Latest semantic rerun source: `/Users/elmarsalimzade/Desktop/Audit 4.md`

## 1. Verdict

small_idealization_copy_wave_recommended

Volume I is prepared enough to write a Human QA readiness packet, but it is not
yet close to a near-ideal beginner learning product. The remaining gap is not a
new P0/P1 blocker. It is a narrow set of high-EV perception and bridge issues
that could make humans see a stronger, clearer version of the route before they
judge it: W12 payoff/terminal satisfaction, W9 non-draw applicability after the
draw bridge, W6->W7 emotional/cognitive bridge strength, W11 danger wording
polish, and W11->W12 review motivation.

The recommended pre-Human work is a small copy/bridge/payoff wave only. It must
not expand W1-W6 families, implement mapper/Practice, open W13+, move scores,
claim readiness, or rewrite the route.

## 2. Plain-Language Summary

Volume I is no longer merely blocked by obvious machine-fixable defects. The
P1 repair pack removed the broken W12 ending, clarified W10 versus W4/W9,
reconnected W8 to W5 draws, strengthened W12 payoff copy, and audited W7-W12
first-use jargon. Audit 4 judged those repairs semantically sound and said a
Human QA readiness packet can be prepared.

The stricter 10/10 question asks something different: will humans see the best
reasonable version of Volume I, or a technically safe version with a few
avoidable rough edges? The answer is that a few rough edges remain. W12 may
still read as a checklist instead of a satisfying ending. The terminal pack is
safe, but may feel anticlimactic. W9 now bridges from draws to call price, but
W9 also needs to feel useful for non-draw calls. W6->W7 is technically bridged,
but the cognitive jump from range buckets to visible-card range narrowing is
still the most important transition. W11 danger language is defined, but could
still feel heavy.

The highest EV before humans see it is a tiny/small copy wave that improves
payoff, bridge motivation, and perception without changing product scope.

## 3. 10/10 Gap Register

| id | world/transition | gap description | why it matters for a beginner | severity | machine-actionable | should fix before Human QA | expected EV | scope size | risk if fixed now | risk if deferred | likely owner seam | recommended validation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| G10-01 | W12 payoff | Current W12 payoff names clue families, but may read as an inventory rather than "I learned to connect clues." | The ending is where learners decide whether the course felt coherent. A checklist can feel like a quiz, not progress. | 10/10 opportunity | yes | yes | high | tiny | Overclaiming capability if wording gets too triumphant. | Human QA may underrate the curriculum because the ending under-sells the learning arc. | `lib/campaign/campaign_pack_registry_v1.dart` W12 final payoff step and W12 guard. | Guard W12 still names at least three clue families, contains a capability/process phrase such as "connect clues into an explanation", and blocks mastery/readiness/top-1/10/10/launch/public claims. |
| G10-02 | W12 terminal | `volume_i_terminal_review_v1` is safe and explains W13 blocked, but may feel like an administrative stop. | The last visible state should feel intentional and earned, not merely "no next world." | 10/10 opportunity | yes | yes | high | tiny | Accidentally implying Practice CTA, W13 promise, or readiness. | Humans may report an anticlimactic or confusing finish even though routing is fixed. | `lib/campaign/campaign_pack_registry_v1.dart` terminal pack and W12 terminal guard. | Guard terminal copy says Volume I review complete, next visible activity is review/keep-sharp, W13 not open, and no Practice CTA/mapper/claim-risk terms. |
| G10-03 | W9 non-draw applicability | W9 first bridge now starts from "after spotting a draw"; W9 also applies when no draw is obvious. | Beginners may think pot/call-price thinking is only for draws, then fail to apply it to made-hand or weak-reward calls. | P3 | yes | yes | medium | tiny | Weakening the successful W8->W9 bridge if the wording becomes too generic. | Human QA may find W9 transfer brittle outside draw spots. | W9 first pack copy and W9 guard. | Guard first W9 copy keeps draw-to-price bridge and also says call price applies with or without a clear draw / to each call decision. |
| G10-04 | W6->W7 cognitive pivot | W7 says it continues W6, but the transition from range buckets/width to visible cards narrowing ranges remains the highest-stakes pivot. | A beginner who has not internalized W6 may see W7 as a new abstraction instead of the next step. | P2 | yes, copy-only | yes | high | tiny/small | Over-explaining range language before W7 and increasing cognitive load. | Human QA may spend its strongest signal on a preventable bridge weakness. | W7 first pack context plus W7 route-depth guard; optionally W6 completion chrome if admitted in a separate source seam. | Guard W7 first copy references W6 range buckets/width and the new W7 job: visible cards narrow possible hands. |
| G10-05 | W11->W12 review motivation | W12 opens as a review checkpoint, but the learner may not know why everything is being reviewed now. | Review feels stronger when learners understand it is a final clue-combination pass, not a random test. | P3 | yes | yes | medium | tiny | Making W12 sound like a mastery capstone. | Humans may report W12 feels like an exam or abrupt quiz. | W12 first pack context and W12 guard. | Guard W12 first pack says "why review": combine prior clues / final Volume I review, without mastery or readiness claims. |
| G10-06 | W11 danger vocabulary | "Danger" is defined as texture pressure, but the word is emotionally strong and can be overgeneralized. | Beginners may start marking every connected/suited board as danger instead of reading specific paths. | P2 | yes, small copy | yes | medium | tiny | Defanging the useful warning signal too much. | Human QA may show W11 over-danger or fear-based answers. | W11 route pack copy and W11 guard. | Guard danger copy pairs danger with concrete path language and rejects "always safe/never matters/guarantee" style wording. |
| G10-07 | W8 draw-type vocabulary load | W8 introduces flush draw, open-ended straight draw, and one-gap/gutshot-style comparison in one world. | Even defined terms can feel dense when clustered. | P2 | partly | no | medium | medium | Pre-Human rewrite could destabilize a recently repaired world. | Humans may report W8 is too terminology-heavy. | W8 packs and W8 jargon guard. | Human QA observation first; repair later if confusion clusters around term load. |
| G10-08 | W8->W9 bridge after repair | Bridge is present and semantically sound, but one sentence may not be enough to carry learners from qualitative draw quality to price comparison. | The draw-to-price mental model is central to W9 motivation. | P2 | partly | no, unless combined with G10-03 | medium | small | Duplicating bridge copy could feel repetitive. | Human QA may still flag ask-before-teach risk. | W9 first pack, W9 guard. | Include as Human QA observation; only pre-fix non-draw applicability. |
| G10-09 | W3 scenario richness | W3 has two canonical Position Thinking families. | Position is foundational and affects many downstream decisions; two families may not build durable intuition. | P2 | no, not safely in this wave | no | high | medium/large | Adding a new family without source authority risks content quality and scope drift. | Human QA may reveal W3 feels thin or repetitive. | W3 source/fixture/registry owners, not this copy wave. | Human QA richness observation; later source-owned expansion DoD. |
| G10-10 | W6 scenario richness / two-family thinness | W6 has two narrow range-thinking families. | W6 supports W7-W12; if range buckets/width are thin, later abstractions wobble. | P2 | no, not safely in this wave | no | high | medium/large | Expanding W6 before evidence can widen a deliberately narrow world. | W6->W7 may feel abrupt or under-prepared. | W6 source/fixture/registry owners, W6 runner chrome. | Human QA transition observation; later source-owned W6 richness wave if needed. |
| G10-11 | W1 copy clarity | W1 is an 8.5 candidate with broad copy sweep incomplete. | The first world sets trust and comprehension for all later work. | P2 | no concrete defect found | no | high | medium | Broad W1 polish can churn frozen baseline without evidence. | Humans may find entry copy unclear. | W1 Act0 table/action/street packs and W1 guards. | Human QA entry observation; repair only from concrete confusion evidence. |
| G10-12 | W2 bridge-limited remainder | W2 has bridge-limited remainder not human-reviewed. | If W2 outruns W1, beginners can lose confidence early. | P2 | no concrete defect found | no | medium | medium | Broad W2 history read/rewrite violates scope. | Humans may find W1->W2 handoff uneven. | W2 campaign/followup packs and runner chrome guard. | Human QA W1->W2 observation; later exact-owner repair if needed. |
| G10-13 | W1-W6 soft-claim residue | W7-W12 were swept in touched copy; W1-W6 frozen baseline still may contain soft implication risk. | Early completion copy can overstate competence even without forbidden terms. | P2 | only with exact defect | no | medium | medium | Broad frozen-baseline copy churn. | Human QA may flag confidence/readiness implication. | W1-W6 active campaign/chrome copy owners. | Human QA claim-safety checklist; targeted repair from exact evidence. |
| G10-14 | Practice CTA absence W7-W12 | Learners who want repetition have no Practice CTA. | Repetition is a natural expectation after mistakes. | P2 | no, requires future gate | no | high | large | Implementing without mapper allowlist can route unsafe practice. | Humans may ask "how do I practice this again?" | Mapper/Practice gate, hidden session owners. | Separate mapper/Practice gate after QA or explicit admission. |
| G10-15 | W9/W10 cross-world repair handling | Copy distinguishes W9 and W10, but repair remains world-local. | A learner can misunderstand price and purpose together. | P2 | no, system work | no | medium | medium/large | Building cross-world repair before QA may over-engineer the wrong pattern. | Human QA may show coupled mistakes. | Repair memory/mapper/followup owners. | Human QA error tagging; later cross-world repair DoD. |
| G10-16 | Route feels like questions, not guided learning | Several packs are task/checkpoint-heavy. | A 10/10 beginner product needs guided progression, not only correct taps. | 10/10 opportunity | partly | no broad fix now | high | large | Broad rewrite or visual/product redesign. | Humans may rate product as useful but not premium/engaging. | Cross-world copy, runner chrome, result surfaces. | Human QA motivation/product-feel prompts; later design/content wave. |

## 4. Fix-before-Human-QA List

| item | why fix before Human QA | bounded? | minimum excellent repair shape | Codex should touch | Codex must not touch | validation needed |
| --- | --- | --- | --- | --- | --- | --- |
| G10-01 W12 payoff capability framing | It directly improves the signal humans will judge at the end of Volume I. | yes | Add one modest capability/process sentence: the learner has practiced connecting visible cards, range, draw, price, purpose, and texture into an explanation. | W12 route payoff copy and W12 guard. | No mastery/readiness/10/10/top-1/launch/public claims; no new W12 system. | W12 guard for cue families, capability/process wording, and claim safety. |
| G10-02 W12 terminal satisfaction | It prevents safe terminal copy from feeling like a dead end. | yes | Add earned-close wording to terminal pack: Volume I review is complete; keep-sharp review is intentional; later worlds remain closed. | Terminal pack copy and W12 terminal guard. | No Practice CTA, mapper target, W13 promise, score movement, or public claim. | Terminal guard plus no `world13_` pack assertion. |
| G10-03 W9 non-draw applicability | It prevents W9 from feeling draw-only after the P2-06 bridge. | yes | Keep the draw bridge, then add "the same price check applies when no clear draw is visible." | W9 first route pack and W9 guard. | No W9 rewrite, no math expansion, no solver/GTO. | W9 guard for draw bridge plus non-draw applicability and claim safety. |
| G10-04 W6->W7 pivot bridge | It is the highest-stakes transition humans will inspect; a one-line bridge may reduce avoidable confusion. | yes | Strengthen first W7 context to mention W6 range buckets/width and W7's new job: visible cards narrow possible hands. | W7 first route pack and W7 guard. | No W6 content expansion or new family. | W7 guard for W6 bridge, visible cards, range, possible hands, no exact-hand overclaim. |
| G10-05 W11->W12 review motivation | It makes W12 feel like a deliberate final integration pass. | yes | Add "now W12 reviews why those clues belong together" style wording to W12 first context. | W12 first route pack and W12 guard. | No capstone/mastery/readiness copy. | W12 guard for review motivation and claim safety. |
| G10-06 W11 danger vocabulary polish | It may reduce over-danger behavior before humans judge W11. | yes | Pair danger with "specific paths" and avoid absolute danger/safety wording. | W11 route copy and W11 guard. | No broad W11 rewrite. | W11 guard for dry/connected/suited/danger path wording and soft-claim exclusions. |

These six items should be one small copy/guard wave. Stop if any item requires
source-family expansion, route state changes, mapper/Practice, W13+, or broad
copy rewrite.

## 5. Big Work Candidate List

| candidate | why it matters | smallest useful version | expected EV | before or after Human QA | risk before Human QA | suggested DoD |
| --- | --- | --- | --- | --- | --- | --- |
| W3 position richness expansion | Position intuition may not build from two families. | Add one source-owned canonical W3 family only if source architecture admits it. | high | after Human QA unless specific evidence appears earlier | Scope drift and unsupported source-remap. | New source packet, fixture/projection, focused guard, no broad W3 rewrite. |
| W6 range richness expansion | W6 supports W7-W12 abstractions. | Add one source-owned range bucket/width transfer family. | high | after Human QA | Could widen a deliberately narrow world and create new bridge debt. | Source-owned family, runner/progression guard, W6->W7 bridge guard. |
| Mapper/Practice CTA for W7-W12 | Learners need repetition paths. | Safe allowlist for one W7-W12 family after mapper proof. | high | separate future gate | Unsafe practice target or false repair promise. | Mapper allowlist proof, hidden owner `practiceCtaAllowed` policy, no W13/monetization. |
| Cross-world W9/W10 repair handling | Coupled price/purpose mistakes may need integrated repair. | Observation-driven cross-world repair cue for W9+W10 misses. | medium | after Human QA | Over-engineering without observed error patterns. | Human QA error evidence, repair owner, focused guard. |
| Guided learning/product feel layer | Route may feel like a sequence of questions. | Add narrow intro/outro microcopy to one or two proven weak transitions. | high | after Human QA, unless tiny copy wave above is accepted | Broad redesign or marketing-style polish. | Human QA evidence, copy guard, no visual/product redesign. |

## 6. Do-not-fix-before-Human-QA List

| item | why not fix now | what humans should observe | evidence that would trigger repair later |
| --- | --- | --- | --- |
| W3 scenario richness | Requires source/family expansion, not safe copy polish. | Whether two position families feel repetitive or insufficient. | Multiple learners report W3 does not build position intuition or misses transfer. |
| W6 scenario richness | Requires content expansion and could widen a locked narrow world. | Whether W6 prepares W7 and later range concepts. | Learners fail or verbalize confusion at W6->W7 because W6 range basis is weak. |
| W8 draw-type load | Recent repair already defines terms; subjective load needs observation. | Whether flush/open-ended/one-gap cluster overwhelms beginners. | Confusion clusters around term volume rather than a single wording gap. |
| W2 bridge-limited remainder | No exact defect found; broad W2 history is out of scope. | Whether W2 outruns W1 table/action basics. | Specific W2 prompt or scenario is named by learners as confusing. |
| W1 broad copy clarity | Frozen baseline; no concrete defect found. | Entry comprehension, action vocabulary, street flow. | Learners misunderstand exact W1 prompt/copy; then repair targeted seam. |
| W1-W6 soft-claim residue | Broad frozen copy sweep risks churn. | Whether completion copy implies competence/readiness. | Exact soft-claim phrase or surface is observed. |
| Practice CTA absence | Needs mapper/Practice gate. | Whether learners ask for repetition and where. | Repeated demand for re-practice plus safe mapper target proof. |
| Cross-world repair system | Needs observed coupled errors. | Whether W9/W10 mistakes occur together. | Human QA evidence of coupled price/purpose misunderstandings. |
| Premium product feel | Monetization/public readiness blocked. | Whether the product feels coherent and motivating, not commercially ready. | Post-QA product-feel findings, not pre-QA speculation. |

## 7. Codex-ready Repair Plan

### Batch 1: Tiny/small high-EV copy/bridge/payoff repairs

Included items: G10-01, G10-02, G10-03, G10-04, G10-05, G10-06.

Owner seams:

- `lib/campaign/campaign_pack_registry_v1.dart`
- `test/guards/w7_route_depth_followup_quality_contract_test.dart`
- `test/guards/w9_route_admission_depth_gate_contract_test.dart`
- `test/guards/w11_route_admission_transfer_depth_gate_contract_test.dart`
- `test/guards/w12_route_admission_review_payoff_gate_contract_test.dart`
- `test/guards/w7_w12_first_use_jargon_contract_test.dart`

Expected files/tests:

- Update only route-visible copy and focused guards.
- Run `dart format` on touched Dart/test files.
- Run focused W7/W9/W11/W12/jargon guards.
- Run `flutter analyze` if Dart changed.
- Run `git diff --check`, `git diff --cached --check`, `graphify hook-check`.

Stop condition:

- Stop if any improvement requires new content family, route state changes,
  mapper/Practice, W13+, screenshots/output, Human QA, monetization, or broad
  W1-W12 rewrite.

### Batch 2: Medium bounded curriculum/richness repairs

Included items: W3 richness, W6 richness, W8 load, cross-world repair only if
Batch 1 is done and a separate prompt explicitly admits source/family or repair
system work.

Owner seams:

- W3/W6 source/fixture/projection owners to be identified by exact failing
  evidence.
- Repair-memory/mapper owners only after Human QA or explicit scope admission.

Expected files/tests:

- New source-owned fixtures only with validator/guard coverage.
- Focused regression/route guards.

Stop condition:

- Stop without Human QA evidence or explicit source-expansion admission.

### Batch 3: Deferred/future gates

Included items: mapper/Practice CTA, public/premium/launch readiness, W13+,
monetization, broad product feel, cross-world repair system if not supported by
Human QA evidence.

Owner seams:

- Separate mapper/Practice gate.
- Separate commercial/public readiness gates.

Validation:

- Gate-specific proof only; not part of this pre-Human idealization plan.

Stop condition:

- Any attempt to use this plan to claim readiness, Human QA pass, public
  learning effect, top-1, 10/10, W13+, or monetization readiness.

## 8. Final Recommendation

run_codex_small_copy_bridge_wave

Run one bounded pre-Human idealization copy wave before preparing the Human QA
readiness packet. The wave should be small enough to preserve the current
repair-batch truth and should only address the six fix-before-Human-QA items in
Batch 1. If that wave grows beyond copy/guard changes, stop and prepare the
Human QA readiness packet instead.

## 9. Claim-Safety Note

- No public readiness claim.
- No top-1 or 10/10 claim.
- No Human QA pass.
- No public learning-effect proof.
- No monetization readiness.
- W13+ remains blocked.
- Mapper/Practice remains blocked unless classified as a separate future gate.

This artifact recommends a small improvement wave toward a stronger pre-Human
experience. It does not claim Volume I is ideal, public-ready, launch-ready,
premium-ready, Human-QA-ready, or proven effective for learners.
