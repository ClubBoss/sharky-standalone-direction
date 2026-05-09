### Psi-2 Sharky-Guided First Spot

Psi-2 is your first interactive hand with Poker Analyzer. Sharky, the professional guide, walks you through a simple BTN vs BB single-raised pot on a dry flop. You learn how Tier-A, the Emotional State Machine (ESM), and Attention/Tone (AT) models inform coaching, and how V4 visuals keep the table readable. The goal is to act once, see feedback, and understand how the system responds.

[[IMAGE: psi2_flow | first spot flow]]

Start with the spot: BTN opens, BB defends, flop K72r. Sharky explains the baseline line: cbet_small for range edge and fold equity. The action buttons and bet sizing lane are clearly highlighted by V4 visuals: consistent colors, spacing, and tooltips from the inline explanation binder. If V4 is off, the fallback is clean but less vivid; onboarding defaults to V4 on.

Persona stack in action: Tier-A reads passive signals (calm, focus, tension). ESM refines them into states like momentum or struggle. AT tracks attention level and tone. Behavioral fusion and dynamics merge these signals, while persona-driven outputs feed coaching. Sharky translates this into pacing hints: if attention is high, guidance is firmer; if tension rises, pacing slows and safety hints appear. Coaching remains deterministic and ASCII-only; no animations or surprises.

Sharky guidance sequence:
1) Preflop reminder: BTN open already made; focus on flop plan.
2) Flop tip: small cbet is default; check_back is a safe alternative to compare.
3) After action: coaching hook surfaces a short suggestion (for example, "keep pace" or "slow down") based on heuristics.
4) Inline tooltip: hover the help icon on action buttons to see short reasons.

Exploit versus balance: Sharky notes that on dry boards with range advantage, small cbet aligns with both exploit ideas and a simple GTO contrast. If BB is overfolding (from Psi-1 signals or later data), the small bet gains even more. If coaching detects struggle or low attention, it may prefer check_back for stability. This contrast is kept simple: no complex trees, only clear, actionable choices.

V4 visual clarity: table surface, hole cards, action buttons, and bet lane use consistent spacing and shadow. Help icons reference the inline explanation binder. Cohesion checks run in the background; if any visual or persona inconsistency is found, advice is suppressed until resolved.

Onboarding arc: Psi-1 prepared you with narrative and structure; Psi-2 is the first live decision. After this hand, you move toward Psi-3, where more board textures and turn decisions appear. The same persona stack will guide you, scaling difficulty as your engagement and attention allow. Short cycles-act, read, adjust-remain the pattern.

What to expect:
- One flop decision: choose cbet_small or check_back.
- Immediate feedback: a short coaching tip and tone.
- Optional replay: take the other line to compare responses.
- Clear visuals: V4 on by default, toggleable if needed.

By finishing Psi-2, you complete the first interactive step: you see how persona signals influence advice, how V4 visuals support decision clarity, and how Sharky keeps guidance concise. You are now ready for Psi-3 and deeper paths (MTT or Cash), carrying the same stable coaching loop forward.
