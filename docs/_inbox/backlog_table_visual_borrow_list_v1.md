# Table Visual + Coach Layer Borrow List v1

Status: DEFERRED

## Goals
- Make the table feel like a scene (viral).
- Reduce empty felt feeling in seat-quiz without clutter.
- Build a universal instruction system for seamless Theory -> Runner.
- Ensure the system scales to 6-max, 9-max, 10-max, and multi-street board/hero states.

## References (descriptive)
- Ref: action buttons (Fold/Call/Raise/Shove) with strong hierarchy and clear tap targets.
- Ref: archetypes table with speech bubble guidance anchored to the scene.
- Ref: theory slideshow with focus highlight that directs attention to one object.
- Ref: bet slider with big bet button and clear amount emphasis.
- Ref: our current runner table (post Viral Table v1) as the baseline to preserve table dominance.

## Borrow List (Actionable)
- Chips-as-objects for pot, toCall, and bets (deterministic visuals, no physics).
- Coach bubble style (one thought) anchored to a table object as an optional layer.
- Focus highlight system for seat, board, pot, hero, and action targets.
- Bottom coach strip (1-2 lines) plus Step Rail (dots) as universal Coach Layer v1.
- Slider sizing pattern for future bet sizing UX (deferred).

## Avoid List
- Big center overlays that cover board or hero cards.
- Heavy blur, glow, or other perf-risk effects.
- HUD overload with too many labels visible at once.
- Non-deterministic animations.

## Proposed Universal Component Contract (Coach Layer v1)
- `stepRail + coachStrip + focusHighlight`
- Long text stays in Details only.
- Single primary CTA progression (`NEXT` or `CONTINUE`).
- Same component used in Theory and Runner (mode switch, not screen switch).

## Measurable DoD (Future Activation)
- No overlap with seats, board, or hero in proofs.
- Table dominance meets target with minimal chrome.
- Store-assets proofs updated for both 6-max and 9-max.

## Activation Trigger and Phased Plan
- Phase 1: Coach Layer v1 in runner (seat-quiz only).
- Phase 2: Extend Coach Layer v1 to hand-loop plus board/hero scenes.
- Phase 3: Unify Theory -> Runner per scenario (no extra taps).
- Phase 4: Optional archetypes layer (deferred).
