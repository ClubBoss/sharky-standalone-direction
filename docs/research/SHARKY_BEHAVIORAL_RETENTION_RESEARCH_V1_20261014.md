# SHARKY — Independent Behavioral Science, Learning Motivation & Retention Audit V1

Date: 2026-10-14 · Mode: read-only research · Author: Claude (Opus 5.5)
Terminal label: `SHARKY_BEHAVIORAL_RETENTION_RESEARCH_V1 — COMPLETE / EVIDENCE_LIMITED`

**Evidence tags used throughout:**
**[E]** established / well-supported · **[C]** context-dependent · **[W]** weak or mixed · **[T]** theoretical inference · **[H]** Sharky-specific untested hypothesis.

---

## 0. Source position (what I verified, what I did not)

Read from GitHub `main` (read-only `gh api`, no clone or fetch into the working tree): `MASTER_PLAN_v5.0_TOP1_BULLDOZER_SSOT.md` (§6, §9, §11–13), `SHARKY_LEAN_GROWTH_PRODUCT_DECISION_20261012.md`, `PRE_HUMAN_CAMPAIGN_STATE_v1.md`. Read from the local checkout (an **August 2026 snapshot**, older than main): `SHARKY_PROGRESSION_RETENTION_LAYER_v1.md` and `PROGRESS_SIGNAL_DERIVATION_v1.md` (both status *Deferred product canon*), and `DURABLE_RETENTION_TRANSFER_CONTRACT_v1.md` (*Active canonical Act0 learning contract*).

What current authority already says:
- Master Plan §9: return value comes from **the prior missed or repaired clue**, not from daily-task clutter. It forbids arbitrary badges, fake levels, skill ratings, leaderboards and guilt streaks unless an evidence-backed taxonomy exists. Recognition must be "earned and brief".
- Master Plan §6/§11: assisted correctness counts as teaching evidence, never as achievement, retention, transfer or repair proof. `unlocked ≠ completed`. XP, streaks and time spent may never be promoted to Human proof.
- Lean decision (2026-10-12): the return cue is "one meaningful current next action… no fake urgency, streak penalties or invented debt". The streak recovery economy is deferred.
- Durable Retention contract: there is already a deterministic 24h → 72h → 7d spaced schedule, lapse handling, and transfer verdicts (`insufficient_evidence`, `recovered_not_durable`, `improving`, `stable`, `regressing`, `mixed`).
- The older *Progression & Retention Layer v1* (deferred) still allows "Streak-Lite" and "Meaningful Badges". **The newer Master Plan v5 §9 is stricter and governs.** I treat that conflict as resolved in v5's favor.

**Not verified:**
- **The "uniform 5 XP per task" premise.** In the August local snapshot, authored `rewardXp` values vary from 5 to 35 (the most common is 10). Already-completed tasks award 0 XP. I could not confirm whether current main has since made XP uniform. The analysis below covers both cases.
- **Streak and achievement code.** The August snapshot contains `streakDays`, an achievement seed called `three_day_streak_v1`, and seeds such as `first_session_complete_v1`. I did not verify whether these are still active or visible on current main.
- I did not read S11, S09-B2 or Session Summary source on main.

---

## A. Executive conclusion

**Best-fit model: mastery-evidence emphasis (H2), with today's XP and earned moments kept in a clearly secondary role (the residue of H1), and H0 kept as the explicit null hypothesis that every future addition must beat.** Rich gamification (H4) is rejected. Structured daily habits (H3) are deferred, and if a return rhythm is ever added it should take the form of due work, not a daily streak.

Why:

1. **Poker decision skill is a cognitive and judgment skill whose real-world feedback is noisy.** Learners commonly fall into results-oriented thinking. The scarce resource is *clear, informative evidence that a decision was good and that a misread is now fixed*. Feedback meta-analyses consistently find that **the information content of feedback** predicts its effect [E]. Feedback that pulls attention toward the self rather than the task weakens or reverses the effect [E].
2. **Points tend to raise output volume, not intrinsic motivation or quality.** Experiments that isolate the elements show this [C]. In Sharky the "volume" that points would buy is mostly the volume the learner was already routed into. XP therefore adds little causal benefit for learning, and it carries some risk if it is framed as skill.
3. **The strongest retention science, retrieval practice and spacing, is already built into Sharky's contracts** [E]. The highest-value motivational move is to *make that evidence legible and emotionally meaningful* ("you missed this clue on Tuesday and you read it correctly today, three days later"). Inventing a parallel reward currency would not do that.
4. **Daily streaks have a specific, documented failure mode.** A visibly broken streak lowers later engagement, more so when people blame themselves [C]. Rigid routines also produced *less* durable behavior than flexible ones in a field RCT [C]. Adult poker learners have variable time, which makes this failure mode especially likely.
5. **A poker product is gambling-adjacent.** Variable-ratio reward mechanics such as loot boxes are linked (correlationally) with problem-gambling symptoms [W/C]. They would also damage premium credibility. This is an additional, domain-specific reason to reject H4.

**Confidence that H2-dominant beats H1-as-is: moderate.** The direction is well supported by mechanism-level science. There is no direct evidence about adult poker learners and no Sharky Human data (`HUMAN_PROOF = FALSE`). The magnitude of any difference is unknown and could be small. Section I lists the conditions that would reverse this conclusion.

---

## B. Scientific evidence matrix (19 sources)

| # | Source | Population / design | Observed outcome | Limitations | Sharky applicability |
|---|---|---|---|---|---|
| 1 | Deci, Koestner & Ryan (1999), *Psychological Bulletin* 125(6):627–668. [PDF](https://depts.washington.edu/techdocs/papers/deciExtrinsicRewardsAndIntrinsicMotivation99.pdf) | Meta-analysis of 128 lab experiments, mostly children and students | Expected tangible rewards undermined free-choice intrinsic motivation (engagement-contingent d≈−0.40, completion-contingent d≈−0.36, performance-contingent d≈−0.28). Positive informational feedback *enhanced* it. **[E for lab tasks]** | Short-term lab tasks that were already interesting. Contested by Cameron & Pierce. Generalization to adult apps is an inference. | XP is not tangible, but completion-contingent "+N" framing resembles the undermining condition. Informational recognition resembles the enhancing condition. |
| 2 | Cameron, Banko & Pierce (2001), *The Behavior Analyst* 24(1). [PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC2731358/) | Counter-meta-analysis | Undermining is limited to narrow conditions. Rewards tied to performance standards can be neutral or positive. **[C]** | Partisan debate. Different coding choices. | Shows that "rewards always crowd out motivation" is **not** established. Rewards tied to meaningful standards are the safer form. |
| 3 | Ryan & Deci (2000), *American Psychologist* 55(1):68–78 (Self-Determination Theory) | Theory plus a programme of studies | Competence, autonomy and relatedness support internalized motivation. Controlling contingencies reduce it. **[E as framework, T for specific UI]** | A theory, not proof that any given UI works. | Lens for judging whether a mechanic informs (supports competence) or controls (pressure). |
| 4 | Kluger & DeNisi (1996), *Psychological Bulletin* 119(2):254–284. [abstract](https://pluto.huji.ac.il/%7Emskluger/files/Download/Kluger%20&%20%20DeNisi%20abstract.doc) | Meta-analysis, 607 effect sizes, ~23k observations | Average feedback-intervention d≈.41, but **more than a third of interventions reduced performance**. Effectiveness falls as feedback moves attention toward the self and away from the task. **[E]** | Heterogeneous tasks, older literature. | Celebration about the person ("you're a shark!") is weaker than task-level recognition ("you read the button position"). |
| 5 | Wisniewski, Zierer & Hattie (2020), *Frontiers in Psychology* 10:3087. [open access](https://www.frontiersin.org/articles/10.3389/fpsyg.2019.03087/full) | Meta-analysis, 435 studies, N>61k | d≈0.48. Effect strongly moderated by **information content**. Larger effects on cognitive and motor outcomes than on motivational ones. **[E]** | High heterogeneity. Mostly school settings. | Supports investing in causal feedback and repair (already core) over reward tokens. |
| 6 | Sailer & Homner (2020), *Educational Psychology Review* 32:77–112. [Springer](https://link.springer.com/article/10.1007/s10648-019-09498-w) | Gamification-in-learning meta-analysis | Cognitive g=.49, motivational g=.36, behavioral g=.25. Only the cognitive effect was stable in rigorous studies. Game fiction and collaboration-plus-competition moderated effects. **[C]** | Gamification packages are bundled, so individual elements are hard to isolate. Short durations. | An average positive effect exists, but it does not tell us XP or streaks specifically help. Motivational effects are fragile. |
| 7 | Li, Ma & Shi (2023), *Frontiers in Psychology* 14:1253549. [open access](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2023.1253549/full) | Meta-analysis, 41 studies, >5k participants | Overall g≈0.82. Moderated by user type, discipline, design principles and **duration**. **[W–C]** | Very high heterogeneity, risk of publication bias, mostly students. | Big pooled numbers should not be read as a design guarantee. Duration moderation is consistent with novelty decay (#9). |
| 8 | Mekler, Brühlmann, Tuch & Opwis (2017), *Computers in Human Behavior* 71:525–534. [PDF](https://glassmanlab.seas.harvard.edu/annotated_works/mekler17.pdf) | Online RCT, points vs levels vs leaderboard vs control, image tagging | Elements **raised output quantity** but did **not** change competence, intrinsic motivation or tag quality. **[C]** | A single simple task, adults online, one session. | Direct analogue for XP: expect "more taps", not "better reads". |
| 9 | Rodrigues et al. (2022), *IJETHE* 19:13. [Springer](https://link.springer.com/article/10.1186/s41239-021-00314-6) | Quasi-experiment, 14 weeks, N=756 STEM undergraduates | Gamification effect declined after about 4 weeks (novelty), then partly recovered at weeks 6–10 (familiarization). U-shaped. **[C]** | Quasi-experimental, single course, behavioral usage measures only. | Expect XP and badge novelty to fade within weeks. Effects measured early (D1/D7) will overstate durable value. |
| 10 | Hanus & Fox (2015), *Computers & Education* 80:152–161 (corrigendum 2018). [DOI](https://doi.org/10.1016/j.compedu.2014.08.019) | 16-week classroom quasi-experiment, mandatory badges and a leaderboard | The gamified section reported **lower intrinsic motivation and satisfaction**, and lower final-exam scores were reported. **[W–C]** | Single course, mandatory and competitive elements, a later corrigendum. | Shows the risk of comparative, mandatory reward structures over longer horizons. |
| 11 | Silverman & Barasch (2023), *Journal of Consumer Research* 49(6):1095–1117. [repository](https://udspace.udel.edu/handle/19716/34160) | 7 studies (field and experimental) | Logged intact streaks raise later engagement compared with broken streaks, **independent of actual past behavior**. The effect is amplified when people blame themselves for the break and attenuated when the streak can be repaired. **[C]** | Consumer behaviors, not learning outcomes. | A streak creates a goal *about the log*, not about the skill. Breaking it predicts drop-off. |
| 12 | Beshears, Lee, Milkman, Mislavsky & Wisdom (2021), *Management Science* 67(7):4139–4171. [RePEc](https://ideas.repec.org/a/inm/ormnsc/v67y2021i7p4139-4171.html) | Field RCT, gym incentives, fixed-window vs flexible | Routine (fixed-time) incentives produced **fewer** visits than flexible incentives, both during and after the intervention. **[C]** | Exercise, cash incentives. | Argues against rigid daily rhythms and for flexible, needs-based return cues. |
| 13 | Milkman et al. (2021), *Nature* 600:478–483. [Caltech](https://authors.library.caltech.edu/records/mys88-cc756) | Megastudy, 54 interventions, N=61,293 | About 45% of interventions raised visits by 9–27% during 4 weeks. **Only 8% had a significant effect after the intervention ended.** The top arm rewarded *returning after a missed workout*. Experts could not predict the winners. **[E for this setting]** | Gym, 4 weeks, cash micro-rewards. | (a) Most engagement nudges do not persist. (b) Recovery framing works better than loss framing. (c) Intuition about which mechanic wins is unreliable, so testing beats debate. |
| 14 | Lally, van Jaarsveld, Potts & Wardle (2010), *European Journal of Social Psychology* 40:998–1009. [record](https://openresearch.surrey.ac.uk/esploro/outputs/99783513802346) | 96 volunteers (82 analysed), 12 weeks, self-report automaticity | Median 66 days to an automaticity plateau, range 18–254. **Missing one opportunity did not materially affect habit formation.** **[C]** | Small sample, self-report, extrapolated curves, not yet replicated. | A single missed day does not hurt habit-building, so "streak broken" messaging is scientifically unfounded as well as unkind. |
| 15 | Cepeda, Pashler, Vul, Wixted & Rohrer (2006), *Psychological Bulletin* 132(3):354–380. [PubMed](https://pubmed.ncbi.nlm.nih.gov/16719566/) | Review and synthesis, 839 assessments, 317 experiments | Spacing benefit is robust. The optimal gap grows with the retention interval. Expanding versus equal gaps is **not** clearly settled. **[E spacing; W expanding]** | Mostly verbal recall. | Validates Sharky's 24h → 72h → 7d due rechecks as the core "return reason". The exact intervals are reasonable but not proven optimal. |
| 16 | Adesope, Trevisan & Sundararajan (2017), *Review of Educational Research* 87(3):659–701. [SAGE](https://journals.sagepub.com/doi/10.3102/0034654316689306) | Meta-analysis of practice testing, ~272 effect sizes | Retrieval practice beats restudy (secondary sources report g≈0.61). Stronger when practice and final formats match. Feedback helps. **[E]** | Mostly declarative knowledge. Transfer to judgment skills is less certain. | An independent recheck *is* retrieval practice. It is the learning event most worth recognizing. |
| 17 | Soderstrom & Bjork (2015), *Perspectives on Psychological Science* 10(2):176–199. [PubMed](https://pubmed.ncbi.nlm.nih.gov/25910388/) | Integrative review | Performance during acquisition is an unreliable index of learning. Some manipulations help one while hurting the other. Learners misjudge their own learning from fluency. **[E]** | Review, not a single test. | Same-session correct answers, and XP accrued from them, are *performance*, not learning. Recognition should lean on delayed evidence. |
| 18 | Metcalfe (2017), *Annual Review of Psychology* 68:465–489. [Annual Reviews](https://annualreviews.org/doi/abs/10.1146/annurev-psych-010416-044022) | Review | Errors followed by corrective feedback enhance learning. High-confidence errors are hyper-corrected. Error-avoidant design can backfire. **[E in lab; C in applied settings]** | Mostly factual and semantic material. | Strong rationale for treating "repaired misread" as a first-class, positively framed event, not a penalty. |
| 19 | Kivetz, Urminsky & Zheng (2006), *Journal of Marketing Research* 43(1):39–58. [PDF](https://business.columbia.edu/sites/default/files-efs/pubfiles/1200/goalgradient.pdf) | Field and online studies, loyalty cards | Effort accelerates near a reward, then **dips after it is reached**. Illusory head-start progress speeds completion. **[E in consumer settings]** | Purchase and rating behavior, not learning. | Progress bars motivate toward thresholds but invite post-goal slumps and manipulation ("bonus stamps"). Use them only for honest, finite learning goals such as "3 clues left in World 2". |

Supporting sources used for narrower points:
- Silverman & Barasch commentary on recovery messaging: [CU Boulder](https://www.colorado.edu/business/news/2023/04/20/research-streaks-marketing-tech-barasch).
- Dai, Milkman & Riis (2014), the fresh-start effect: [PDF](https://faculty.wharton.upenn.edu/wp-content/uploads/2014/06/Dai_Fresh_Start_2014_Mgmt_Sci.pdf) [C].
- Usher & Pajares (2008), *Review of Educational Research* 78(4), mastery experience as the primary source of self-efficacy (Bandura) [E as theory, C as measurement].
- Hattie & Timperley (2007), *Review of Educational Research* 77(1):81–112, self-level praise is the least effective feedback level [E/C].
- Koedinger & Aleven (2007), *Educational Psychology Review* 19:239–264, the "assistance dilemma" [T/C].
- Zendle & Cairns (2018), *PLoS ONE* 13(11):e0206767, a loot-box–problem-gambling association that is correlational [W–C].
- Qualitative Duolingo-misuse evidence, including pressure to keep daily streaks: [arXiv 2203.16175](https://arxiv.org/pdf/2203.16175) [W].

**No controlled study isolating a streak mechanic against learning outcomes was found.** Industry streak-retention claims are correlational and self-reported. I treat them as non-evidence for learning.

---

## C. Mechanism assessment

### C1. XP
- **Supports competence when** it is informational: tied to a standard the learner understands and paired with an explanation of what was achieved (#1, #2, #5). **[C]**
- **Makes progress understandable when** the unit maps to something real. A uniform 5 XP per task maps exactly to *task count ×5*. That is honest as a **practice-volume counter** and carries **no information beyond completion**. **[T]**
- **Encourages deliberate practice?** There is no evidence that points raise practice *quality* (#8). Deliberate practice needs targeted difficulty and feedback, which Sharky's repair routing already supplies. **[C]**
- **Crowding-out risk:** low to moderate. XP is symbolic, not tangible, and is not the session's focus. The risk rises if "+XP" becomes the climax of the payoff (completion-contingent framing, #1). **[T]**
- **Low-value repetition:** largely mitigated already, because re-completing a task awards 0 XP. The residual risk is a learner who reads XP as skill. **[H]**
- **Easy-task preference:** a real risk in free-choice systems. **In Sharky it is limited** because the path is system-routed (Academy plus one Decision Lab next rep). Uniform XP *avoids* building an "XP-optimal path". Difficulty-proportional XP would create one and would need trustworthy difficulty calibration Sharky does not have. **[T]**
- **Verdict on uniform 5 XP:** **harmless and somewhat useful as a volume counter, misleading only if presented as skill.** It is not pedagogically meaningful in itself. Do not change the values. Change, if anything, **how prominent XP is relative to evidence**. If main actually still has variable authored XP (5–35, as in the August snapshot), the same logic applies, with the added caution that the variation is not tied to validated difficulty.

### C2. Completion rewards
Completion is necessary for the curriculum but is not learning (#17). Recognize completion as **"you finished X; here is what you can now read"**, so the reward carries the *content*. Avoid "+N for finishing". **[C/T]**

### C3. Streaks
- Evidence suggests they lift short-term logged-behavior frequency (#11, industry data) and **create a goal about the log itself** (#11).
- When broken, they predict drop-off, especially when people blame themselves (#11). Rigid schedules underperform flexible ones (#12). A single miss does not hurt habit-building (#14). Persistence beyond the intervention is rare across 54 nudges (#13).
- For adults with variable time, a niche skill, a premium price point, and a domain already linked to compulsive play, **the downside fits Sharky badly**. **[C → H]**
- Legitimate alternative: **due-work cues**. "Two clues you repaired are ready to recheck." This return reason is *literally the learning mechanism* (#15, #16). It is also already Master Plan policy. **[E mechanism; H for return-rate effect]**

### C4. Achievements
- Activity achievements such as `first_session_complete` and `three_day_streak` tend to function as extrinsic incentives (#8). Their novelty decays (#9).
- **Evidence achievements** (first repaired misread, first held-after-time recheck, first transfer to a new spot) are informational. They overlap with item C5 and are not a catalog.
- A catalog *beyond* evidence events adds maintenance burden and invites the "stat junkyard" the progression doc itself warns against. **[T]**

### C5. Progress feedback, repaired mistakes and transfer recognition (the H2 core)
- Mastery experience is theorized to be the primary source of self-efficacy (Usher & Pajares). A visible record of *"missed → repaired → held after 3 days"* is a direct, honest mastery experience.
- Error-correction is a strong learning event (#18). Delayed retrieval success is the best in-app proxy for learning (#16, #17).
- **Sharky already computes these states** (Durable Retention contract verdicts). The cost is presentation, not a new engine. **[E mechanisms; H for the motivational effect of displaying them]**
- Guardrails:
  - Never display a percentage or rating. The states are categorical.
  - "Stable" is not "mastery" (the contract already says so).
  - Assisted success is shown as "learned with help", never as proof (Master Plan §11).

### C6. Return cues
Rank by evidence and fit:
1. Due recheck of a previously missed clue. **[E mechanism]**
2. Unfinished honest next lesson. **[neutral]**
3. Optional practice. **[neutral]**
4. A generic "come back today". **[W]**
5. Loss-framed streak warnings. **[C, harmful]**

Notification copy should be informational ("ready to recheck"), not controlling ("don't lose…"), per SDT (#3). **[T]**

### C7. Emotional design (question F)
- **Recognition after a corrected mistake** is plausibly more motivating *and* more informative than celebration after an easy correct answer. It signals genuine change (#18), avoids self-level praise (#4, Hattie & Timperley) and normalizes error, which matters for poker's results-oriented players. **[T/H]**
- Adult-appropriate tone means calm, specific, task-level language. Example: "Last time you missed the raise from early position. You caught it this time without help." Avoid confetti for routine answers. Reserve motion and haptics for proof events.
- **Curiosity hook.** After a proof event, one line naming *what's next* that is genuinely harder, such as "Next: the same read when the raiser is in the blinds." This is the competence-plus-autonomy pattern. **[T]**
- **Resilience.** Frame a lapse ("missed it again after 3 days") as *normal forgetting with a short path back*. That framing is accurate (spacing literature) and consistent with the recovery-over-loss evidence (#13). **[C/T]**

---

## D. Risks and failure modes

| Risk | Mechanism | Who gets hurt | Existing guard? |
|---|---|---|---|
| Performance read as learning | Same-session correctness and XP feel like progress (#17) | Learner overestimates skill. Real-poker transfer disappoints. Premium trust drops. | Partly. Durable contract gates "durable" and "transfer" language. XP itself is not gated. |
| Assisted success masquerading as mastery | Celebration does not distinguish hint-assisted from independent answers | Learning integrity (Master Plan P1 defect class) | Yes in source. Presentation must keep it visible. |
| Streak as a goal about the log | Logging creates its own goal (#11) | Autonomy. Anxiety. Drop-off after a break. | Master Plan forbids guilt streaks. **The August snapshot still contains streak state and a 3-day streak seed** (status on main unverified). |
| Novelty decay | Effects fade at about 4+ weeks (#9) | D1/D7 data overstates value. Decisions get made on transient lift. | No. This is a measurement-design risk. |
| Post-goal slump | Goal-gradient dip after a milestone (#19) | World completion followed by churn | No. A clear next objective at the milestone mitigates it. |
| Self-level praise | Attention moves to the self (#4) | Fragile motivation, infantilizing tone | Master Plan bans "baby mascot". Copy discipline is needed. |
| Variable-reward mechanics | Gambling-like reinforcement (Zendle & Cairns) | Vulnerable users, brand credibility | Lean decision rejects the economy. Keep it that way. |
| Monetization-driven engagement | Optimizing D7 or streaks for subscription retention trades learning for habit loops | Long-term WTP built on obligation rather than value | Master Plan sequence: value proof before offer. |
| Activity achievements | Extrinsic, decaying (#8, #9) | Clutter, "stat junkyard" | v5 §9 forbids arbitrary badges. |

---

## E. H0–H4 comparative arbitration

| | H0 None extra | H1 Lightweight XP + moments | H2 Mastery-evidence emphasis | H3 Structured habits | H4 Rich gamification |
|---|---|---|---|---|---|
| Scientific rationale | Informative feedback plus spaced retrieval are the active ingredients (#5, #15, #16) | Points raise output (#8). Informational positive feedback can enhance intrinsic motivation (#1). | Mastery experience, error correction, retrieval success (#16–18) | Habit formation via repeated cues (#14) | Average gamification effects (#6, #7) |
| Evidence quality | Strong for the mechanisms, weak for "sufficient for return" | Moderate (lab, single-task) | Strong mechanisms, untested display effect | Weak–contextual. Rigid routines underperform (#12). | Heterogeneous, decaying (#9), negative long-run cases (#10) |
| Likely positive mechanism | Clean learning signal, no distraction | Legible volume, small immediate gratification | Competence from real change, honest return reason | More frequent opens | Novelty, social or competitive pull |
| Likely unintended effects | Weak felt momentum early. Fewer returns before evidence accrues. | XP mistaken for skill, crowd-out if foregrounded | Delayed gratification (proof needs 24h+). Confusing early. | Obligation, broken-streak drop-off (#11), "streak-farming" with trivial reps | Crowd-out, comparison anxiety, maintenance burden, gambling resemblance |
| Required learner data | None new | Existing | **Existing** (retention states, review_kind, repair queue) | New per-day activity semantics | New economy and tuning data |
| Cheapest valid experiment | Baseline arm in any test | XP-forward arm | Evidence-forward Summary/Profile prototype in moderated sessions | Only after a Human return problem is observed | Not worth testing now |
| Build/maintenance burden | ~0 | Already paid | Low–moderate (presentation and copy only) | Moderate | High |
| Fit for adult poker learners | Good but possibly austere | Neutral | **Best** | Poor (variable time) | Poor (credibility, gambling adjacency) |

**Arbitration:**
- **H2 has the strongest expected net value.** Keep the H1 residue as-is because removal has a cost and no proven harm.
- H0 is the honest comparator. If evidence-forward presentation does not beat it on learner comprehension or meaningful return, there is no reason to build more.
- H3 is deferred until a Human return problem is observed.
- H4 is rejected.

**Uncertainty:**
- High that H4 is wrong for Sharky.
- Moderate that H2 beats H1-as-is on learning comprehension.
- **Low** on whether H2 improves *return rates*. There are no data. Delayed proof might feel less rewarding in sessions 1–2.

---

## F. Sharky-specific recommendations (5)

All are **research and validation proposals only**. None is an implementation requirement, and none changes S11 or current dispatch.

**1. KEEP XP values and award rules unchanged. Keep XP visually secondary to evidence.**
- *Mechanism:* avoid churn on a working, farm-resistant counter. Prevent XP from becoming the payoff climax.
- *Benefit:* preserves legible volume without crowd-out or skill-misreading.
- *Evidence:* #1, #8, #17.
- *Confidence:* moderate–high.
- *Risk:* minimal.
- *Cost:* zero.
- *Falsifier:* Human sessions show learners citing XP as evidence they "got better", or replaying content for XP. That would trigger demotion. Alternatively, removing XP in a prototype causes no comprehension or return loss. That would make XP optional.
- *Stage:* already true. Re-check at P02 and at S13–S15 observation.

**2. REFINE the Session Summary and earned-moment hierarchy toward the correction and proof event (H2 presentation, no new engine).**
- *Mechanism:* lead with "the clue you now read better" and its provenance (repaired / independent / held after time). XP and completion are secondary.
- *Benefit:* informational competence feedback at the task level, and a learner-visible separation of performance from learning.
- *Evidence:* #4, #5, #16–18.
- *Confidence:* moderate (mechanisms strong, display effect untested).
- *Risk:* early sessions have little delayed evidence, so the Summary may feel thin. Needs a "learned with help / not yet proven" honest state.
- *Cost:* low (copy and layout on existing state). Master Plan §6 already describes this intent.
- *Falsifier:* a moderated comparison of an XP-forward vs evidence-forward Summary mock. If participants cannot state what they learned any better, or prefer XP-forward *and* show equal recall, H2 presentation gives no advantage.
- *Stage:* a no-code or Figma prototype inside an admitted Human gate (P02 or later). Not before.

**3. KEEP due-work as the sole default return reason. Do not add a daily streak. Phase out loss framing wherever a streak exists.**
- *Mechanism:* "Ready to recheck" uses the spacing mechanism as the return motive. Informational, not controlling.
- *Benefit:* return aligned with retention, autonomy preserved, no broken-streak drop-off.
- *Evidence:* #11–#15. Master Plan §9 and the Lean decision already set this direction.
- *Confidence:* moderate–high that it beats streaks for learning. Low on the return-rate magnitude.
- *Risk:* fewer returns on days with nothing due. Mitigate with the honest optional-practice offer the Lean doc already specifies.
- *Cost:* zero to low. If the August-snapshot `streakDays` / `three_day_streak` seed is still surfaced on main, it warrants an owner review of its framing. That is not an automatic removal.
- *Falsifier:* real elapsed-time cohorts (S13–S15) show due-work learners return materially less **and** retain no better than a cohort shown lightweight, non-punitive routine recognition.
- *Stage:* S13–S15 Human return trials, using the existing scheduler and existing `day2_return` / `review_kind` events.

**4. REFINE Profile / You to show categorical concept evidence states, not scores.**
- *Mechanism:* per concept family, show *needs repair → recovered → held after time → applied in a new spot*, plus a short repaired-mistake history. No percentages, ratings or radar charts.
- *Benefit:* a durable, honest progress identity ("I used to miss X; now it holds"). A clear next objective counters the post-goal slump (#19).
- *Evidence:* Usher & Pajares, #18, #19. Master Plan §9 bans unfounded ratings; this design does not need any.
- *Confidence:* moderate.
- *Risk:* new users have an empty map, so it needs a good empty state. A "regressing" state could discourage, so frame lapses as normal forgetting.
- *Cost:* low–moderate (projection of existing Durable Retention verdicts).
- *Falsifier:* learners in a usability test misread the states, find them discouraging, or cannot locate their progress any better than with XP or completion counts.
- *Stage:* S10-class "honest saved Profile" scope if the owner admits it. Validate at P02 or later.

**5. DEFER and do not test now: streaks, achievement catalogs, levels, ranks and economies (H3/H4).**
- *Mechanism:* opportunity cost and risk control.
- *Evidence:* #9–#13, Zendle & Cairns.
- *Confidence:* high for H4, moderate for H3.
- *Falsifier for reopening:* Human data shows a *return* problem that due-work plus honest next steps cannot solve, with sufficient sample and real elapsed time.
- *Stage:* only after S13–S15 return evidence and a separate owner admission.

---

## G. What should remain unchanged

- The Durable Retention state machine, intervals, transfer gates and claim boundaries.
- Assistance provenance (`quickHint` / `theoryRecall` / `legacyUnknown` / `none`). Assisted correctness is never treated as proof.
- Repair-debt integrity: only an independent matched repair closes debt.
- XP values and award rules, including 0 XP on re-completion.
- `unlocked ≠ completed`. No fake success in Home, Review or Summary.
- The event family and telemetry semantics. **No research-only telemetry.** `review_kind` plus existing events suffice for the proposed analyses.
- Modern Table visuals, the S11 executor, and current B5/S-stage dispatch.
- The Master Plan §9 bans, which this research independently supports.

---

## H. What only Human evidence can establish

1. Whether adult novices **notice and value** evidence states over XP, or skim past both.
2. Whether a correction-focused payoff *feels* rewarding or reads as "you were wrong".
3. Whether learners **return after real elapsed time** for due rechecks, and whether those rechecks succeed. These are retention and transfer, not app opens.
4. Whether early sessions (before any delayed evidence) feel motivating enough without heavier rewards.
5. How much XP, if any, shapes behavior: replays, avoidance, or self-assessment.
6. Whether any streak-like signal produces **pressure or anxiety** in this population.
7. Whether in-app transfer predicts **real-poker decisions**.
8. Whether any of this affects **willingness to pay**. That is a separate market gate. No inference from learning data alone.

Metric separation to enforce in every future read-out:

| Metric | What it measures | What it cannot show |
|---|---|---|
| D1/D7/D30 opens | App engagement | Learning |
| Voluntary meaningful reps | Purposeful return | Retention |
| Session completion | Persistence | Understanding |
| Spaced recheck accuracy | In-app retention | Real-poker transfer |
| Unseen-spot accuracy | In-app transfer | Long-term retention |
| Real-hand decisions | Real-poker transfer | WTP |
| Purchase or price choice | Willingness to pay | Learning |

Where rewards can raise one metric while harming another:
- **Streaks:** raise D7 opens, but the reps they drive tend to be trivial ones done to keep the streak alive.
- **XP:** raises completion, but the experience inflates the learner's self-assessment.
- **Celebration of easy correct answers:** raises session satisfaction but adds no proof.

---

## I. Three strongest counterarguments

1. **"Gamification works on average; you're leaving engagement on the table."**
   - *The argument:* meta-analyses report positive pooled effects (g .25–.82; #6, #7). Without return there is nothing to retain. A purist H2 could lower opens enough to starve the spaced-review loop.
   - *Reversal condition:* real cohorts show an evidence-forward experience has materially **lower meaningful return**, with no gain in recheck accuracy or comprehension, compared with an H1/H3-light variant.
2. **"Delayed proof is too slow for novices."**
   - *The argument:* spaced evidence takes 24h–7d. Session 1 has almost nothing durable to show. The goal-gradient and immediate-feedback literature favors fast, visible progress (#19). XP fills that gap honestly.
   - *Reversal condition:* P02-type sessions show first-session participants find evidence states confusing or deflating, while an immediate progress signal improves their willingness to do another rep without increasing overconfidence. H1 should then stay more prominent early and H2 should take over later.
3. **"Subscription businesses need habit loops; the category winners use streaks."**
   - *The argument:* commercial retention may depend on routine more than on learning quality. A premium learning app that never builds a habit may not survive to deliver learning at all.
   - *Reversal condition:* market-gate data shows paying users cite routine or habit as the main value, and a flexible, non-punitive routine recognition (weekly, recoverable, no loss copy) improves paid retention **without** worsening recheck accuracy or self-reported pressure. H3-light would then be admissible.
   - *Note:* competitor popularity alone does not meet this bar.

---

## J. Final verdict

| Element | Disposition | One-line reason |
|---|---|---|
| XP rewards | **KEEP** (unchanged values; visually secondary) | Farm-resistant volume counter. No evidence it builds skill, no evidence it currently harms. |
| Completion rewards | **REFINE** (presentation) | Recognize *what is now readable*, not the act of finishing. |
| Streaks | **DEFER** (no daily streak; no loss framing anywhere) | Log-goal and broken-streak drop-off risk. Rigid rhythms underperform. A single miss does not hurt habits. |
| Achievements | **DEFER** (no catalog; evidence events live inside Summary and Profile) | Activity badges are extrinsic and decay. Master Plan §9 already blocks arbitrary badges. |
| Skill progression | **REFINE** (categorical evidence states from existing Durable Retention verdicts) | Mastery experience without invented percentages. |
| Session Summary celebration | **REFINE** (correction and proof first; brief; task-level, not person-level praise) | Informational, task-focused recognition is the best-supported form. |
| Return motivation | **KEEP** (due-work and missed-clue return as default; informational copy) | Return reason equals learning mechanism. Already SSOT direction. |

**Validation handoff (for the owner, not dispatch):** At the next owner-admitted Human gate, run one moderated, no-code comparison: an **XP-forward vs evidence-forward Session Summary/Profile mock** on the same learner run. Measure:
- whether participants can state the clue they learned and whether it was proven alone;
- whether they choose another rep;
- unprompted mentions of pressure or overconfidence.

Then, at S13–S15, read meaningful return and spaced-recheck accuracy from the existing `day2_return` / `review_kind` events after real elapsed time. Add no new telemetry. Treat any D7 difference as engagement, not learning, unless it comes with recheck accuracy.

`SHARKY_BEHAVIORAL_RETENTION_RESEARCH_V1 — COMPLETE / EVIDENCE_LIMITED`