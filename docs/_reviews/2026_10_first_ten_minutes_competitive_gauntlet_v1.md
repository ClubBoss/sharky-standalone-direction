# First 10 Minutes — Learning × Engagement Competitive Gauntlet v1

Date: 2026-10-08
Status: STAGE1_SOURCE_BACKED_WAVE / PARITY_RUNTIME_NOT_YET_OBSERVED
Authority: Master Plan v4 + APP_WIDE_MONETIZATION_AND_RETENTION_GUIDELINE_v1.
Target: same exact novice, same questions, equivalent iPhone-class device, EN locale, unaided free-entry task; independently record differences in user jobs rather than copying competitor features.
Canonical Sharky baseline: `main bdf560f`, with fixed candidate `PR226 e878623` for any post-fix product execution; both unmerged.
No app code / asset / CI modifications authorized by this packet.

## 1. Five timed waypoints, measured rather than imagined

Start timer at first visible app screen on fresh install. A journey ends at 10:00 or voluntarily earlier. Record:
1. **T0–30 seconds / curiosity:** one-sentence user interpretation of promise; first unaided tap, tap latency, visual focal point and any confusion.
2. **T0–2 minutes / entry friction:** permission/sign-in/account/payment requests, number of meaningful taps/questions and earliest actual poker decision (not generic profile survey).
3. **T2–5 minutes / educational value:** one contextual poker read, pre-choice hidden answer, committed action, causal feedback, error recovery. For nondidactic PVP modes, record that this is a different job, not an automatic FAIL.
4. **T5–8 minutes / emotional progression:** explicit owned accomplishment vs generic XP; invitation to a *distinct* next meaningful challenge; whether a player recognizes improvement without moderator coaching.
5. **T8–10 minutes / free voluntary continuation:** optional next rep chosen without countdown/streak pressure; ability to exit with a meaningful tomorrow return reason; free path still available; record any paywall exposure and restore/cancel disclaimers.

Record **beginner vs experienced placement variants separately**, never average their entry actions before first decision; for the experienced variant the three diagnostic checks ARE decisions but must not be conflated with the first taught challenge. For every waypoint: video/notes if consented, device & exact app version, screenshot at relevant frame, elapsed seconds, task, action, feedback, comprehension, delight/boredom self-report AFTER observation, trust concern, exact free/premium boundary. No PII export.

Critical outcome variables:
- `time_to_first_poker_decision_sec` **observer stopwatch**, NOT current Act0 telemetry ms (source emits only `decisionTimeBucket`);
- `causal_feedback_recall` (open paraphrase without hints);
- `voluntary_second_meaningful_rep` yes/no, not coerced by point reward;
- `novel_challenge_anticipated` yes/no with quoted reason;
- `independent_task_completion` intervention level 0–3;
- `paywall_before_proof` yes/no;
- `decision_repair_transfer` task-specific; if no repair naturally triggered, `NOT_EXPOSED`.

A five-novice formative test is for discovering repeated issues, not statistical product comparison; avoid claiming measured market superiority. If competitors need accounts, consent and legitimate access are prerequisites, no bypass.

## 2. Source-truth route sketch and competing hooks (not runtime observation)

| Product | Actual publicly documented entry hook | First-10-min promise / likely friction to test (inference, NOT observed) | Evidence |
| --- | --- | --- | --- |
| Sharky PR #226 | Native welcome: Sharky Poker, "Find your start", primary bottom CTA. Production `_placementQuestionsV1` defines **2 possible questions**: experience and confidence, not all four questions in the bank. **But they are NOT both universally mandatory:** selecting the explicit beginner option `new` on the first question changes the CTA to `Start from zero` and invokes `onStartFromZero` before the second question. Other users answer both questions and then enter the three-spot quick check; a result screen subsequently offers recommended or from-zero start. `directRunner: true` is used for the post-diagnostic recommended route. | Hypothesis: the learner may spend time scanning a spacious introductory screen before the first decision. Strong direct table route possible; verify real unaided CTA/timing, challenge tension and earned proof comprehension. | Runtime first-screen iPhone16e screenshot `/tmp/sharky_pr226_first_run_iphone16e_20261008.png`; `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` near lines 5210–5260 and 14850; direct only first screen. |
| Poker Skill | Short taught lessons, Daily Puzzle, coached AI games; all lessons free energy-paced, 1 AI game/day. Recent published **2.1.39 Aug 21, 2026** introduced Daily Missions, tailored onboarding puzzles and music continuity (not a release made today). | Test if the coached hints leak the answer before commitment; whether energy creates artificial stopping, whether 2–5 minute mission really has a satisfying conclusion and one obvious follow-up. | https://www.pokerskill.com/features/ ; https://www.pokerskill.com/pricing/ ; https://apps.apple.com/gb/app/poker-skill-learn-holdem/id6748104711 ; reviews at https://apps.apple.com/us/app/poker-skill-learn-holdem/id6748104711?see-all=reviews. |
| WSOP Academy | Short lessons, Poker IQ, challenger/pro identity, global ranks, premium challengers, Daniel Negreanu brand. | Test whether user is taught before tested, can choose practice over aspiration, whether score/rank is actionable or simply thrilling, how soon user makes real table choice. App Store release **1.8.1 Sep 5** offers fresh version history but not a confirmed complete first-run. | https://www.wsopacademy.com/ ; https://apps.apple.com/us/app/wsop-academy/id6762133819 |
| PokerArena | Account-gated head-up game; competitive/casual modes, rank, leaderboard and GTO-linked review. | Distinct job: **live rivalry** may dominate immediate excitement but novice accuracy learning may require after-match explanation. Time-to-first-match & matchmaking wait, casual vs ranked and post-match transfer are key. Don't auto-demand PVP in Sharky. | https://gtowizard.com/pokerarena ; https://blog.gtowizard.com/enter_the_poker_arena_a_new_era_of_competitive_poker_has_begun/ |
| Runout | Adaptive drill/leak marketing, solver-inspired scenario training and skill tiers. | Test onboarding survey -> first taught decision -> pre-proof paywall; reviews report both valuable causal explanation and payment-gate resentment. Review anecdotes are not confirmed current universal first-run behavior. | https://runoutpoker.com/ ; https://apps.apple.com/us/app/runout-poker-trainer-gto-coach/id6760210288 ; https://apps.apple.com/us/app/runout-poker-trainer-gto-coach/id6760210288?see-all=reviews |

**Source discrepancy to adjudicate, not silently resolve:** `gtowizard.com/pokerarena` says in one section every-match analysis is free while a nearby feature description says GTO analysis is available via a subscription. Therefore `POKERARENA_FREE_ANALYSIS_ENTITLEMENT = UNVERIFIED` until a controlled account/test.

## 3. Stage-specific red flags

- A product quizzes the novice before any interpretable teaching and then markets that score as learned mastery.
- A hint tells the correct move before the player has committed.
- A paywall consumes survey/account setup time before showing substantial actual value.
- A generic reward event substitutes for the player's own ability to state one corrected clue.
- Repetitive drill path creates no more interesting challenge after the first mini-session.
- Learner must fight a hidden/dead CTA, blank state, or unresumable exercise.
- Endless engagement through guilt/energy scarcity is misclassified as real retention.
- Competing task types are treated as equivalent just to force a 10/10 ranking.

These are falsifiable checks, not accusations about each competitor. Code quality, marketing volume, download/rating count, and brand fame cannot certify effective education.

## 4. Product-owned route evidence before any attack

Current Sharky source:
- **Two different first-run paths:** self-declared complete beginner: intro → select experience `new` → `Start from zero` (skips the other question and the placement diagnostic) → a possible first-run Welcome interstitial → initial lesson. Experienced/casual: intro → experience and confidence answers → three poker quick-checks → placement result → recommended route → possible first-run Welcome before runner. Four questions exist in the bank but only experience and confidence are in active selection. This nuance comes from `act0_placement_shell_v1.dart:259-267,384-405`, `act0_shell_preview_screen_v1.dart:5235-5262,9295-9358,14850-14864`. No elapsed-time observation yet.
- Placement callback offers direct runner handoff. This is a source capability, not a timed proven experience.
- One native iPhone 16e opening frame shows welcome proposition and visible CTA. It does not validate taps or next scenes.
- Existing Act0 daily 3-rep, calendar-spaced review, personalized return reason and post-value premium preview are already implemented source owners.
- A prior P01 human attempt found actionability concerns; W3 exact PR226 suite has 39 pass / 5 fail older assumptions, including real spacing gaps. Do not call full end-to-end green.
- The PR226 earned-proof visual patch is in Draft/unmerged. Do not test competitor parity against baseline main while claiming it contains the new proof.

A high-impact improvement **might** be to shorten time-to-first-compelling-table-decision or make the earned correction more emotional; both remain `TEST_HYPOTHESES`, not `IMPLEMENT_NOW`.

## 5. One bundled evidence collection wave — execution itinerary

**Pass A — official/source evidence now:** verified feature hooks and conflicting claims, route source tracing (this document); no simulator or subscription needed.
**Pass B — Sharky native runtime evidence:** use existing isolated fixed PR226 iPhone16e build; record exact time/taps to first table decision, first feedback, earned proof, first voluntary next rep and exit. Test external blank-start only after preserving exact build/seed conditions. No screenshot-driven visual iteration.
**Pass C — direct competitor parity:** legitimate installs/accessible browser flows; same device class/locale/novice operator; no subscriptions purchased without separate approval. If access unavailable, label missing rather than substituting marketing.
**Pass D — five real novice observers:** experiment with already-approved moderator script; 0–3 intervention levels; add engagement observation only, don't insert leading fun questions during the action. The early pilot is NOT P02.
**Pass E — bottleneck attack admission:** choose *one* high-incremental-EV learner × fun failure with Human or proven runtime evidence, clean reversible PR, native smoke, focused tests, challenger falsification. Any score remains a prioritization aid, not a release gate.

## 6. Stop/go matrix

| State | Action |
| --- | --- |
| Competitor evidence only C/D (marketing/reviews) | Document unknown and request/arrange real walkthrough; NO implementation |
| Sharky route machine passes but Human independent action fails | One bounded UX/continuation fix if observed |
| Human completes route but does not understand proof | Causal teaching/receipt quality attack |
| Human understands but does not choose second rep | Challenge/pacing/delight attack, preserving correctness |
| User repeats but no unseen transfer | Learning engine/context transfer attack, not more streaks |
| Human returns meaningfully D7 but refuses paid value | Paid depth/content/entitlement research downstream |
| Strong positive evidence and no blocker | `NO_IMPLEMENT_NOW` and advance to next valid evidence; don't fabricate a gap |

Final non-claims:
`COMPETITOR_DIRECT_PARITY = NOT_OBSERVED`
`SHARKY_NATIVE_FIRST_SCREEN = PASS`
`SHARKY_NATIVE_FIRST_DECISION = NOT_YET_TIMED`
`FIRST_10_MIN_USER_ENGAGEMENT = UNMEASURED`
`ATTACK_WAVE_NEW_CODE = NOT_ADMITTED`
