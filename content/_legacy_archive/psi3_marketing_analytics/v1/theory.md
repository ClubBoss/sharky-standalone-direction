### Psi-3 Marketing Analytics Polishing

Psi-3 focuses on how Poker Analyzer tracks onboarding funnels, retention loops, and early-signal analytics while keeping persona and coaching signals aligned with V4 visuals. The goal is to make marketing insights deterministic and readable so product and coaching teams see the same signals. This module links the first 24 hours of usage to 7-day conversion metrics, showing how early accuracy, speed, and friction data feed persona guidance.

[[IMAGE: psi3_flow | marketing analytics flow]]

Positions referenced: UTG, MP, CO, BTN, SB, and BB anchor the sample spots tracked in analytics.
GTO contrast: instead of perfectly balanced ranges, Psi-3 favors exploit-ready marketing signals tuned to observed friction and engagement.

Funnel stages: arrival (install and first open), orientation (Psi-1 narrative), first action (Psi-2 spot), depth (Psi-3 decisions), and retention checkpoints (day 1, day 3, day 7). Each stage records accuracy (decision correctness), speed (time to act), and friction (help taps, backtracks). The data stays ASCII-only and deterministic, with no hidden sampling.

Retention loops: daily nudges tie to coaching signals. If attention is high and friction low, the system suggests deeper content; if friction rises, pacing slows and safety tips increase. Early wins (correct actions) boost reward weights; streaks over day 1 to day 7 feed a simple XP curve. Marketing reads the same signals to time re-engagement: short sessions for high-pressure users, longer for calm, focused ones.

Early-signal analytics: accuracy, speed, and friction form the core metrics. Accuracy tracks correct vs incorrect decisions; speed measures time-to-action buckets; friction counts help requests and backtracks. V4 persona/coaching influence appears through tone and pacing hints: engaged users see firmer tone and more advanced suggestions; struggling users see safer options. These signals are logged deterministically for analytics dashboards.

Session-length heuristics: 10-15 minutes for tension-prone users, 20-30 minutes for calm users, and short repeats for high-focus but variance-sensitive users. Marketing uses these heuristics to time notifications and surface content. Persona signals adjust session recommendations without changing UI: coaching tone and pacing guide users to stop or continue.

First 24h -> 7d conversion: day 0 covers install to first action; day 1 measures repeat opens and successful completion of the first spot; day 3 checks whether users try a new board texture; day 7 measures retention and XP streak continuity. Metrics stay bounded: accuracy 0-1, speed buckets labeled, friction as counts. Reports align with persona and coaching states so marketing, product, and coaching see one source of truth.

V4 persona/coaching influence on marketing signals: Tier-A, ESM, and AT feed fusion and coaching; coaching outcomes (tone, pacing, hooks) feed analytics events. V4 visuals ensure consistent surfaces so action logging is stable. If cohesion or token checks fail, marketing signals pause until corrected, preventing polluted data.

Next steps: this module prepares you to interpret analytics in Psi-4 and beyond, where more complex spots and retention experiments appear. The same deterministic pipeline supports MTT and Cash paths, keeping marketing, coaching, and persona data aligned.
