# Competitive North Star Gauntlet — Baseline + Scoring Contract v1

Date: 2026-10-08
Status: STAGE_0_EXACT_GITHUB_RECONCILED / STAGE_1_PUBLIC_RESEARCH_PACKET / STAGE_2_SCORECARD_METHOD_PROPOSED
Authority: `docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md` on current canonical main.
This is a **proposal/research companion**, not a change to Master Plan v4, not P02 admission, not product implementation and not license to reopen frozen visual families.

Research source: `docs/_reviews/2026_10_competitive_landscape_evidence_v1.md`.

## 0. Verified exact GitHub baseline (not a release claim)

Repository `ClubBoss/sharky-standalone-direction`.
Main confirmed via all three PR bases: `bdf560f0d90d9659335f6492149c373842f655b1`.
- PR #224 — `bd2046e7470f6aa3137e3a9354b5155528d99e25`, OPEN, unmerged; V4R1 actor art parked.
- PR #225 — docs-only owner mechanics-first wave tracker, OPEN/DRAFT/unmerged. Holds W1–W4 policy audits and a pilot preflight.
- PR #226 — `e87862309817f2f27f9db8bb51afbfd118f8310f`, OPEN/DRAFT/unmerged; exact-head own GitHub Actions for Health, Theory Integrity, R5 release gate, Test Authority Lanes, Web QA Mirror passed; conditional L2 skipped. Independent TestSprite reports `No tests detected`, not an owned green test.
- PR #226 resolves missing earned proof in scene-owned source recheck at the widget level, not actual Human knowledge transfer.
- Independent exact-PR226 route cone: **39 passed / 5 failed**; 3 legacy widget/copy/location assumptions, 2 measured table-to-feedback/action gaps (94.12 / 143.12 logical px). Do not hide FAIL or assert full-route green.
- Human P01 previously encountered interaction/continuation failure and triggered an actionable stop; later machine evidence must not be substituted for fresh Human validation.
- Unmerged code/doc PRs are **not** baseline main and do not automatically change product claims.
- Protected dirty Mac checkout `/Users/elmarsalimzade/Sharky_1.0` is excluded from any operations.

## 0A. Independent exact-SHA native launch smoke (after research baseline)

An earlier isolated Mac iOS build completed during this research pass, so one **targeted** Desktop Commander check was justified despite GitHub-first policy:
- Exact `PR #226 HEAD = e87862309817f2f27f9db8bb51afbfd118f8310f`;
- Xcode 26.2, Flutter iOS Simulator Debug build `EXIT_CODE=0`, build time ~575 seconds; installed `Runner.app` (`com.example.pokerAnalyzer`) on iOS 26.2 **iPhone 16e Simulator**;
- `simctl launch` succeeded and a local-only first-screen PNG was captured:
  `/tmp/sharky_pr226_first_run_iphone16e_20261008.png`;
- Visually inspected screenshot: branded `Sharky Poker` welcome, starter tile `Find your start`, footer explanatory line and primary `Find my start` CTA are visible, with no clipping/blank screen/crash on this frame;
- The central part of the screen contains a large empty field in this screenshot. Its effect on perceived fun/quality is an **unverified observation**, NOT permission for screenshot-driven cosmetic repair.

This is `NATIVE_FIRST_SCREEN_SMOKE_PASS` ONLY. No tap/navigation, subsequent lesson, payment, error repair, Human comprehension, competitor app or Day-2 return was examined through this screenshot. Do not upgrade broader UI or P02 claims.

## 1. Product differentiation and evidence hierarchy

Preserve exact Master Plan v4 product promise:
> The poker coach that turns mistakes into corrected table instincts.

Canonical chain:
`SEE -> DECIDE -> UNDERSTAND -> REPAIR -> PROVE -> TRANSFER -> RETAIN`.

Add a **parallel evaluation lens**, not a fake new engine:
`DESIRE_TO_START -> ENJOY_DECISIONS -> WANT_NEXT_REP -> RETURN_WITH_PURPOSE -> VALUE_WORTH_PAYING`.

The learner chain is not effective merely because its functions exist. The engagement chain is not effective merely because XP/streak/plays are frequent. A Sharky 10/10 requires BOTH learning integrity and durable voluntary involvement.
No artificial sunk cost, punishment for skipped days, hidden paywall, gambling-style reward schedules, or deliberate session prolongation. Prefer challenge/skill fit, meaningful variable *problems* (not manipulative variable reward), earned surprising insight, clean pacing, and a clear reason to practice tomorrow.

Evidence types are NOT fungible:
`MACHINE_PROVEN` != `HUMAN_PROVEN` != `LONGITUDINALLY_PROVEN` != `MARKET_PROVEN` != `REAL_POKER_PROVEN`. The v4 rule explicitly forbids a single aggregate readiness score from replacing evidence class. All weighted scores below are **decision aids only** and CANNOT produce a green admission.

## 2. Same-scenario rubric for Sharky and each competitor

When adequate evidence arrives, give each dimension an explicit observation, score (0–10), confidence (A–E), segment, free/premium context and source. Until then write `UNKNOWN`, not `0` or invented averages.

| Dimension / proposed priority weight (not fixed authority) | What 10/10 would require | Earliest valid evidence |
| --- | --- | --- |
| Learning / independent clue recognition (part of 25%) | novice independently sees correct causal signal prior to hints | blind Human SEE observations |
| Learning / repair, unseen transfer and recall (rest of 25%) | correct after repair with lower scaffold, resolves different held-out spot, retains after elapsed time | Human same-signal + genuinely unseen tasks + D2/D7 |
| Fun / decision satisfaction (part of 20%) | player enjoys decision itself; helpful tension; no boredom/fatigue spike | participant enjoyment + voluntary continuation |
| Fun / escalating variety and challenges (rest of 20%) | differentiated 2/5/15-minute reps and meaningful challenges matched to skill | repeated-session Human observations |
| Habit / voluntary return (part of 15%) | reopens to address a named skill goal, not guilt | D1/D7/D30 behavioral cohorts |
| Habit / return usefulness over weeks (rest of 15%) | next session gives tailored useful novelty and spaced memory repair | follow-up cohort incl. D7 |
| Personalization (10%) | weak spot improves more than generic controls, format preference honored | randomized/cohort comparisons and skill trace |
| UX & premium polish (10%) | fresh user independently completes first loop on compact phone; responsive/accessible | direct on-device + novices |
| Poker correctness & honest claims (10%) | independently validated poker decisions + scenario assumptions, no invented GTO/EV claims | poker SME audit + deterministic test fixtures |
| Commerce & long-term perceived value (10%) | meaningful free value, clear post-value premium depth, safe checkout, legitimate continued payment | completed real purchase/restore + churn and willingness-to-pay |

Practical scoring anchors per dimension:
- 0–2: blocker / incorrect / unavailable;
- 3–4: function exists but learner cannot independently use it or no value;
- 5–6: coherent minimal capability, inconsistent experience;
- 7–8: good repeatable experience under evidence with known constraints;
- 9: strong direct independent evidence, minor bounded gaps;
- 10: target segment independently demonstrates repeatable best-in-class outcome, with adequate sample and no hard blocker.

Never infer 10/10 from App Store rating, screenshot aesthetics, "AI" label, lesson count, XP count, product claim or one enthusiastic interview. Comparisons must use the **same learner archetype and task**. Not every mature solver/courses platform is direct novice-mobile competition.

## 3. Baseline Truth Map — preliminary, not numeric quality claims

| Area | What repo/test evidence supports | NOT proven | Next needed |
| --- | --- | --- | --- |
| Correct answer/causal feedback | Source-owned deterministic learning policies and selected tests pass on exact baseline | all poker content mathematically correct / novice understands | independent poker spot corpus + Human UNDERSTAND |
| Repair/recheck and earned payoff | 70 selected learning tests green; separate PR #226 fixes a real missing proof visibility bug with 105 selected gate tests | fresh real-user improvement and generalized transfer | accept PR #226 and fixed-candidate novice observation |
| Revisit / Review / personalization | due Review, retention and next-step machine contracts exist and passed selected lanes | user finds route by themselves, perceives it useful days later | observational early pilot and D2/D7 return |
| First ten minutes | canonical Act0 onboarding exists and old P01 found P1 actionability/continuation issues | fresh post-fix Human autonomous success | new frozen SHA Human 5-person pilot |
| Enjoyment / anticipation | progression and return motifs exist in strategy; implementational truth needs source/runtime audit | voluntarily choosing next rep, fun ratings, boredom and flow | actual first 10 minutes + repeated-session interview |
| Habit / week 2–4 | retention timing and spaced-review policy documented | D7/D30 cohorts or genuine repeat use | real cohort telemetry, delayed check-ins |
| Premium value | monetization SSOT requires W1-W4 free, W5+ depth, paid value after proof | production purchases, free-to-paid conversion, renewals | price/entitlement implementation and market study |
| V4R1 cinematic art | archived proof pack and PR #224 exist, separate unfinished visual family | production exact-head visual acceptance | dedicated art final wave, NOT present Gauntlet stage |

Any historical product numeric scoring (e.g. prior 7.x/8.x) is a context-bound hypothesis, **not** current market-relative proof.

## 3A. Stage 2 direct active-source implementation sample (GH exact-main audit)

This is a **code inspection of the current Act0 shell**, not an in-app Human assessment or evidence that every rendering path is visible. It materially improves baseline truth beyond design documents:

- **Daily micro-rep and streak state — implemented.** `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart:1156-1160` holds daily task/rep and streak fields. `_persistProgress` around lines 3817-3843 counts a day as done at >=3 daily reps, persists streak days, and branches for consecutive calendar days; restore logic around lines 3483-3491 reconciles last-active day. **Unproven:** enjoyment, adherence, habit pressure, D7 retention or real device daily rollover.
- **Learner-facing daily continuation — wired.** Current Home construction near 5324-5354 passes a daily goal, daily plan, 'next useful hand' reason and source-owned `personalizedReturnReasonLine`; the active daily-drill launcher around 5392-5415 uses 3-rep daily completion. Source near 6862-6895 presents `Done for today` / `Streak saved` and tomorrow-focused copy rather than random rewards. **Unproven:** independent novice comprehension and desire to reopen.
- **Personalized return contract — source-owned.** `lib/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart:48-85` prioritizes active repair → failed repair retry → due Review → reinforce transfer → recent focus → safe fallback. It reuses existing contracts rather than a resurrected ML planner. **Unproven:** personalization uplift over generic lessons.
- **Calendar-based durable review — source present.** `lib/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart:56-87` exposes `refreshedAt(DateTime nowUtc)` and `dueItemsAt(DateTime nowUtc)` based on `nextDueAtUtc`. This is stronger than a mere click-count placeholder, but **not** proof the learner retains after D2/D7.
- **Premium preview is an informational, secondary surface.** `lib/ui_v2/act0_shell/act0_premium_preview_v1.dart:80-145` explicitly marks 'Free right now', 'Premium adds later', 'Stay on free route', and a 'Not now' exit. **Unproven:** actual purchase/restore/trial safety or willingness to pay; public checkout intentionally deferred by monetization SSOT.
- **The broader repo has legacy streak widgets.** Generic code search returns `lib/widgets/streak_*`, but those are **not** evidence that the active Act0 path renders them. This audit relies on the active `act0_shell` owner, not legacy artifact count.

Implication for wave selection: **do not create a new streak, daily-goal, calendar review or personalization subsystem on the assumption that Sharky lacks it.** The likely missing evidence is real *experience quality and learning effect* of already wired mechanics. Ask humans whether 3 reps is satisfying, if they perceive a compelling optional next challenge, and whether Review is useful tomorrow. Only then attack a demonstrated seam.

## 3A.1. Welcome is already an interactive learning micro-win (CURRENT source wins over old audit)

A June/July historical PIEC claimed no pre-lesson interactive micro-aha, but a later implementation was already accepted and `main` still includes it. `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart:12-13,33-62,80-136` now renders three beats `intro → demoSpot → handoff`, with `Act0LessonRunnerShellV1` using the existing W1 `fold_check_call_raise/actions_check_drill` and real choice/feedback. The micro-win intentionally earns no fake XP, task completion, repair debt or mastery.

This source fact **supersedes** the older `docs/_reviews/welcome_placement_micro_aha_alignment_piec_v1.md` conclusion at historical SHA `86512b2`. `docs/_reviews/archive/2026-07/welcome_first_micro_win_alignment_v1.md` documents the later change; don't reimplement it. Its user enjoyment, comprehension and downstream retention remain **UNMEASURED**.

Independent exact-head PR226 local Mac Flutter test evidence for this wave:
- four active activation suites: **39/39 PASS**;
- adding `act0_p3_split_e2e_v1_test.dart`: **40 PASS / 2 FAIL** (both old lesson-tile location expectations, not an established new product bug). Record the full extended suite as FAIL, do not hide or force obsolete widgets back;
- files/logs unchanged except ignored local logs; Flutter generated macOS registrant restored in isolated checkout.

This means the next high-EV challenge is **whether the existing Welcome decision feels like a meaningful, interesting achievement**, not inventing another intro mini-game or redoing the screenshot pipeline. See `docs/_reviews/2026_10_competitive_engagement_attack_wave_bundle_v1.md`.

## 3B. Important existing telemetry/protocol mismatch (not a reason to broaden app scope)

Source checked, not guessed:
- Current `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart:1858-1868` defines **`decisionTimeBucket`** (`under_3s`, `3_to_10s`, `over_10s`, `unknown`), emitted on choice/result. The active runner does **not** emit exact `time_to_decision_ms`.
- The current `docs/plan/ACT0_TELEMETRY_TRUTH_MAP_v1.md:35-45` explicitly says exact decision milliseconds are not emitted and prohibits raw copy/identity and external analytics.
- Older `docs/_reviews/human_novice_proof_preflight_v1/TELEMETRY_MAPPING.md:7` asks for `time_to_decision_ms`. It predates this privacy-preserving active projection; treat it as a **stale field expectation**, not proof the event is absent.
- For the early observed pilot, record exact elapsed time by observer stopwatch/consented recording **separately from** existing local safe event bucket. Do not alter the active privacy contract just to generate millisecond analytics; reconcile the human protocol when formally admitting it.
- Commercial renewal, D7 and engagement funnels have **no established production remote analytics proof**. Avoid claiming WAIL can already be computed from existing on-device local HNP 256-event capture.

This mismatch matters because a dashboard made from non-existent precision fields would create false experimental confidence. The next wave must distinguish observed raw timing (Human scorecard), safe event bucket (machine), and hypothetical future aggregate cohort analytics (not instrumented).

## 4. Hypothesis stack from desk research (rank ≠ authorization to code)

Candidate bottleneck families; each requires actual baseline observation and comparative proof before `IMPLEMENT_NOW`:

**H1 — first 10 min intrinsic motivation and clue control**
Poker Skill uses short lessons/daily puzzle while WSOP Academy provides challenge/identity. Sharky may have the mechanics but not enough self-directed delight; test with 5 unaided novices, fixed first route, reward-neutral baseline. Potential attack: more distinct pedagogical challenge rhythm / earned surprise in ONE tested seam, not confetti or new rewards architecture.
Evidence confidence: LOW-MEDIUM from competing public surfaces; Sharky enjoyment unmeasured.
Potential impact: HIGH if start abandonment is observed. Build scope: UNAUTHORIZED until result.

**H2 — corrected-insight payoff consistency**
Runout reviews praise *why* explanations, and Sharky PR #226 found one real case where visible earned proof was missing. Need verify proof remains visible AND is understood and remembered under real Human use.
Evidence confidence: HIGH product-bug proof, LOW Human impact. Next: Human causal paraphrase + next action.

**H3 — challenge variety without curriculum inflation**
PokerArena ranked adversary and WSOP celebrity challenges create replay anticipation. Sharky long-horizon strategy already provides 36-world identity; use selected checkpoints or held-out challenges ONLY IF observed boredom/repetition bottleneck. Do not build PVP, leaderboards, matchmaking or 36-world expansion by imitation.
Confidence: MEDIUM competitor packaging, LOW Sharky bottleneck.
Potential engagement impact: CONDITIONAL.

**H4 — value-before-subscription and format commitment**
Runout reviews describe pre-trial paywall friction and preference-mismatch anecdotes; Poker Skill advertises free core plus optional practice depth. Sharky's monetization SSOT already locks W1-W4 free and W5+ future premium. Protect this trust differentiator; benchmark actual free/paywall experience before proposing changes.
Confidence: MEDIUM store/reviews, LOW actual current checkout; commerce not authorized.

## 5. Gauntlet operating protocol — large safe waves, one bottleneck

STAGE 0 (this packet): exact code/PR source and non-claim reconciliation; GREEN for GitHub metadata only. Native iOS fresh candidate smoke is an additional ongoing evidence task, not silently passed.
STAGE 1 (this packet): primary and adjacent competitor public research; `DESK_PASS`, actual app parity `PENDING`.
STAGE 2 (this packet): same-scenario rubric and backcast candidates; `METHOD_READY`, final Sharky-vs-competitors scores `BLOCKED_ON_DIRECT_EVIDENCE`.
STAGE 3: BOUNDED EARLY HUMAN mechanics **and engagement** diagnostic on frozen exact learner path, optional pending admission, NOT full P02.
STAGE 4: one **largest safe bounded attack wave** selected by demonstrated incremental EV (user impact × confidence × addressable learner frequency minus regression/cost). One owner family, several independently reviewable small PR if needed.
STAGE 5: D2/D7/D30 return, unseen transfer and durable improvement: cannot be claimed before real elapsed time.
STAGE 6: premium/paid value and trust **after** proven free value and retention; commerce only within monetization SSOT.
STAGE 7: deferred final art (PR #224 + engaged/disengaged cast variants) and premium shipping acceptance; reopen only for real input affordance blocker earlier.
STAGE 8: fixed exact-SHA beta, release safety and continuing competitive challenge.

A wave can only be ACCEPTED if:
1. Claim/impact measurable in the target user, with before and after comparison;
2. Product safety and deterministic correctness maintained;
3. Appropriate machine test cone and exact-head CI pass (old known failures remain recorded);
4. Evidence class supports the claim; no Human outcome claim from CI;
5. Falsifying challenger asked what worsened (attention, answer leakage, fun, speed, device, fairness, privacy, trust);
6. `DIMINISHING_RETURNS` and `DO_NOTHING` explicitly allowed.

## 6. Funnel and telemetry measurement (proposed, no fake operational claims)

Product north-star research metric:
`Weekly Active Improving Learners (WAIL)` = learners with >=1 voluntary **meaningful** training session this week AND independently observed improvement on a held-out or later-repeated skill. **Not yet instrumented or market measured.** Keep it as a research lens until data model + privacy/consent/QA exist.

Parallel guardrails:
- `First Decision → First Understood Feedback → First Independent Recheck` route completion (independent vs moderator-assisted).
- `Next Rep Voluntary Start` and enjoyable challenge score, measured **without pressure prompts**.
- Time-to-decision + correctness, error_type and user_choice in exact task flow (do not collect identity).
- D1/D7/D30 return with meaningful work, not mere app open.
- Held-out transfer accuracy and retention accuracy after elapsed time.
- Subscription start / restore / cancellation / renewal and actionable churn reason, only once real commerce exists.
- Negative signals: forced completion, hints revealing choice, decision fatigue, redirection away from true weaknesses, notification pressure, paywall before proof.
- Avoid conflating app engagement minutes, streaks, XP or downloads with value/retention and avoid a single blended score masking fatal deficiencies.

First Human sample of five is for **formative defect discovery only**, not statistical conversion/retention inference. No arbitrary pass percentages until baseline distributions and sample sizes are observed. Later experiments should control learner level, device, locale, scenario difficulty, and cohort selection.

## 7. Explicit SSOT precedence and unresolved routing questions

Master Plan v4 wins. Its current canonical exact pre-P02 stage is preserved.
`TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` is subordinate strategy context with historical/older launch-stage labels.
`APP_WIDE_MONETIZATION_AND_RETENTION_GUIDELINE_v1.md` controls offer timing:
W1-W4 free, future W5+ depth, no hard paywall before tangible value, no manipulative streak traps.
Existing staged PR #225 is the owner mechanics-first movement and PR #226 the unmerged proof repair; this research does not merge or bypass either.
No change to `PRE_HUMAN_CAMPAIGN_STATE_v1.md` in this research branch, to prevent competing concurrent dispatch overlays.

**Before an execution wave begins**, reconcile exact main/PR heads and explicit owner's acceptance of candidate. No speculative current UI grades, new engines, broad content expansion, art redesign, public checkout or competitor asset copying.

## Exit state

`STAGE0_GITHUB_TRUTH = DOCUMENTED`
`STAGE1_COMPETITOR_DESK = INITIAL_COMPLETE`
`STAGE1_COMPETITOR_RUNTIME = PENDING`
`STAGE2_SCORE_RUBRIC = PROPOSED_READY`
`STAGE2_FINAL_COMPARATIVE_10_10 = UNKNOWN_NOT_ADMISSIBLE`
`ACTIVE_NEXT_EVIDENCE = FIRST_RUN_PARITY_AND_EARLY_HUMAN_INVOLVEMENT`
`NEW_PRODUCT_CODE = ZERO`
`HUMAN_PROOF = FALSE`
`LONGITUDINAL_PROOF = FALSE`
`MARKET_PROOF = FALSE`
