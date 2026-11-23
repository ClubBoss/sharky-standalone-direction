# Sharky · Personas v1 (2026-11-23, value-index session)

Purpose: the persona weights below feed `reach` in `value_index_v1.json`. Shares sum to 100% of the **target audience** (CLAUDE.md: «micro-stakes player who makes mistakes and wants to repair them quickly»), not of all poker players.

Source keys:
- **[CLAUDE]** project CLAUDE.md product context.
- **[PLAN]** `docs/PLAN.md` on origin/main 50c08140d (route, «Сейчас», 1.x stages).
- **[CMP]** `docs/plan/COMPETITOR_COMPARISON_v1.md` (Poker Skill, River, PokerPath, Poker Power, Runout).
- **[OCA]** `docs/plan/OWNER_CONCEPTS_ADDENDUM_v1.md` (W13–W36 concepts).
- **[HH]** `l0-audit/reasoning/decisions/hand_history_presentation_v1.md`.
- **[LS]** `l0-audit/lead/lead_state.md` (owner rules 2026-11-23).
- **[A-x]** market assumption, not measured by us; confidence H / M / L. Every share is an [A] assumption until beta data (0.5.0 / 0.6.0 in PLAN) replaces it.

| ID | Persona | Share | Pays? | Confidence of share |
|---|---|---:|---|---|
| P1 | Paying / active micro-stakes regular | 30% (v1: 25%) | most likely payer | M |
| P2 | Free beginner | 40% (v1: 45%) | rarely | M |
| P3 | Returner | 20% | sometimes | L |
| P4 | Live / MTT player (optional) | 10% | sometimes | L |

Share assumptions:
- **[A-1, M]** In poker-training apps the free/beginner funnel is the largest top-of-funnel group, and the paying core is a minority of regular online players. This is typical of freemium learning apps; the 40/30 split is our estimate (v1.1 after Codex; v1 was 45/25).
- **[A-2, L]** Returners are common because recreational players play seasonally (lapse and come back). 20% is a guess.
- **[A-3, L]** Live/MTT-first players are a smaller share of app learners than online cash players, because most study tools target online cash. 10% is a guess; it is «optional» per the brief.

---

## P1 · Paying / active micro-stakes regular (30%)

Sub-group to recruit in beta (Codex): the active recreational micro-stakes player who knows the rules, repeats mistakes and has never used a trainer or bought study tools.

**Portrait.** Plays NL2–NL25 online cash, 6-max, a few sessions a week, often on GG or PokerStars. Knows the basics (positions, open ranges, pot odds) but leaks money in the same spots again and again: calling too wide on the turn, missing thin value, misreading sizes. Has tried a solver or trainer and found it too heavy. Wants a short daily loop that finds and fixes *his own* leaks, not a course from zero. This is the closest match to the target user in [CLAUDE].

| | Claim | Source |
|---|---|---|
| **JTBD** | «Find my recurring mistake and drill it until it sticks.» | [CLAUDE]; repair→recheck→Day 2/Day 7 [CMP PokerPath/River advantages] |
| | «Review the hands I actually played.» | own hands import, T1 / HST-06 [PLAN «Сейчас», T1] |
| | «See my accuracy by position/street, and whether it trends up.» | Runout gap [CMP Runout] |
| | «Know the line before the decision on turn/river.» | [HH] problem statement |
| | Depth beyond W12 (ranges, sizing, exploits). | W13–W24 plan [OCA] |
| **Stays because** | Repair loop proves the fix (retry ≠ independent Day 2/7 success). | [CMP PokerPath] |
| | No energy wall: can keep going in one session. | [CMP Poker Skill] |
| | Real numbers he can recompute (prices, thresholds). | [CMP Runout] |
| **Pays for** | Depth (W13+), own-hands analysis, leak analytics, more import formats. | [A-4, M] regulars pay for tools that touch their own results (Runout/GTO-trainer style pricing exists) |
| **Churns when** | Course feels beginner-only after W4; no link to his real hands; no solver-like comparison. | [CMP River: solver frequencies/EV gap]; [A-5, M] |

## P2 · Free beginner (40%)

**Portrait.** Learned the rules recently, plays home games or freerolls, maybe the first micro-stakes deposit. Does not know positions or what a «price» is. Opens the app for 5–10 minutes on the phone. Needs a first win in the first minutes and plain words. Most likely to install from the store page, most likely to churn in day 1.

| | Claim | Source |
|---|---|---|
| **JTBD** | «Make my first decision quickly and understand why.» | checklist F1: first fold/call/raise in 2–3 min [atlas checklist F1] |
| | «Fix a rules mistake right away.» | [CMP River advantage] |
| | «Feel progress without fake rewards.» | ENG-02 honest reward [PLAN, Roadmap done] |
| | «Not be lost at a 9-handed home table.» | 9-seat table, full ring [PLAN 1.4] |
| **Stays because** | Short lessons, honest first success, one useful next step. | ENG-01, ENG-03 done [Roadmap] |
| | Looks premium and calm (visual). | V6/V7 [PLAN 0.4.0]; [A-6, H] store conversion depends on screenshots and first-screen polish |
| **Pays for** | Rarely; maybe a one-off unlock once hooked. | [A-7, M] beginners convert below regulars in learning apps |
| **Churns when** | Wall of text before the first tap (W2 had 172 words), slow first decision, unclear screens, crashes. | [atlas checklist F1/F2]; [A-8, H] D1 churn is driven by onboarding friction |

## P3 · Returner (20%)

**Portrait.** Played a few years ago or stopped for months; coming back before a trip, a home game or a new site. Remembers fragments, overestimates their level. Wants to know «where am I now» and a quick refresher, then the new material. May be a former P1.

| | Claim | Source |
|---|---|---|
| **JTBD** | «Place me correctly and refresh what I forgot.» | placement (J1 rules check) [PLAN «Следующий блок»] |
| | «Pick up where I left off without losing progress.» | DAT-03 resume, DAT-07.b reinstall [Roadmap] |
| | «Remind me, but don't nag.» | ENG-05, RET-01 opt-in return [Roadmap done] |
| **Stays because** | Placement skips what they know; spaced Day 2/Day 7 repeats. | [CMP PokerPath advantage] |
| **Pays for** | Sometimes, when the depth beyond W12 is there. | [A-9, L] |
| **Churns when** | Placement forces basics again; progress lost on a new phone. | DAT-07.b open [Roadmap]; [A-10, M] |

## P4 · Live / MTT player (10%, optional)

**Portrait.** Plays live 1/2–2/5 or small tournaments (local MTTs, online freezeouts). Tables are 9–10 handed; stacks and ICM matter; live etiquette (verbal actions, string bets, one-chip rule) costs real money and embarrassment.

| | Claim | Source |
|---|---|---|
| **JTBD** | «Play 9-handed ranges and positions.» | F1 full-ring chart, F2/F3 9-max [LS Backlog] |
| | «Know live rules and avoid angle-shoot traps.» | B16 «Живой зал» spec [LS]; W30 [OCA] |
| | «Tournament stack and ICM decisions.» | W9 (M-ratio), W26 [OCA] |
| **Stays because** | Content that other apps (6-max online first) do not cover. | [CMP] none of 5 covers live rules; [A-11, M] |
| **Pays for** | Live/MTT packs, push/fold trainer. | [A-12, L] |
| **Churns when** | 9-seat table missing; only 6-max online examples. | PLAN 1.4 «Стол на 9 мест» (designer visual) |

---

## Persona weights used in reach

`reach = Σ share(p) × hit(p)`, where `hit(p)` is the fraction of persona p that meets the item in the first 30 days (0, 0.25, 0.5, 0.75, 1). Values are in `value_index_v1.json → persona_notes`.

## Open questions for beta (0.6.0)
1. Real split P1/P2 (store attribution + placement answer).
2. Share of 9-handed play among P2 home-game players (drives F2/B15/9-seat visual).
3. Import format demand: PokerStars vs GG vs others (drives HST-06.b).
