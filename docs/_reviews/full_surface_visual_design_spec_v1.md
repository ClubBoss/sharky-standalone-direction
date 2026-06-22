# Full Surface Visual Design Spec v1

## 1. Scope

Local-only visual/product design specification on `main` after
`c35352866d5dab4a38278b3eb0c230e2f29bb6ce`.

This is a spec, not an implementation wave. It defines the future first-week
10/10 visual direction, ranks implementation slices by product EV, and protects
the already-working proof flow:

`placement -> Welcome micro-win -> W1 decision -> feedback -> repair proof -> Review/Profile proof`

No product code, UI, copy, tests, assets, screenshot tooling, routes,
telemetry, Modern Table visuals, Sharky Character implementation,
monetization, AI/chat/ML behavior, dashboard/charts, XP, or economy work
changed.

## 2. Evidence used

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/full_surface_ux_ui_coherence_audit_v1.md`
- `docs/_reviews/first_week_proof_packet_acceptance_v1.md`
- `docs/_reviews/first_week_proof_packet_capture_lane_v1.md`
- `docs/_reviews/welcome_first_start_visual_acceptance_v1.md`
- `docs/_reviews/surface_role_cta_coherence_audit_v1.md`
- `docs/_reviews/sharky_character_coaching_presence_piec_v1.md`
- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/manifest.json`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

Accepted evidence gaps remain accepted for this spec:

- completed placement result is not captured;
- dynamic personalized Profile repair-return reason is not captured;
- fast-renderer button labels can appear as white bars, so the packet is not
  final CTA-copy screenshot proof.

## 3. Current first-week visual verdict

The first-week product story is now coherent and reviewable, but it does not
yet look like a finished 10/10 commercial surface system.

Strengths:

- the table is readable enough to carry the learning proof;
- the first-use Welcome micro-win makes activation tangible;
- feedback explains visible table signals, not only correct/wrong status;
- repair focus/result/session proof makes the learning effect concrete;
- Review and Profile support the proof loop without becoming heavy analytics.

Main visual weakness:

- the experience still reads as a sequence of competent functional panels, not
  a tightly authored premium first-week product. The next visual pass should
  improve hierarchy, rhythm, and proof emphasis before decorative polish.

## 4. Target visual principles for Sharky 10/10

1. **One real spot, one clear action, one clear why.** Every screen should make
   the current table signal and current action obvious within seconds.
2. **Proof beats polish.** Visual hierarchy must first strengthen learning
   causality: choice -> signal -> reason -> repair -> proof.
3. **Card hierarchy, not card stacking.** Screens may use cards, but the user
   should see one dominant role per surface.
4. **Table leads decision moments.** In runner states, the table should feel
   like the evidence source; cards below it should explain, not compete.
5. **Feedback stays emotionally light.** Wrong/repair states should feel calm,
   specific, and fixable.
6. **Repair proof is ceremonial but compact.** Repair result and session repair
   need enough emphasis to feel like progress, without becoming a dashboard.
7. **Progress is proof, not economy.** Profile should mirror real improvement,
   not sell XP, score, or fake mastery.
8. **Sharky appears only next to evidence.** Mascot/presence should support
   route orientation, table prompt, feedback, or summary transition; it should
   not become decorative noise.
9. **Commercial readiness without monetization.** The first week should feel
   premium and trustworthy before any paywall/trial/premium CTA appears.
10. **Modern Table remains stable.** The table can receive framing/spacing
    support around it, but table visuals themselves stay maintenance-only
    unless a real readability regression appears.

## 5. Surface-by-surface visual spec

| Surface | Current issue | Product EV | Recommended visual direction | Risk | Priority |
| --- | --- | --- | --- | --- | --- |
| Placement | Intro is clear but visually close to the rest of the dark-card system. | Faster first understanding; first-week trust. | Keep short route-check framing; make placement feel like the entry gate with one calm primary path and reduced secondary visual weight. | Over-polishing could make it feel like a long onboarding course. | P2 |
| Welcome | Now has the right micro-win, but decision/feedback/handoff rhythm can feel like runner UI inserted into onboarding. | Faster first value; stronger activation. | Give Welcome a distinct first-start wrapper: route beat -> table beat -> handoff beat should share one progress/rhythm treatment. | Too much ceremony could slow the first hand. | P1 |
| Home | Not in first-week packet; prior evidence says CTA ownership is structurally sound. | Clearer next action. | Maintenance for now; future pass should verify mission card dominance in `core_fast` before changing. | Changing Home without evidence can destabilize route ownership. | P3 |
| Learn | Accepted route clarity; not central in first-week packet. | Route confidence. | Maintenance; keep route/current-concept hierarchy and avoid making it resemble Practice. | Cosmetic map polish can distract from first proof. | P3 |
| Practice | Role is reinforcement; not central in first-week packet. | Habit clarity. | Maintenance; ensure future visuals keep Practice as rep surface, not second Learn. | Adding cards can create CTA competition. | P3 |
| Runner decision | Table and options are readable, but table-to-question rhythm is dense on compact phone. | Clearer decision and less cognitive load. | Improve spacing/anchoring around prompt/options below table; preserve table size and Modern Table visuals. | Touching table visuals directly is out of scope. | P1 |
| Correct feedback | Signal proof is visible but competes with multiple small stacked elements. | Stronger learning proof. | Make result label, missed/seen signal, and why line read as a single proof stack. | Over-ceremony could slow flow. | P1 |
| Wrong feedback | Emotionally light and useful; density still makes the lower card work hard. | Lower error shame; clearer repair action. | Use a clearer wrong-state hierarchy: status -> missed clue -> better option -> next repair. | Heavy red/error styling would hurt trust. | P1 |
| Repair focus | Strong proof value, but visually one more block inside an already dense feedback card. | Stronger repair causality. | Promote Repair focus as the dominant secondary block after missed clue; give it clearer separation from generic feedback. | Too much emphasis could feel like a dashboard/error log. | P1 |
| Repair result | Important proof is visible but shares space with session repair in the same compact stack. | Stronger progress proof. | Distinguish outcome receipt from next-session summary through hierarchy, not extra surface area. | Fake mastery language or trophy styling would overpromise. | P1 |
| Session repair | Visible but visually close to Repair result. | Session closure and return trust. | Treat as a compact closure strip: what changed, what remains, next focus. | Too much ceremony becomes progress theatre. | P2 |
| Review | Reads as repair coach, but the card could feel more premium and less utilitarian. | Stronger review value. | Keep one repair-coach card as primary; improve proof hierarchy and CTA separation. | Dashboard/table temptation. | P2 |
| Profile / You | Shows proof, but progress hierarchy under-sells the real repair/growth story. | Stronger progress proof and return motivation. | Elevate current focus / recent proof above generic stats; metrics remain secondary. | Over-building Profile into analytics. | P2 |
| Cross-surface transitions | Flow is coherent, but screens do not yet share an authored first-week rhythm. | First-week trust and premium feel. | Standardize proof beats: orientation, table action, feedback, repair, reflection. | Over-standardization can make surfaces feel samey. | P1 |

## 6. Cross-surface visual rhythm spec

### Placement -> Welcome

Placement should feel like a short route check. Welcome should feel like the
first usable product moment, not another explanation page. The transition
should visually move from "find your start" to "try one real table read."

Spec rule:

- Placement owns route confidence.
- Welcome owns first proof.
- Do not add extra diagnostic/report styling between them.

### Welcome -> Home/W1

Welcome handoff should preserve the micro-win feeling and make the next W1
step obvious. The final Welcome beat should not compete with Home as the
top-level owner.

Spec rule:

- Welcome says "you did the loop once."
- Home says "do this next."
- Home remains the next-action owner.

### Runner -> Feedback

The table decision should hand off cleanly into a feedback card that explains
the same visual signal. The learner should be able to connect the table state
to the feedback without hunting.

Spec rule:

- Runner table remains the evidence.
- Feedback card names the exact table clue and action.
- The feedback card should not introduce unrelated progress theatre.

### Feedback -> Repair

Wrong feedback should feel like a calm repair invitation, not a failure report.
Repair focus should be visually connected to the missed clue.

Spec rule:

- Wrong state: missed clue first.
- Repair focus: why this next hand was selected.
- CTA: continue into the repair path, not a generic course action.

### Repair -> Review/Profile

Repair result/session repair should prove progress, then Review/Profile should
mirror it without turning into analytics.

Spec rule:

- Repair result says what happened now.
- Session repair says what carries forward.
- Review says what to fix next.
- Profile says what is improving.

## 7. CTA/button hierarchy spec

The first-week route should have exactly one dominant action per surface.

Rules:

- Primary filled CTA belongs to the current surface job.
- Secondary pills/chips can explain state but should not visually compete with
  the CTA.
- Runner `Continue` is acceptable only when adjacent to a concrete feedback or
  instruction.
- Repair CTA should use repair language when the state is repair-owned.
- Home owns cross-surface next action; Welcome, Feedback, Review, and Profile
  should not pretend to be global planners.
- Because the fast renderer can show white bars for some button labels, final
  CTA-copy acceptance needs either native/real-render proof or a narrow
  renderer fix if review requires screenshots of button text.

## 8. Feedback / repair card hierarchy spec

Target order inside feedback and repair states:

1. outcome state: correct / missed / replay / repaired;
2. table signal: the clue the learner saw or missed;
3. action contrast: chosen vs better action when useful;
4. reason: why the action follows from the signal;
5. repair focus/result/session proof;
6. next action.

Visual direction:

- use tone and spacing to separate status, clue, and repair proof;
- keep repair proof compact but visibly more important than metadata chips;
- avoid shame-heavy red, dashboard blocks, charts, XP, or fake mastery.

## 9. Profile proof hierarchy spec

Profile should feel like a growth mirror, not a stat dashboard.

Target order:

1. current focus / next useful return;
2. recent real proof: repaired clue, clean rep, stable habit;
3. small progress context: level, streak-lite, completion count;
4. optional replay/setup controls.

Visual direction:

- elevate the "what I am improving" card above generic metrics;
- keep XP/streak/stat cards secondary and quiet;
- avoid permanent mastery claims;
- avoid adding charts, rankings, leak dashboards, or economy mechanics.

## 10. Review repair proof hierarchy spec

Review should continue to feel like a repair coach, not a correction log.

Target order:

1. what to fix next;
2. repeated pattern / missed signal if present;
3. why this repair matters now;
4. repair CTA;
5. recovered proof secondary.

Visual direction:

- one primary repair card;
- pattern card as coaching context, not analytics;
- recovered mistakes remain proof/growth, not a second primary action;
- no session proof ceremony leakage into Review.

## 11. Evidence-adjacent Sharky usage rules

Use Sharky where the character does learning work:

- Welcome route explanation and first-use reassurance;
- runner prompt if the line focuses the current table read;
- correct/wrong feedback when tied to the visible signal;
- repair focus/result/session closure;
- optional Home return reason if it explains the next useful action.

Do not use Sharky for:

- decorative identity coverage;
- extra Profile mascot layer over progress proof;
- generic reassurance that repeats a route card;
- Review repair-card wrapping if the repair copy already does the coaching;
- chat, AI, persona, or animated companion expansion.

## 12. Strict not-now list

- no broad visual redesign implementation;
- no product code, UI, copy, tests, routes, telemetry, or assets;
- no Modern Table visual change;
- no new screenshot/capture tooling;
- no completed-placement capture unless separately requested;
- no dynamic Profile repair-return capture unless separately requested;
- no Sharky Character implementation;
- no premium/paywall/trial/commercial CTA work;
- no AI/chat/ML behavior;
- no dashboard/charts/XP/economy work;
- no broad copy rewrite;
- no cosmetic-only micro-polish.

## 13. Ranked implementation slices

### Slice 1: Feedback / Repair Card Hierarchy Pass v1

Product EV:

- stronger learning proof;
- lower error shame;
- clearer repair causality;
- better first-week trust.

Scope:

- wrong feedback;
- Repair focus;
- Repair result;
- Session repair;
- shared card hierarchy inside the existing feedback seam.

Why first:

- the accepted packet shows this is the highest-value proof moment;
- it improves the core Sharky promise directly;
- it can be bounded without changing routes, table visuals, Profile, or
  monetization.

### Slice 2: First-Week Visual Rhythm Pass v1

Product EV:

- faster first understanding;
- smoother premium first-week feel;
- stronger cross-surface trust.

Scope:

- Placement intro treatment;
- Welcome beat rhythm;
- Welcome -> W1 handoff;
- Runner -> feedback transition spacing;
- no table visual changes.

Why second:

- it is more cross-surface and therefore riskier than the feedback/repair
  hierarchy pass.

### Slice 3: Profile / Review Proof Hierarchy Pass v1

Product EV:

- stronger progress proof;
- clearer return motivation;
- better Review/Profile role separation.

Scope:

- Review repair card hierarchy;
- Profile current-focus / recent-proof hierarchy;
- recovered proof and metrics stay secondary.

Why third:

- it strengthens retention proof after the core feedback/repair proof is more
  visually legible.

## 14. Recommended next implementation wave

Recommended next implementation wave:

`Feedback / Repair Card Hierarchy Pass v1 — Local Only`

This is the smallest high-EV visual implementation slice because it improves
the exact moment where Sharky proves learning value:

`mistake -> missed signal -> repair focus -> repair result -> session repair`

It should not touch Modern Table visuals, routes, copy strategy, Profile, or
monetization. It should make the existing feedback and repair proof hierarchy
clearer, calmer, and more premium in compact portrait.

## 15. Exact recommended next prompt title

`Feedback / Repair Card Hierarchy Pass v1 — Local Only`
