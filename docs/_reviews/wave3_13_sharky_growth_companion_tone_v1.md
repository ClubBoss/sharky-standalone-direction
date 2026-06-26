# Wave 3.13 - Sharky Growth / Companion Tone v1

## 1. Verdict

wave3_13_sharky_growth_companion_tone_ready

## 2. Target 10/10 block

Sharky Growth / Companion Tone.

Target backcast row D: Foundation Sharky should feel warm and simple while the future 36-world register is structurally protected without AI/chat.

## 3. Current gap

Sharky had compact soul phrases but not a formal tiered growth contract.

Before this slice, `Act0SharkyCoachMomentV1` owned a small set of phrases, but it did not define Foundation / Developing / Sharp tiers or give future waves a deterministic world-band selector.

## 4. Sharky Phrase Tier Contract

Tier 1 - Foundation:

- applies to W1-W4;
- tone: warm, direct, short, confidence-building;
- job: reduce fear, name the table clue, make one next rep feel useful;
- no jargon unless already introduced.

Tier 2 - Developing:

- applies to W5-W12 later;
- tone: more precise, vocabulary-confident;
- job: connect concepts like price, position, board, and pressure;
- implemented as deterministic contract copy only, not active W5-W12 expansion.

Tier 3 - Sharp:

- applies to W13-W36 later;
- tone: minimal, peer-level, tactical;
- job: support advanced reasoning without hype;
- documented and represented in the selector contract only, not activated as new content.

Mechanism:

- deterministic curated phrase sets indexed by world band and moment type;
- `act0SharkyCoachTierForWorldNumberV1` maps world numbers to tier;
- `act0SharkyCoachLineForMomentV1` selects by moment and tier;
- no AI, dynamic generation, chat, emotion simulation, or unsupported memory claim.

## 5. Implementation summary

Phrase owner reused and extended:

- `lib/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart`

Active moment types touched:

- Practice current repair prompt;
- Review active repair coaching;
- Session Summary proof fallback remains owned by the contract;
- W1 completion payoff now consumes the phrase owner for its banked-read line.

Copy examples:

- `Run one quick rep while the clue is fresh.`
- `Keep this read warm with one quick rep.`
- `Nice. You found the table clue.`
- `Small win, real proof.`
- `You banked the first table read.`

Tests added/updated:

- phrase tier mapping and forbidden-copy coverage;
- Practice queue Foundation copy;
- Review active repair Foundation copy;
- W1 completion payoff copy through the phrase owner.

## 6. Learner-visible change

Sharky now speaks with more consistent Foundation tone in the active proof/repair loop:

- Practice asks for one quick rep while the clue is fresh;
- Review frames the repair as keeping the read warm;
- Session Summary keeps the compact proof line;
- W1 completion says the first table read was banked.

The change is small by design: Sharky is more structured, not louder.

## 7. Evidence

Focused tests:

- `flutter test test/ui_v2/act0_sharky_coach_phrase_contract_v1_test.dart`
- `flutter test test/ui_v2/act0_play_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_review_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_world1_completion_payoff_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Block summary exposes mastery and suggested next action|World completion summary surfaces unlock and clean progress"`

Screenshot proof:

- `./tools/screen_review_fast_v1.sh first_week compact` passed and regenerated `output/screen_review/current/first_week_fast/`.
- `./tools/screen_review_fast_v1.sh full_scroll compact` passed and regenerated `output/screen_review/current/full_scroll_fast/`.

Static validation:

- `flutter analyze` passed.
- `graphify hook-check` passed.
- `dart format --set-exit-if-changed` on touched Dart/test files passed.
- `git diff --check` passed.
- `git diff --cached --check` passed.

Generated screenshot artifacts remain local-only and untracked.

## 8. Anti-theater proof

This is a deterministic companion-tone system:

- all copy is curated and stored in a source-owned phrase contract;
- selection is by explicit enum moment plus world-band tier;
- Foundation remains the active default for W1-W4;
- future tiers are contract scaffolding, not live W5-W36 expansion;
- no chat, AI, LLM, dynamic generated text, emotion simulation, memory system, or mascot behavior was added.

No line claims mastery, leaks, GTO, solver validation, ratings, levels, radar, premium status, or Sharky remembering everything.

## 9. Context Efficiency Protocol

Followed:

- no broad repo read;
- graphify was queried before broad file reads;
- owner seams were found through graphify plus targeted `rg`;
- large files were opened only around matched sections/symbols;
- generated output directories were not read;
- historical/archive docs were not reopened.

Graphify located `act0_lesson_runner_shell_v1.dart` as a related owner, while targeted search identified `act0_sharky_coach_phrase_contract_v1.dart` as the exact phrase seam.

## 10. Not built

Not built:

- no AI/chat;
- no dynamic generation;
- no mascot bloat;
- no memory system;
- no RPG/XP/levels/rating/radar;
- no monetization;
- no route rewrite;
- no Modern Table changes;
- no W5-W36 content implementation;
- no Store/Public packaging;
- no RU rollout.

## 11. Expected TOP1 movement

Expected movement:

- product soul improves because Sharky has a protected phrase register;
- long-horizon coherence improves because the tier contract matches the 36-world path;
- W1-W4 Foundation tone becomes warmer and more consistent;
- 36-world companion believability improves without persona bloat.

## 12. Actual observed movement

The matrix row moved from compact but flat phrases to a tiered deterministic phrase contract with Foundation copy applied to active surfaces.

Evidence is copy/test/screenshot-packet safe. Emotional lift remains a future reviewer/user-read metric rather than a claimed quantified result.

## 13. Next wave validity

Wave 3.14 - Competitive Wedge Pass v1 remains the next valid route.

Wave 3.13 should not expand into chat, AI, mascot animation, a memory system, W5-W36 content authoring, or broad brand work.
