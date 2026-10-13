# SHARKY — INDEPENDENT RETENTION, REWARDS & COMPETITIVE MECHANICS RESEARCH V1

**Status:** `READ-ONLY / PREPARATORY RESEARCH / EVIDENCE_LIMITED`  
**Verification date:** 14 October 2026 (Asia/Baku)  
**Repository:** `ClubBoss/sharky-standalone-direction`, `main` (connected GitHub read-only inspection)  
**Scope:** motivational progression, XP, achievements, rewards, retention, learning transfer, return behavior and premium interaction. No design, code, branch, CI, issue or roadmap changes.

> **Central research question:** What is the strongest evidence-informed, lowest-complexity motivation and progression model for Sharky?

## A. Executive verdict

**Verdict: `REFINE` the existing motivation/reward presentation; `KEEP` its source-owned learning foundation; `DEFER` new habit/economy systems. No implementation admission.**

The best current hypothesis for Sharky is **evidence-first motivation**: a novice understands a real mistake, receives constructive support, makes a genuinely independent subsequent decision, sees exactly what was and was not established, and is offered **one justified next useful action**. Compact earned acknowledgements can help users notice progress; XP may remain secondary, but must not act as a proxy for mastery. An independent 24-hour/72-hour/7-day review and a materially different transfer spot are stronger *learning claims* than a daily-login sequence.

Across 14 products, **skill-relevant next practice** is the most transferable design convention: Chessable's spaced recall, Chess.com's themed puzzle training, Aimchess's weakness targeting, PeakGTO's leak-to-drill-to-lesson link and GTO Wizard's performance breakdown. Points, streaks and badges can make participation more salient (Poker Skill, PeakGTO, Duolingo, Brilliant), but their **product-specific effects on independent retained poker skill are not publicly demonstrated**. A widely cited Duolingo vendor A/B test measured **retention of app use**, not language proficiency or poker transfer. An independent gamification meta-analysis finds learning gains across heterogeneous interventions; it does not identify a Sharky-optimal XP design.

**Evidence confidence:** high that feedback/retrieval/spacing are plausible general learning mechanisms; medium that honest source-backed progress and a single next action are good interface choices; low that any added reward increases Sharky's voluntary D7 retention or willingness to pay; **none** for a causal Sharky-specific increase until appropriately measured. No percentage uplift or engineering-hour estimate is defensible from these sources.

**Decision order:** use **M0 (minimal evidence-first, no new gamification)** as the baseline and null hypothesis; preserve existing bounded **M1** presentation where it is demonstrably helpful; consider **M2** only as a clearer *consumer of already-owned skill evidence*, not a new level engine. **M3** and **M4** are not justified for admission. Doing nothing is an admissible winning outcome.

**Governance:** Source-of-truth checks find `S11` still active on 13 October, with `S12.V` visual trust next, P02/Human not admitted. These findings neither change this sequence nor authorize intervention in S11, protected Modern Table, PR #224 or upcoming Human gates.

## Research method, classification and limitations

- **Selection:** 14 examples with informative contrasts, not a popularity ranking. Poker first, then chess/cognitive education, then habit/coaching. Existing 13-product cross-industry analyses were used only as context; the new investigation specifically probes missing proof of *why returns happen*, whether rewards correspond to independent skill and premium economics.
- **Source hierarchy:** active repo source and owner-adopted SSOT; identifiable current official feature/help pages and dated release notes; independent academic research; historical vendor experiments; anecdotal user reports only as hypothesis generators. **Public product documentation is not an independent audit of an installed build.**
- **Claim classes:** `VERIFIED CURRENT (PUBLIC DOC)` = live identifiable official material available on verification date, not an app-binary test; `VERIFIED HISTORICAL` = dated past experiment/feature; `VENDOR CLAIM` = supplier claims performance, adaptive quality, learning efficacy or business outcomes; `INDEPENDENT STUDY` = separate population/experiment, not necessarily app users; `USER EXPERIENCE` = anecdote; `HYPOTHESIS` = Sharky transfer inference; `UNKNOWN` = not established.
- **Retention data:** Unless specifically qualified for Duolingo below, a product's measured D1/D7/D30 retention, causal benefit of gamification, revenue impact and learning-transfer uplift are **NOT DISCLOSED** in examined public sources. No paid-internal analytics or private account metrics were accessed.
- **Freshness:** official pages were checked on **2026-10-14**; some describe historical experiments, and no claim is made that a UI flow was personally installed or exercised. Links are provided at the claim's point of use.

## B. Competitive benchmark matrix — 14 products

**Verification for every row: 2026-10-14.** `NOT DISCLOSED` applies to measured product retention, premium conversion and independent learning impact unless noted. Dates in parentheses distinguish historical source publication from current public documentation.

| Product / category | Documented relevant mechanics | Evidence class / limits | Risk and Sharky relevance | Primary source |
|---|---|---|---|---|
| **1. Runout** — direct poker | Offline poker drills, leak detection and **12 skill tiers**, reportedly adaptive to assessed decisions. Specific daily reward/streak mechanics not substantiated in this pass. | `VERIFIED CURRENT (PUBLIC DOC)` for feature advertising; **adaptive effectiveness and measured outcome = VENDOR CLAIM / UNKNOWN**. | High comparator on progression/weakness narrative; beware algorithmically asserted “tier = true skill.” Existing Sharky Runout APK research does **not** prove runtime adaptation/paywall or improved learning. | [Runout official](https://runoutpoker.com/), [about and tier claims](https://runoutpoker.com/about) |
| **2. Poker Skill** — direct poker | Short lessons and explain-why feedback, Daily Puzzle, AI-hand review with grades, **XP for lessons/puzzles/games**, streak credit after lesson or puzzle; lessons use refillable energy, Plus removes friction and adds practice/archive access. | `VERIFIED CURRENT (PUBLIC DOC)`; reported benefit of XP/streak = **NOT DISCLOSED**. | Strong comparison for first value/premium access; risk of optimizing XP/day, energy friction and puzzle habit instead of difficult independent repair. | [Poker Skill features](https://www.pokerskill.com/features/), [pricing](https://www.pokerskill.com/pricing/) |
| **3. GTO Wizard** — poker study/trainer | Saved drill setups; performance stats and **EV loss per 100 hands**, accuracy by position/street, in-hand context, change/rethink action. Public evidence here does not confirm any XP or daily-streak system. | `VERIFIED CURRENT (PUBLIC DOC)` — feature changes in dated **27 July 2026** release notes; true live fidelity and transfer not independently tested. | Strong **diagnosis → repeat relevant spots** model; danger of advanced statistics intimidating Sharky's first-time users, and solver score being mistaken for real-life EV. | [GTO Wizard 27 Jul 2026 patch notes](https://blog.gtowizard.com/plo-upgrades-custom-hu-solving-postflop-icm-nodelocking-more/) |
| **4. PokerCoaching / PeakGTO** — poker ecosystem | **Course → graded leak identification → relevant drill → course recall**, daily missions with XP, daily drills, Elo and leaderboards, badges/titles/cosmetics, paired premium content. | `VERIFIED CURRENT (PUBLIC DOC)` for marketed features; benefit, scale and “Elo proves better play” = `VENDOR CLAIM` not external validation. | Best **causal link back to lesson** reference; premium tier and reward economy are much heavier than Sharky's validated needs. | [PeakGTO / PokerCoaching](https://pokercoaching.com/peakgto/) |
| **5. Chess.com** — adjacent decision skill | Rated puzzles plus targeted themes, wrong-answer feedback, timed Puzzle Rush, streak-like daily modes, performance/rating signals, premium puzzle capacity. | `VERIFIED CURRENT (PUBLIC DOC)`; mastery/transfer from ratings = **NOT DISCLOSED**. | Theme-specific repairs transfer conceptually; speed runs/rating obsession could incentivize guessing rather than reading the table. | [Chess.com puzzle help](https://support.chess.com/en/articles/8608686-how-do-puzzles-work-on-chess-com) |
| **6. Chessable** — memory of decision patterns | **MoveTrainer** repeated retrieval with progressively spaced review intervals, incorrect variations re-enter review, course/repertoire progress; re-review is explicitly linked to previous work. | `VERIFIED CURRENT (PUBLIC DOC)` for help article (historical publication date not itself proof of 2026 app build); long-term poker transfer = `UNKNOWN`. | One of the strongest *purposeful return* analogues, with caveat that repeated exact lines can produce memorization without unseen transfer. | [Chessable review timing](https://support.chess.com/en/articles/10319267-when-will-the-variations-be-ready-for-my-review), [2026 repertoire update](https://www.chess.com/blog/Chessable/chessables-new-repertoire-feature-turns-you-from-active-learner-to-architect-of-your-chess-growth) |
| **7. Aimchess** — adjacent chess coach | Connected-game analysis, weaknesses and individualized lessons/puzzles centered on detected deficiencies. XP/streak specifics not verified. | `VERIFIED CURRENT (PUBLIC DOC)` for feature positioning; individualized effectiveness = `VENDOR CLAIM / UNKNOWN`. | Strong reason-to-return template: “You missed this kind of decision; practice it,” with no need for generic tasks. | [Aimchess](https://aimchess.com/) |
| **8. Brilliant** — cognitive learning | Interactive problem solving, progress, daily streaks, streak-charge recovery, recommended lessons, subscription for more access. | `VERIFIED CURRENT (PUBLIC DOC)` in updated public help; efficacy of streak charge = **NOT DISCLOSED**. | Low-friction continuation is useful; streak insurance and daily requirements would divert effort from Sharky's corrective learning unless validated. | [Getting started](https://brilliant.org/help/using-brilliant/how-do-i-get-started-on-brilliant/), [streak description](https://brilliant.org/help/features/what-is-a-streak/) |
| **9. Elevate** — adaptive cognitive trainer | Personalized **Today workout** and difficulty adjustment based on performance, training statistics, streak calendar; free daily workout versus paid breadth/details. | `VERIFIED CURRENT (PUBLIC DOC)`; real-world cognitive transfer and feature-attributable retention = `UNKNOWN`. | Low decision cost and predictable sessions; beware training the app's test format rather than poker skill. | [Elevate starting workout](https://support.elevateapp.com/hc/en-us/articles/4402930765595-Where-do-I-start), [free vs paid](https://support.elevateapp.com/hc/en-us/articles/4402930775835-What-s-included-in-the-free-version-vs-the-upgraded-version) |
| **10. Mimo** — coding practice | Guided learning path, interactive exercises and **buildable coding projects** as outcome evidence; subscription adds learning scope. Specific 2026 XP/streak terms were **not established** in examined source. | `VERIFIED CURRENT (PUBLIC DOC)` for projects/path; `UNKNOWN` for exact rewards and impact. | Projects resemble Sharky's meaningful transfer checkpoints: **can independently do the task** matters more than app points. | [Mimo official](https://mimo.org/) |
| **11. Duolingo** — habit/language | XP, daily lesson streaks, streak protection and progress/quests; historical vendor A/B separated daily goal from streak, simplifying what counts as a day. | `VERIFIED CURRENT (PUBLIC DOC)` for features; **`VERIFIED HISTORICAL / VENDOR EXPERIMENT`** for uplift (see §C); does not measure poker or language mastery. | Useful low-pressure lesson from reducing streak friction; high risk of compulsion, farming and confusing app attendance with ability. | [Improving the streak (2020)](https://blog.duolingo.com/improving-the-streak/), [current product guide](https://blog.duolingo.com/duolingo-101-how-to-learn-a-language-on-duolingo/) |
| **12. Finch** — supportive habit coach | Completing personally chosen goals yields companion **energy** and **Rainbow Stones** for customization; can pause/snooze a goal. No direct assessment of cognitive mastery. | `VERIFIED CURRENT (PUBLIC DOC)` mechanics; business/behavior effect = **NOT DISCLOSED**. | Gentle emotional response to small wins may help Sharky repair, but a currency/pet economy creates major scope and motivational displacement. | [Goal completion](https://help.finchcare.com/hc/en-us/articles/37779940291213-Creating-and-Completing-Goals), [energy versus stones](https://help.finchcare.com/hc/en-us/articles/37780134479757-Energy-vs-Rainbow-Stones) |
| **13. Strava** — activity and social proof | User-selected challenges, real-activity completion badges and trophy case; social comparisons for activity performance. | `VERIFIED CURRENT (PUBLIC DOC)`; skill-transfer and retention causality = **NOT DISCLOSED**. | Recognition tied to externally completed activity is a better metaphor for authentic achievement than tapping a badge; social comparison is poor default for Sharky novices. | [Challenges](https://support.strava.com/en-us/articles/15401916-strava-challenges), [trophy case](https://support.strava.com/en-us/articles/15402068-the-strava-trophy-case) |
| **14. Headspace** — wellbeing / low-pressure habit | Meditation **run streak** and progress history; the streak can be hidden/disabled from Profile. Some content does not qualify for the streak. | `VERIFIED CURRENT (PUBLIC DOC)` (accessible help); causal retention or wellbeing lift = **NOT DISCLOSED**. | **Optional visibility** is a useful anti-pressure design convention, not proof a streak is valuable for Sharky. | [Run streak help](https://help.headspace.com/hc/en-us/articles/215730567-How-does-the-run-streak-feature-work), [Profile](https://help.headspace.com/hc/en-us/articles/6096184071323-Updated-Profile) |

**Classification nuance:** `VERIFIED CURRENT (PUBLIC DOC)` means the named provider was currently documenting this mechanic on 14 October 2026, *not* that an independent operator verified its 2026 production binary or paid offering. Supplier phrases such as “proves you're better,” “AI adapts,” “skill tiers” and “effective” remain **vendor claims** absent outcome data. An absence of visible documentation is **UNKNOWN**, not evidence that a feature is absent.

### Market findings that matter, rather than a frequency tally

**Most instructive direct poker contrast:** Poker Skill offers low-friction short lessons and XP/daily puzzles; PeakGTO combines an unusually clear **leak → relevant course/drill** loop with far heavier Elo/XP/leaderboard/economy machinery; GTO Wizard measures trainable error and EV while emphasizing detailed training controls; Runout advertises tiers/adaptation without public proof of their calibration. Thus *fixing the next meaningful poker mistake* is a common high-value product job; **no inspected competitor establishes that points themselves made poker decisions better**.

**Most instructive cross-industry contrast:** Chessable deliberately schedules the next repetition based on memory history; Headspace allows users to hide their streak; Strava badges celebrate actual participation; Mimo's projects can demonstrate a finished capability. These are very different success criteria and should not be collapsed into “gamification works.”

## C. Deep mechanism analysis and evidence

### 1. XP / points

- **Observed design usage:** XP can acknowledge a finished lesson, correct rep, game review or daily mission (Poker Skill, Duolingo, PeakGTO). It is easy to count, simple to animate and readily gameable if rewarded for clicks, trivial repeats, quick completion or answer memorization.
- **Engagement:** Points provide immediate feedback and could increase activity, but the *causal incremental effect on Sharky reopens* is `UNKNOWN`. Popularity of the mechanic is not efficacy.
- **Learning:** A score can be a useful **participation ledger**, not a competence estimate. If earned from assisted correct, repeating easy items or opening the app, it can distort both training behavior and learner trust.
- **Cost:** retaining existing XP is cheap; adding multipliers, caps, sources and premium boosters multiplies state/provenance/testing/support burden.
- **Sharky implication:** do **not** use XP delta to establish independent PROVE, TRANSFER or RETAIN. Keep any inherited XP subordinate to truthful receipt; avoid gratuitous balancing changes.

### 2. Streaks / habit pressure

- **Vendor randomized experiment (historical, Duolingo):** Duolingo publicly described an A/B test where **A = extend a streak after one lesson independently of daily goal**, **B = old rule requiring the daily goal**. Reported **Day-14 retention +3.3%**, **DAU +1%**, and over **20 days** the share of daily active learners who had a streak **+10.5%**. Day-14 retention was defined as percentage active 14 days later. Source post uses a 2020 screenshot and was published around **2020**. Sample size, statistical uncertainty, retention baseline and the relative-versus-absolute interpretation of “3.3%” were not disclosed in the cited article; treat the figure as **vendor-reported** and not a poker-app forecast. It is a comparison of *two streak rules*, not a random assignment to “streak or no streak.” [Duolingo experiment](https://blog.duolingo.com/improving-the-streak/).
- **Observational selection confound:** Learners who already maintain 7 days may be naturally motivated. A reported association between long streaks and next-day return does not identify the streak's causal effect.
- **Quality:** Streaks reward *showing up*. An uninterrupted calendar sequence neither ensures error correction nor demonstrates independent memory after 7 days. Such metrics can push users toward low-effort tasks merely to preserve a counter.
- **Fit:** Sharky already has a streak source/achievement. More coercive framing, escalating penalties, recovery currencies or push-pressure is **not supported**. An optional, subdued signal would be more defensible than adding a new daily-requirement system, subject to real evidence.

### 3. Concept/skill progression

- **Strong version:** independent correct decisions, across *several materially different contexts*, with separated assistance history and sufficiently spaced review, form a plausible skill progression signal. Helpful intermediate states include `introduced`, `practiced with assistance`, `independent matched recheck`, `unseen transfer demonstrated`, `retained after elapsed time`. These are **distinct evidence categories**, not five mandatory public levels.
- **Weak version:** arbitrarily rising rating, empty confidence bars, ever-growing XP levels or solver-derived numerical score misrepresented as “you will win more money.”
- **Risk:** complex taxonomies need sufficient authored cross-context tasks; an ambitious skill graph can be data-starved. The existing Act0 concept, transfer and durable-review owners must remain canonical.

### 4. Repair recognition and emotional reward

- **High-fit hypothesis:** recognizing a corrected misconception has more instructional relevance than a bonus for the initial correct guess. Source-backed wording can distinguish “We practiced the clue with help” from “You independently read a new spot.” A small earned moment should be noninterruptive, preserve the next-action CTA and avoid shame after failure.
- **Alternative:** If users already clearly understand the outcome, a separate card may add distraction. Existing source-backed Summary/Coach should be evaluated before introducing a second celebration component.
- **No external quantitative proof:** there is no identified poker-app randomized study here showing that reward for repair independently increases transfer or D7 retention.

### 5. Meaningful return triggers

- **Best pedagogical support:** a previously missed signal or due recheck provides a concrete, explainable reason to return. Chessable's review timing and PeakGTO's leak-linked course/trainer illustrate the **workflow**, not proven transfer uplift.
- **Cheapest choice:** reuse existing active-repair/due-review and recent focus. Do not create a generic “Daily Challenge” generator when a relevant unresolved weakness is available.
- **Stopping point:** a short closure should state what is learned, what remains unresolved, and the next action. Infinite easy drills and loss-aversion clocks may increase usage while reducing confidence or actual insight.

### 6. Premium interaction

- **Observed patterns:** Poker Skill's optional subscription removes energy limits, permits unlimited AI practice and archive access; Brilliant and Elevate sell broader access; PeakGTO bundles deep courses with linked, higher-complexity training. These demonstrate monetization **packaging**, not proof that Sharky can sustain a subscription.
- **Sharky-fit hypothesis:** users might pay for additional *genuine training depth*: more concept coverage, high-quality varied scenarios, and repeated independent feedback **after experiencing real free learning value**. Selling frustration relief (life refills, streak saves, artificial waiting) conflicts with trust.
- **Monetization metrics across the sample:** causal subscription conversion lift, payback and churn changes attributable to the above systems are **NOT DISCLOSED**.

### Independent research: what is actually demonstrated

| Source | Measured outcome and population/comparator | Result / limits for Sharky |
|---|---|---|
| **Cepeda et al. (2006), distributed practice** | Quantitative review of memory experiments comparing different practice intervals; **317 experiments and 839 assessments across 184 articles**, using verbal recall tasks. | Spacing is a credible general technique; ideal interval depends on desired retention interval. Does not estimate Sharky retention, poker transfer or product usage. [PubMed](https://pubmed.ncbi.nlm.nih.gov/16719566/) |
| **Rowland (2014), retrieval versus restudy** | Meta-analysis of testing/retrieval practice on later memory, comparing active recall with restudy. | Supports **independent recheck** as plausible learning design; does not validate any Sharky exact task or business outcome. [PubMed](https://pubmed.ncbi.nlm.nih.gov/25150680/) |
| **Butler & Roediger (2008), corrective feedback** | Experimental study of feedback after multiple-choice testing, with later cued recall, compared with less/no corrective feedback. | Specific feedback can support later remembering and suppress learning of wrong alternatives; poker action-quality transfer remains unmeasured. [PubMed](https://pubmed.ncbi.nlm.nih.gov/18491500/) |
| **Sailer & Homner (2019 online / 2020 journal), gamification meta-analysis** | Across interventions, cognitive learning `g=0.49` (19 samples/studies, N=1,686), motivation `g=0.36` (16, N=2,246), behavioral learning `g=0.25` (9, N=951) against comparison learning arrangements. | Broad positive *average intervention* effects; heterogeneity and many short experiments limit transfer. Cannot isolate XP, streaks, badges, poker ability or D7 app retention. [Open-access journal](https://doi.org/10.1007/s10648-019-09498-w) |
| **Duolingo (2020 historical), internal A/B** | Users of Duolingo; simplified streak eligibility vs old combined daily-goal requirement; Day-14 app activity, DAU and streak share, reported over approximately 20-day monitoring for latter. Sample characteristics and uncertainty not disclosed. | Vendor says +3.3% D14 retention, +1% DAU and +10.5% share on streak. Does **not** show skill impact or give an effect of adding streaks to an app without them. [Vendor experiment](https://blog.duolingo.com/improving-the-streak/) |

**Conclusion:** Educational psychology makes *relevant feedback, retrieval and spaced rechecking* relatively stronger hypotheses for Sharky's real learning. The gamification meta-analysis prevents categorical dismissal of rewards, but it **does not license numerical predictions for XP, a streak economy, paid conversion or poker improvement**.

## D. What Sharky already has — verified sources vs policy vs missing proof

### D1. Verified current repository implementation (read on `main`, 2026-10-14)

| Current source / consumer | Grounded observation | Boundary |
|---|---|---|
| [`act0_achievement_seed_projection_v1.dart`](https://github.com/ClubBoss/sharky-standalone-direction/blob/main/lib/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart), lines 44–155 | Six possible source-backed earned seed types: first **unassisted** correct, first repair note, first Review history, first eligible evidence signal, first current-session completion, three-day rhythm. Lesson-complete and clean-mini-drill seed entries are **blocked for missing source**. | Source code verifies eligibility logic, **not** measured user motivation or complete native visual acceptance. |
| [`act0_achievement_seed_consumer_v1.dart`](https://github.com/ClubBoss/sharky-standalone-direction/blob/main/lib/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart) | Deterministically filters earned seeds, limits displayed moments and supplies compact safe copy; no second award authority. | Does not create new badges/economy. |
| [`act0_shell_preview_screen_v1.dart`](https://github.com/ClubBoss/sharky-standalone-direction/blob/main/lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart), `_profileState` | Computes/profile-projects level, XP, task completion, accuracy, streak, strength/weakness data; currently exposes several basic achievements including first read, streak, repaired queue, saved streak and clean run. | This is **existing UI choice**, not proof the achievement is meaningful to a user. No assumption that every dormant model elsewhere is active. |
| [`act0_shell_state_v1.dart`](https://github.com/ClubBoss/sharky-standalone-direction/blob/main/lib/ui_v2/act0_shell/act0_shell_state_v1.dart), `Act0ProfileStateV1` | Holds separate XP, lesson, accuracy, streak, achievement and skill fields. | Separation in model does not automatically establish reliable cross-context mastery. |
| [`act0_lesson_runner_shell_v1.dart`](https://github.com/ClubBoss/sharky-standalone-direction/blob/main/lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart), `_BlockXpProgressCardV1` | Summary carries a compact `'One clean read'` / `'Local read saved'` card. Its indicator currently fills **0 or 100% based on whether `summary.xpEarned > 0`**, not a graded competence measure. | This is a presentation observation, not a recommendation to change a protected active S11 consumer. Potential comprehension ambiguity only a **hypothesis**, not a reproduced user defect. |
| Same shell, `_blockCompletionSummary` | Summary records first assessed outcomes per task, assisted kinds, independently known provenance, skill gains and `_lessonRunXp`. Subsequent guided correction does not overwrite the first assessed error. | Source-proven scoped semantics, **not** long-term retention. |
| [`act0_personalized_return_reason_v1.dart`](https://github.com/ClubBoss/sharky-standalone-direction/blob/main/lib/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart), `fromSources` | Ordered source-reason logic: active repair → retry an unresolved miss → due review → reinforce transfer → recent focus → safe no-evidence fallback. | Already owns the concept of next useful action; a new recommender would duplicate authority. |
| [`act0_review_shell_v1.dart`](https://github.com/ClubBoss/sharky-standalone-direction/blob/main/lib/ui_v2/act0_shell/act0_review_shell_v1.dart) | Contains actual due review / unresolved repair presentation and safe empty states. | Current S11 joined native proof is separate; no actual end-user return observed here. |

**Significant finding:** XP, streaks and achievements are **already present in current Act0**, contrary to any assumption that Sharky has none. A different set of achievement/streak engines under legacy `lib/services/` exists in the repo but is **not authority over active Act0 merely because those files exist**. Avoid inferring production behavior from those dormant sources.

**Reproducibility limitation:** This was a source-level `main` inspection. The S11 draft integration/binary was neither read nor modified. It does not claim current runtime screenshots, visual acceptance, Human learning, D7 usage or exact current release entitlement.

### D2. Accepted product strategy

- [`MASTER_PLAN_v5.0_TOP1_BULLDOZER_SSOT.md`](https://github.com/ClubBoss/sharky-standalone-direction/blob/main/docs/plan/MASTER_PLAN_v5.0_TOP1_BULLDOZER_SSOT.md): real poker decision improvement > causality/trust > usability > brand > engagement; assistance cannot become independent mastery; distinguish machine, human, longitudinal, real-poker and market evidence. The single next step derives from source-owned need.
- [`SHARKY_LEAN_GROWTH_PRODUCT_DECISION_20261012.md`](https://github.com/ClubBoss/sharky-standalone-direction/blob/main/docs/strategy/SHARKY_LEAN_GROWTH_PRODUCT_DECISION_20261012.md): one excellent English-first learning journey, honest premium only after visible value, not an engagement-engine expansion; paid recurring value still unproven.
- [`PRE_HUMAN_CAMPAIGN_STATE_v1.md`](https://github.com/ClubBoss/sharky-standalone-direction/blob/main/docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md), 2026-10-13 top dispatch: **S11 active**; next **S12 with visual-trust gate S12.V**; P02/Human not admitted. S09/S10 are predecessor accepted scopes; old dates farther down do not override the top dispatch.

### D3. Explicitly deferred historical proposals

[`SHARKY_PROGRESSION_RETENTION_LAYER_v1.md`](https://github.com/ClubBoss/sharky-standalone-direction/blob/main/docs/plan/SHARKY_PROGRESSION_RETENTION_LAYER_v1.md) and [`PROGRESS_SIGNAL_DERIVATION_v1.md`](https://github.com/ClubBoss/sharky-standalone-direction/blob/main/docs/plan/PROGRESS_SIGNAL_DERIVATION_v1.md) are both marked **`Deferred product canon`**. They record potentially useful streak-lite, family mastery, milestone/badge and future identity ideas; they are **reference constraints**, not automatic implementation authorization. Do not reintroduce general RPG titles, rank economy or a new model as a roadmap stage.

### D4. Missing proof, not automatically a defect

No located controlled Sharky evidence answers whether (a) XP increases voluntary return, (b) streak reduces genuine learning versus increases activity, (c) source-backed receipts improve understanding, (d) a novice distinguishes assisted from independently proved progress, (e) the target survives an unseen transfer and real 24h/7d recheck, or (f) any of these causes payment. This research did not conduct a usable app-binary comparison, recruit users, inspect S11 draft or access analytics. **All such claims remain `UNKNOWN / NOT PROVEN`.**

## E. Best opportunities — net learner/product EV first

**These are alternatives for future falsification, not requested implementation tasks.** Each assumes reusing existing Act0 contracts; no new dependency, engine, telemetry owner or protected Modern Table modifications.

| Priority | Candidate (current source leverage) | Immediate comprehension | Learning/transfer | Voluntary retention | Premium differentiation | Implementation / upkeep | Distortion/pressure risk | Evidence confidence | Cheapest future falsifier |
|---|---|---|---|---|---|---|---|---|---|
| **1** | **Evidence-justified next action**: favor existing unresolved repair/due review/confirmed recent focus; keep single CTA and clear why-now, do not add daily engine | **High** | **High potential** via relevant recheck; transfer requires unseen spot | Medium potential | Medium/high credibility | **Low if current consumer already adequate**; low upkeep | Low | Medium for pedagogical direction; low for Sharky retention | At admitted Human return gate: after authentic prior mistake, ask which task learner chooses voluntarily and why; verify exact source ID and later recall versus neutral continuation |
| **2** | **Honest repair/proof receipt**: one compact moment tied to corrected clue, assisted state versus independent matched proof kept separate; retain existing Summary/Coach if sufficient | High | Medium potential; highlights causal correction, not necessarily adds practice | Low/medium potential | High trust impact | Low when wording/presentation-only; negligible upkeep | Low if not overclaiming | Medium source coherence; **low causal UX evidence** | In admitted novice proof: can user articulate what is proven and what still needs an independent test, without confusing XP with skill? |
| **3** | **Skill-family evidence clarity**: if genuinely sourced, distinguish practice/independent/recent unseen transfer/retained evidence **without fake master ratings** | Medium | High potential as planning support; not proof by itself | Medium potential | High if legible and honest | Low–medium *consumer only*; high if new metrics/curriculum needed | Medium (scores can overclaim) | Medium conceptual, low actual user effect | Show existing Profile/Review on real earned histories; ask users to point to a demonstrated ability and its limitation; check source trace |
| **4** | **Purposeful spaced return, not streak pressure**: surface an existing actually-due item when legitimately due; no notification backend | Medium | High **general** learning support (retrieval/spacing); actual poker effect unknown | Medium potential | Medium | Low if due-owner reused; upkeep tied to valid content | Low | Medium for memory research, low for app return | Naturally elapsed 24h/72h/7d re-open, compare correct independent due review and unseen spot with control, no altered device clocks |

**Net-EV rank** above is an informed ordinal judgment, not quantified expected value. Complexity estimates are rough **Low / Medium / High relative bands**, not promised engineering hours. In each case the **do-nothing version** of the existing UI must be a credible comparator. Priority 1 may already be sufficiently fulfilled by the source; if it is, the recommendation is **keep it** rather than reimplement it.

**Why not a fifth feature?** XP boosters, achievement expansion, streak flexibility engines or gamified ranks have no direct evidence strong enough to overcome their trust, maintenance and attention costs before Sharky's Human evidence gates.

## F. What not to copy

1. **Global XP race / double-XP events / farming loops:** pushes easy repetition and number maximization over independent novel decisions; high abuse/inflated-signal risk.
2. **Punitive consecutive-day streaks, loss aversion, freeze/repair currency:** conflates attendance with retention and introduces guilt; especially weak fit when a strategic learner benefits from deliberate stopping and due review.
3. **Elo/leaderboards advertised as poker ability:** solver training metric may reflect tested distribution; cross-learner ranks and proof of real-world skill are not interchangeable. Adds fairness and calibration demands.
4. **Achievements for launching, clicking or speed alone:** activity is not mastery; large galleries and locked titles amplify phantom progress.
5. **Companion pet/virtual-currency economy:** Finch's energy/stones serve a different emotional wellness job. Sharky's Coach can support repair without a side game.
6. **Artificial energy gates or paid streak recovery as the conversion lever:** monetize additional genuine teaching depth after value, not frustration.
7. **Daily mandatory puzzle as substitute for targeted repair:** the Daily Puzzle may be enjoyable but can be unrelated to a specific learner's error. Use arbitrary content only if it helps a proven use case.
8. **Speed leaderboards and instant answer hints in scored assessment:** a fast click is not automaticity unless accuracy holds and the spot is independent; hints are teaching, not proof.
9. **An unverified high-resolution mastery heatmap:** don't derive continuous skill bands from a handful of mixed assisted/unassisted beginner attempts.

These are **poor-fit hypotheses**, not claims that each mechanic is always harmful. If future randomized and actual learning evidence contradicts them, revisit the single bounded item at the proper gate.

## G. Reward-system scenarios — M0–M4 and DO NOTHING

| Candidate | Learner story | Incremental upside over Sharky existing | Cost / trust risk | Net product EV judgment now | Decision |
|---|---|---|---|---|---|
| **DO NOTHING** (actual live baseline) | Keep existing XP, compact earned moments, streak and source-backed next action unmodified | Avoids distractions and regression; baseline for causal identification | **Zero new scope**, baseline shortcomings may remain | **High option value**; first comparator | `VALID CONTROL / KEEP UNTIL FALSIFIED` |
| **M0 — Minimal evidence-first** | No new XP mechanics; foreground error corrected, independent proof and next useful work | Clarifies learning truth; potential trust/learning gain | Low when current source reused; avoid accidentally changing frozen stage | **Highest near-term research priority** | `FIRST TO FALSIFY`, not auto-build |
| **M1 — Lightweight XP & earned moments** | Keep current XP ledger and compact acknowledgements; no multipliers/economy | Familiar reassurance and short delight; already present | Low if unchanged; if emphasized, risk XP=mastery | **Positive only as bounded secondary presentation** | `KEEP EXISTING, DO NOT EXPAND` |
| **M2 — Skill-based progression** | Honest concept evidence, assistance + same-signal + unseen transfer + elapsed retention distinguishable | Potential strongest long-term differentiation and training choice | Medium/high if new taxonomy/content/metrics; fake certainty risk | **Conditional long-term high EV** if existing source + human understanding support it | `RESEARCH LATER; NO NEW ENGINE` |
| **M3 — Habit enhancement** | Streak-lite, prompts, recoverability, daily/weekly ritual | May lift D1/D7 activity; skill effect ambiguous | Medium and privacy/pressure costs; existing streak may suffice | **Lower EV than relevant review** | `DEFER` |
| **M4 — Rich rewards** | Badge families, titles, ranks, leagues, economies | Possible segment delight/monetization; no Sharky evidence | **High** implementation/content/maintenance and signal-distortion | **Net EV likely negative pre-Human** | `REJECT PREP / DEFER` |

**Selection:** Test **M0's claim** (“users value evidence-first next action more than generic progress”) against existing **DO NOTHING** first. **M1 stays intact while evaluated.** M2 is a conditional **concept-evidence presentation** direction only; avoid a synthetic second mastery owner. The M0–M4 labels are *alternatives*, not release stages to be implemented sequentially.

## H. Unanswered questions only humans or Sharky first-party behavior can answer

1. Does a novice accurately understand the distinction between “correct with hint,” “fixed on matched recheck,” “transferred to a new spot,” and “retained after days” when seeing the current Summary/Profile?
2. On reopening, is the suggested task selected because the learner finds the *why* useful, because it's convenient, or to maintain XP/streak? What proportion of return starts are **meaningful independent reps**?
3. Does any earned receipt improve unaided causal explanation or only subjective enjoyment? Does removing/hiding it improve focus for some users?
4. What percentage of accepted `repair_completed` episodes is followed by independent unseen transfer? Does transfer remain after a real interval?
5. Are users *intrinsically returning* after one clear learning session, without a notification, daily reward or social prompt? Is D7 usage concentrated in low-effort streak-preserving sessions?
6. Are there distinct novice and progressing learner needs for progress visibility, or merely apparent segments created by task volume, prior skill and onboarding selection?
7. Is a compact visible skill-family state meaningful with the **number, balance and authenticity** of currently playable tasks?
8. Does free experience support repeat willingness-to-pay for ongoing practice, or would honest one-time courses/packs fit better?
9. Do fatigue, hurry and pressure from a streak actually degrade decision accuracy or completion of difficult repairs?
10. Do new users perceive any XP/progress bar as an independent ability rating in today's English product? This is not inferable from implementation source alone.

## I. Research-to-product handoff — falsifiable hypotheses only

These hypotheses should feed **existing** Human / longitudinal / market evidence gates if/when admitted, not a new roadmap stage. Use the current authorized choice/result/repair/recheck/return event owners and privacy rules; do not add a parallel analytics layer solely for this research.

| ID / candidate gate | Hypothesis and comparator | Observable primary success | Confounds / explicit fail signal |
|---|---|---|---|
| **H-R1 — S13/S15, M0** | Existing specific **why-now** return proposition enables more meaningful voluntary repair/review than an otherwise equivalent neutral “Continue” on a source-matched state. | After genuine elapsed time, independently chosen relevant target, valid source ID, correct/causally explained target outcome and independent unseen check. | Do **not** count tap, notification-open, fake due or assisted success as retained skill. Failure: irrelevant/ignored recommendation or lower independent accuracy. |
| **H-R2 — S13, M1 vs no added emphasis** | An honest compact proof receipt improves users' accurate account of what happened, without delaying next action, relative to same source evidence shown more minimally. | Correct unaided explanation of assisted vs independent status; next-action reachability; qualitative trust. | Demand characteristics and screen-order; failure: users repeat “I mastered it” after guided-correct, or spend less attention on the clue. |
| **H-R3 — S15, source-owned due review** | Returning to an actually due prior misconception yields better *elapsed independent recall / unseen transfer* than matched unscheduled generic rehearsal. | Real 24h/72h/7d correct decisions with no assistance on independently chosen new spots; concept-level error reduction. | Item difficulty, self-selection, multiple testing; failure: only exact-item improvement, no transfer. |
| **H-R4 — S13/S15, optional segment evaluation** | Learners vary in desired progress detail: new players prefer short causal receipt, experienced learners benefit from deeper bounded skill evidence. | Within-person comprehension, completion and stated preference conditional on actual ability/need. | No artificial personas based on 1–2 actions; failure: no robust differential benefit or a simpler one-size approach wins. |
| **H-R5 — S19, conditional commercial hypothesis** | After multiple *actual* useful sessions, access to broader and demonstrably valuable independent practice produces credible willingness to pay; currencies/streak protection aren't needed. | Understandable Free/Premium difference; real price-choice / eventually authentic purchase behavior only when market work admitted. | Stated intent ≠ purchase; sales copy, novelty and cohort selection. Failure: no durable repeated job; test course/pack alternative rather than forcing subscription. |

**Measurement integrity:** activity (`D1/D7` active or reopen) is separate from **quality-qualified retained learning** (unassisted correct, causal explanation, unseen changed spot after elapsed time). Track both; an app can improve one and worsen the other. The smallest possible comparison can be qualitative in initial S13 novice observations; causal population inference needs a sufficiently powered, controlled future protocol. Do not invent sample sizes, thresholds or effects here.

**Sequence protection:** `S11 terminal native evidence → S12.V visual trust / S12 P02 owner decision → S13 real novice observation → S15 actual elapsed return and unseen transfer → S19 conditional market WTP`. The research does **not** permit advancing any gate or recruiting/running testing now.

## J. Strongest counterarguments to the preferred M0-led approach

**1. Minimal rewards may feel dry, even if the learning is accurate.** Premium coaches also need enjoyment, progress anticipation and return salience. Users might learn marginally more per session but abandon before enough sessions accumulate. **What would change the conclusion:** a controlled compact-reward condition demonstrates meaningfully more *quality-qualified independent retained practice* with no accuracy or trust penalty. A mere growth in XP collection does not suffice.

**2. Existing source-owned cues may already overwhelm rather than motivate.** Even several truthfully earned evidence labels could feel abstract to a novice; stronger simple XP/metaphors might communicate faster, regardless of theoretical purity. **What changes the conclusion:** native/Human evidence that users consistently misinterpret current explanation while a simple alternative measurably improves comprehension and subsequent task choice. Preserve actual source truth while changing the consumer, not the engine.

**3. Highly engaged users may need stronger goals, social recognition or routine after the beginner phase.** Duolingo and PeakGTO demonstrate commercial products operating rich feedback loops, and gamification meta-research does not support a blanket ban. **What changes the conclusion:** adequate *segment-specific, multi-session* evidence of incremental retained poker performance and sustainable commercial value that exceeds upkeep, fairness, stress and distraction costs. This would warrant an explicit future owner gate, not retroactive admission.

## K. Final recommendation and decision boundary

**`MOTIVATION_REWARDS_LAYER = REFINE` (RESEARCH VERDICT ONLY)**

- **KEEP** existing source-owned XP/proof/earned moments and the personalized next-action/due-review owner for now; never present XP or streak as a quantified ability claim.
- **REFINE only as a candidate at a future evidence gate** how current repair/proof and next action are explained, *if* real learners show comprehension/return deficits. The expected solution should first be content/copy/consumer selection over the existing contracts, not a new engine.
- **DEFER** new streak programs, reward currencies, achievements/ranks, fake skill scores, social competitions, notification pressure and sophisticated gamification; no execution permission is conferred by this research.
- **Preserve exact evidence boundaries**: assisted correctness = teaching; independent matched recheck = localized proof; materially novel independent situation = transfer; a real elapsed independent test = retention; voluntary return ≠ proficiency; subscription interest ≠ payment.
- **Preserve one active work owner and stage:** no PR, branch, issue, screenshot or S11 artifact touched; Modern Table remains protected and S12.V is the designated visual trust gate.

### Confidence ledger

| Claim | Research confidence | Next proper source of proof |
|---|---|---|
| Spaced retrieval, feedback are credible mechanisms for memory | **Moderate–high general**, not poker-specific | S15 with real time and independent novel poker spots |
| Sharky source-backed repair/next reason is a coherent low-complexity product choice | **Medium design reasoning** | S13 Human comprehension/flow and S15 return |
| Compact earned moments outperform less reward-oriented presentation | **Low** | Controlled Human comparison |
| New daily streak raises quality-qualified D7 Sharky retention | **Unknown** | Longitudinal comparison; no approval for implementation |
| Premium recurring training demand follows learning value | **Unknown** | S19 actual market behavior |

### Final single strongest finding and next evidence gate

**Strongest preparatory finding:** Sharky's meaningful retention advantage, if it exists, is most likely in making **error correction, independent re-proof and time-appropriate return visibly useful**, not in multiplying XP, streak and badge surfaces. Crucially, Act0 **already contains** much of this foundation; the most valuable near-term choice may be to **leave rewards unchanged**.

**Next future evidence gate:** complete the existing **S11 → S12.V / S12 owner pre-Human admission** process first. Only once legitimately admitted, **S13** can falsify comprehension of current earned proof, and **S15** can test actual voluntary return, delayed independent recall and unseen poker transfer. No new roadmap stage or feature is proposed.

**Terminal verdict:** `SHARKY_MARKET_REWARD_RESEARCH_V1 — COMPLETE / EVIDENCE_LIMITED`.