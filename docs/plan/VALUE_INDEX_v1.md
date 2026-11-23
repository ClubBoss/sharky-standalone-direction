# Sharky · Value index v1.1 (2026-11-23, after Codex second opinion)

The single priority index for all work. Built by `build_value_index.py` (rerun after any score change); data in `value_index_v1.json`; personas and shares in `personas_v1.md`.

## Method
- `reach` = Σ share(persona) × hit(persona); shares **P1 30% · P2 40% · P3 20% · P4 10%** (v1.1; v1 was 25/45/20/10).
- `impact` = **0.40·activation + 0.40·d7_retention + 0.20·willingness_to_pay** (v1.1; brief default 0.35/0.35/0.30, see «Second opinion»), each 0–3.
- `confidence` 0.5 / 0.8 / 1.0. `effort_days` = agent days (designer days for **D** items, owner days included for **O**).
- `unblock` ×1.0–1.5 for items that let other value land (screen logic before visual, H1 before H2–H5, F2 before 9-max content).
- `index = reach × impact × confidence × unblock / effort`.
- **Kano.** `basic` = absence caps value: a basic item that gates beta (**G**) is Now regardless of index; a basic item with low index is still never Drop. `indifferent` → Drop.
- **Gates are not ranked (v1.1).** Pure verification/distribution gates (A8, V9, beta, F1 device measurement, Q14/P8/P5, REL-02/03) get direct impact 0 and rank «—»: the critical path schedules them, the index ranks learner improvements. Fixes that a gate run finds get their own row.
- **Tiers.** Now (before beta) = G, or index ≥ 0.30. Next (before 1.0) = index ≥ 0.08. Later ≥ 0.03. Drop < 0.03.
- **Rules on top of the formula** (all stated, none hidden):
  1. NEW ideas are capped at Next: CLAUDE.md forbids new feature scope without an owner decision.
  2. **Prerequisite lift (v1.1):** a prerequisite is lifted to the tier of what it unlocks (H1 → Now because H2 is Now); NEW dependents do not lift. Prerequisites set start order, not value.
  3. Excluded-on-purpose items (**X**) keep their owner placement: monetization Next (after beta WTP data), bots/coach/RU/a11y polish Later.
  4. REL-02/03 is Next: it gates 1.0, not the TestFlight beta.
- Flags: **M** merged into another row (counted once) · **G** beta gate · **D** depends on the designer · **O** owner action · **X** excluded on purpose · **NEW** new idea.
- Statuses come from `atlas_data/roadmap_joined.json` (re-joined 12:45) plus lead_state merges up to 21:20; items fully merged since (T1, T3, T4, B19, F1) are not scored.

## Index table
| # | ID | Item | Reach | A/R/W | Imp | Conf | Eff d | Kano | Unbl | **Index** | Tier | Was | Flags | Monetization |
|---:|---|---|---:|---|---:|---:|---:|---|---:|---:|---|---|---|---|
| — | VI-05 | A8 signed RC, launch time, reinstall/new device (REL-01, PER-01, DAT-07.b) | 1.00 | 1/1/0 | 0.80 | 1 | 1.5 | basic | 1.5 | **0.800** | Now · gate (critical path, scheduled by dependency) | — | G O | free |
| 1 | VI-01 | B23 screen logic, view models, states, designer handoff | 1.00 | 2/2/1 | 1.80 | 0.8 | 3 | basic | 1.5 | **0.720** | Now | Now | G | free |
| 2 | VI-09 | ASM-03.a / CUR-02.a W1–W4 grades and concepts remainder | 0.75 | 2/1/0 | 1.20 | 0.8 | 1 | basic | 1.0 | **0.720** | Now | Now | G | free |
| 3 | VI-11 | T2 finish #764 (HST-03.b, HLP-02.b, LRN-01.b) | 0.47 | 0/1/1 | 0.60 | 0.8 | 0.5 | linear | 1.1 | **0.502** | Now | Now |  | free |
| 4 | VI-13 | H2 summary + paused street frames (logic; look = designer) | 0.65 | 1/2/0 | 1.20 | 0.8 | 2 | basic | 1.2 | **0.374** | Now | Next | D | free |
| 5 | VI-02 | V6 screens outside the table (VIS-04.b, VIS-05.b) | 1.00 | 3/2/3 | 2.60 | 0.8 | 8 | basic | 1.3 | **0.338** | Now | — | G D | free |
| 6 | VI-40 | Goal-based route (online cash / home game / live / MTT) | 1.00 | 2/2/1 | 1.80 | 0.5 | 3 | linear | 1.0 | **0.300** | Next | new | NEW | free |
| 7 | VI-03 | V7 assets: rights, quality, pack, icon, Sharky expressions (VIS-08.a/b, MSC-01.a) | 1.00 | 2/1/0 | 1.20 | 0.8 | 4 | basic | 1.2 | **0.288** | Now | — | G D | free |
| 8 | VI-14 | B21 H3 fix history gaps + migrate ~1,300 trails | 0.90 | 1/1/1 | 1.00 | 0.8 | 3 | basic | 1.2 | **0.288** | Next | Now |  | free |
| 9 | VI-36 | Full-hand play-through: decide on every street (H5 / O5) | 0.75 | 1/2/2 | 1.60 | 0.8 | 4 | linear | 1.0 | **0.240** | Next | new | NEW | free |
| 10 | VI-10 | CUR-01.b / CUR-04.b / CUR-05.b / TRN-06 W5–W12 remainders | 0.72 | 0/2/0 | 0.80 | 0.8 | 2 | basic | 1.0 | **0.232** | Next | Now |  | free |
| 11 | VI-34 | Leak dashboard: accuracy by position/street/skill + trend | 0.55 | 0/2/3 | 1.40 | 0.8 | 3 | linear | 1.1 | **0.226** | Next | new | NEW D | premium-candidate |
| 12 | VI-20 | B15 F3 9-max tasks into catalog behind visual gate | 0.50 | 0/1/2 | 0.80 | 0.8 | 1.5 | linear | 1.0 | **0.213** | Next | Now | D | premium-candidate |
| 13 | VI-25 | B16 «Живой зал» live-room lessons into catalog | 0.42 | 1/1/2 | 1.20 | 0.8 | 2 | delight | 1.0 | **0.204** | Next | Next |  | free |
| 14 | VI-12 | B20 H1 typed hand timeline (one record for earlier streets) | 0.65 | 0/1/0 | 0.40 | 1 | 2 | basic | 1.5 | **0.195** | Now | Now |  | free |
| 15 | VI-38 | Pre-session warm-up: 5 min from your own leaks | 0.36 | 0/3/2 | 1.60 | 0.5 | 1.5 | delight | 1.0 | **0.195** | Next | new | NEW | premium-candidate |
| 16 | VI-24 | B18 practice generator for W13+ | 0.45 | 0/3/2 | 1.60 | 0.8 | 3 | linear | 1.0 | **0.192** | Next | Next |  | premium-candidate |
| 17 | VI-26 | More task formats: timed drill, «slightly harder» step | 0.75 | 0/2/1 | 1.00 | 0.5 | 2 | delight | 1.0 | **0.188** | Next | Next |  | free |
| 18 | VI-22 | B4–B8 W17–W24 transfer behind flag (CUR-09.a) | 0.55 | 0/2/3 | 1.40 | 0.8 | 4 | linear | 1.2 | **0.185** | Next | Now |  | premium-candidate |
| 19 | VI-37 | Opponent-style drills (scripted tight/loose/aggressive, no bots) | 0.57 | 0/2/2 | 1.20 | 0.8 | 3 | linear | 1.0 | **0.184** | Next | new | NEW | premium-candidate |
| 20 | VI-39 | Returner refresher: re-placement + resume + spaced refresh | 0.30 | 2/3/1 | 2.20 | 0.5 | 2 | basic | 1.0 | **0.165** | Next | new | NEW | free |
| 21 | VI-29 | GRO-01 / GRO-02 remaining device checks | 0.25 | 0/1/0 | 0.40 | 0.8 | 0.5 | linear | 1.0 | **0.160** | Next | Next |  | free |
| 22 | VI-19 | F2 9-seat engine logic (pots, side pots up to 9) | 0.50 | 0/1/2 | 0.80 | 0.8 | 3 | linear | 1.3 | **0.139** | Next | Now |  | free |
| 23 | VI-41 | Chart library: preflop by position/stack, 6-max/9-max, push/fold | 0.38 | 1/2/1 | 1.40 | 0.5 | 2 | linear | 1.0 | **0.131** | Next | new | NEW D | premium-candidate |
| 24 | VI-21 | 9-seat table visual | 0.50 | 1/1/2 | 1.20 | 0.8 | 5 | linear | 1.3 | **0.125** | Next | Next | D | free |
| 25 | VI-35 | Own-hands leak finder PILOT: existing import + one validated leak→drill mapping | 0.30 | 1/3/2 | 2.00 | 0.5 | 2.5 | delight | 1.0 | **0.120** | Next | new | NEW | premium-candidate |
| 26 | VI-15 | H4 replayer controls (speed, scrub, street jump) | 0.47 | 0/1/1 | 0.60 | 0.8 | 2 | linear | 1.0 | **0.114** | Next | Next | D | premium-candidate |
| 27 | VI-18 | HST-06.b more import formats (GG, ACR, Winamax…) | 0.30 | 0/2/3 | 1.40 | 0.8 | 3 | linear | 1.0 | **0.112** | Next | Next |  | premium-candidate |
| 28 | VI-17 | B14 HST-06.a widget scenario + HST-04 find/explain/new-spot | 0.23 | 0/1/1 | 0.60 | 0.8 | 1 | linear | 1.0 | **0.108** | Next | Now |  | free |
| 29 | VI-43 | Spot search: find the lesson by position/street/concept | 0.38 | 1/1/1 | 1.00 | 0.5 | 2 | linear | 1.0 | **0.094** | Next | new | NEW | free |
| 30 | VI-23 | B9–B13 W25–W36 transfer + Claude review W28–W36 (CUR-09.b) | 0.35 | 0/1/3 | 1.00 | 0.8 | 5 | linear | 1.1 | **0.062** | Later | Now |  | premium-candidate |
| 31 | VI-31 | Bots: legal limited bots, freer mode (BOT-01/02) | 0.75 | 1/3/3 | 2.20 | 0.5 | 15 | delight | 1.0 | **0.055** | Later | Later | X | premium-candidate |
| 32 | VI-32 | AI coach with safe fallback (COA-01.a–c) | 0.50 | 1/2/3 | 1.80 | 0.5 | 12 | delight | 1.0 | **0.038** | Later | Later | X | premium-candidate |
| 33 | VI-30 | COM-01–04 monetization (free/paid line, paywall, offer) | 0.72 | 0/0/3 | 0.60 | 0.5 | 6 | basic | 1.0 | **0.036** | Next | Next | X O | premium-candidate |
| 34 | VI-42 | Push/fold + ICM quick trainer (MTT) | 0.12 | 0/2/2 | 1.20 | 0.5 | 3 | linear | 1.0 | **0.025** | Drop | new | NEW | premium-candidate |
| 35 | VI-44 | Share a spot as a quiz to a friend | 0.25 | 1/0/0 | 0.40 | 0.5 | 2 | delight | 1.0 | **0.025** | Drop | new | NEW | free |
| 36 | VI-27 | A11y and motion polish beyond store minimum (ACC-03/04 rest, ACC-04.b, JRN-04 long answers) | 0.10 | 1/1/0 | 0.80 | 0.8 | 3 | basic | 1.0 | **0.021** | Later | Later | X | free |
| 37 | VI-45 | Session and bankroll log | 0.20 | 0/1/1 | 0.60 | 0.5 | 3 | indifferent | 1.0 | **0.020** | Drop | new | NEW | premium-candidate |
| 38 | VI-33 | RU localisation (LOC-01.b) | 0.10 | 2/1/1 | 1.40 | 0.5 | 8 | linear | 1.0 | **0.009** | Later | Later | X | free |
| — | VI-04 | V9 final screenshot run W1–W12 on iPhone | 1.00 | 0/0/0 | 0.00 | 1 | 1 | basic | 1.3 | **0.000** | Now · gate (critical path, scheduled by dependency) | — | G D | free |
| — | VI-06 | Beta: quiet test + TestFlight 10–20 (O2, B0, JRN-04 human) | 1.00 | 0/0/0 | 0.00 | 0.8 | 2 | basic | 1.5 | **0.000** | Now · gate (critical path, scheduled by dependency) | — | G O | free |
| — | VI-07 | F1 first fold/call/raise ≤ 3 min, measured on device | 0.60 | 0/0/0 | 0.00 | 0.8 | 0.5 | basic | 1.0 | **0.000** | Now · gate (critical path, scheduled by dependency) | — | G O | free |
| — | VI-08 | Q14/P8 maps rebuild + P5 two audits (internal gate) | 0.25 | 0/0/0 | 0.00 | 1 | 0.5 | basic | 1.2 | **0.000** | Now · gate (critical path, scheduled by dependency) | — | G | free |
| — | VI-16 | LRN-01.a confidence + mistake reason (logic in B23, widget in V-wave) | 0.90 | 0/0/0 | 0.00 | 0.5 | 1.5 | linear | 1.1 | **0.000** | Now · merged | Now | D M | free |
| — | VI-28 | REL-02.a / REL-02.b / REL-03 store, legal, support, GO/rollback | 1.00 | 0/0/0 | 0.00 | 1 | 1 | basic | 1.2 | **0.000** | Next · gate for 1.0 | — | O | free |

## Critical path to beta (scheduled by dependency, not by index)
V6 (designer) + V7 (designer) → V9 screenshot run → beta. In parallel: B23 (screen logic, so V6 drops in), W1–W4 truth (B26), Q14/P8/P5 maps and audits, A8 signed RC (owner Apple access), F1 device timing. LRN-01.a logic rides inside B23.

## Top 10 learner improvements (ranked, v1.1)
1 VI-01 B23 screen logic 0.720 · 2 VI-09 W1–W4 grades/concepts 0.720 · 3 VI-11 T2 #764 finish 0.502 · 4 VI-13 H2 street summary logic 0.374 · 5 VI-02 V6 screens (designer) 0.338 · 6 VI-40 goal-based route (NEW) 0.300 · 7 VI-03 V7 assets (designer) 0.288 · 8 VI-14 B21 H3 trail gaps 0.288 · 9 VI-36 full-hand play-through (NEW) 0.240 · 10 VI-10 W5–W12 partials 0.232. H1 (VI-12, 0.195) is lifted to Now as H2's prerequisite.

## Moves against today's Backlog

**Pulled forward that should move back**
| Item | Was | Tier | Why |
|---|---|---|---|
| VI-19 F2 9-seat engine (effort high) | Backlog #2 | Next | 0.139: high cost, beta is 6-max, value lands only with the designer's 9-seat table. Start after B20 + B24 (H2) and B23. |
| VI-20 B15 9-max tasks to catalog | Backlog #7 | Next | Hidden behind the visual gate; needs F2. |
| VI-22 B5–B8 W19–W24 transfer | Backlog #5 (chain) | Next | 0.185: beta testers rarely reach W13+. Finish B4 (running), then the [C] slot goes to B21 H3 and B26 first. |
| VI-23 B9–B13 W25–W36 transfer (+ Claude review W28–W36) | Backlog #5 | Later | 0.062: zero reach while the flag is closed; specs are done, nothing is lost by waiting. Review rows only as a cheap tick filler. |
| VI-17 B14 HST-06.a widget scenario + HST-04 | Backlog #6 | Next | 0.108, low reach. |
| VI-10 W5–W12 partials | «Now» in PLAN 1.2 | Next | 0.232 after WTP set to 0 (Codex); still in B26 because it shares the audit, but W1–W4 parts go first. |

**Pushed back that should come forward**
| Item | Was | Tier | Why |
|---|---|---|---|
| VI-13 H2 summary + street frames (logic) | briefed only after H1 accepted | Now | 0.374; logic is designer-independent. Brief B24 now, start right after B20 merges. |
| VI-12 B20 H1 | waits T2 | Now (lifted) | Prerequisite of H2–H5; start the moment #764 merges, before F2. |
| VI-09 W1–W4 partial criteria (ASM-03.a, CUR-02.a) | partial, no package | Now | 0.720, Kano basic: truth of the free path. Brief B26. |
| VI-14 B21 H3 history gaps | after all transfer jobs in [C] | Next, first [C] after B4 | 0.288 > 0.185: fixes the line every W1–W12 learner sees. |
| VI-24 B18 generator | after W13–W24 transferred | Next, [X] lane, scoped to W13–W18 | Codex: the move needs a smaller scope and an explicit dependency change. B27 is that scope; it runs in [X], so it does not compete with [C] transfers. |
| VI-16 LRN-01.a logic | «waits the visual wave» (Backlog excluded list) | Now, inside B23 | Counted once in VI-01; only the widget waits for the designer. |

**Designer-dependent items:** VI-02 V6, VI-03 V7, VI-04 V9, VI-13 (look), VI-15 H4 (look), VI-16 (widget), VI-20 and VI-21 9-seat, VI-34 and VI-41 (look). The mechanism part of each is in `screen_vision_v1.md` and goes first.

**New ideas worth owner scope (Next, by index):** VI-40 goal-based route 0.300, VI-36 full-hand play-through 0.240, VI-34 leak dashboard 0.226, VI-38 warm-up 0.195, VI-37 opponent-style drills 0.184, VI-39 returner refresher 0.165, VI-41 chart library 0.131, VI-35 own-hands leak finder PILOT 0.120, VI-43 spot search 0.094. **Drop:** VI-42 standalone push/fold trainer (teach it in W26 practice), VI-44 quiz share, VI-45 bankroll log.

## Monetization link (input to the later study, no pricing here)
Premium-candidates by index: leak dashboard (VI-34), warm-up (VI-38), generator W13+ (VI-24), W13–W24 depth (VI-22), opponent drills (VI-37), B15 full-ring pack (VI-20), chart library extended sets (VI-41), own-hands leak finder (VI-35), H4 controls (VI-15), import formats (VI-18), W25–W36 (VI-23), bots/coach (VI-31/32). Everything in W1–W12, review basics, the table, a11y and language stays free. WTP is weighted 0.20 so it ranks, but does not drive, pre-beta work.

## Second opinion (Codex, read-only, effort medium, thread 01a2098d, 2026-11-23)
Codex's main point: «Use the critical path to schedule TestFlight gates and the index to rank learner improvements. Counting gate completion as learner impact distorts both decisions.»

**Agreed and applied in v1.1**
- Gates (A8, V9, beta, F1 measurement, Q14/P8/P5, REL) have direct impact 0 and are not ranked; critical path section added.
- T2 #764: confidence 1 → 0.8, effort 0.25 → 0.5 d, unblock 1.3 → 1.1 (0.502).
- H1: reach down (P2 0.5, others 0.75), impact 1/2/1 → 0/1/0 (data only, value via unblock). H2: impact 2/2/1 → 1/2/0.
- LRN-01.a counted once inside B23 (row VI-16 marked merged).
- V7 WTP 2 → 0; W5–W12 partials WTP 2 → 0; REL impact 0.
- Chart library: reach and confidence down (0.388 → 0.131): F1 chart is merged, 9-max needs the table.
- Own-hands leak finder rescoped to a pilot (one validated leak→drill mapping, 2.5 d): 0.060 → 0.120.
- Prerequisites set start order (lift), they no longer cap the dependent's tier.
- Generator move rationale fixed: scoped to W13–W18 in the [X] lane (B27).
- Bottom: agreed W25–W36 Later; push/fold, quiz share, bankroll log Drop; bots, coach, a11y polish, RU Later; monetization owner-gated Next.

**Partly agreed**
- Personas: Codex proposed 35/40/15/10 (more active regulars, fewer returners). Applied 30/40/20/10: P1 up, but returners kept at 20% because placement/resume data from beta is the only evidence either way. Codex's «active recreational player who never used a trainer» is recorded as a sub-group of P1 to recruit in beta.
- Weights: Codex proposed 0.45/0.50/0.05 through TestFlight. Applied 0.40/0.40/0.20: the owner explicitly allowed WTP as a ranking metric that later feeds the monetization study, so it stays non-trivial. With Codex's weights the top 10 order changes little (W1–W4 truth and B23 still top; T2 falls to 4th).

**Disagreed**
- F1 device timing at 0: agreed as a measurement, but the first-decision-in-3-minutes target remains the top activation risk; if the run fails, the fix row should be scored at activation 3.
- H2 reach 0.50: kept 0.75 for P1/P3/P4 — W5–W12 and all of W13+ are mostly postflop, so most non-beginners meet multi-street tasks within 30 days.
