# Sharky Academy — one iconography language (owner decision, 2026-10-25)

Owner rejects mixed icon packages/styles in selected Home B1 reference. One iconographic language is a GLOBAL DESIGN CONTRACT. It does not authorize changing protected Table/cast art, production Academy screens not yet owner admitted, or merging draft PRs.

## Required visual grammar

- All interactive UI glyphs (tab, CTA, learning, repeat, progress, feedback, utility) must look like ONE coherent simplified OUTLINED family. Consistent optical weight, stroke endings, silhouette complexity, geometry, sizes and baseline alignment. No emoji, colored pseudo-3D stickers, hollow+heavy filled mix or arbitrary unrelated arrow metaphors.
- Candidate vector art grid 24x24, apparent stroke approx 1.8-2pt, round or soft geometry, tab size 21-22pt, learning circle glyph 22pt, CTA arrow 19-20pt; hit area at least 44pt independent of drawing size. These represent TARGET OPTICAL RULES, not a claim that Flutter legacy Material icons are exactly equal in geometry.
- Selected/current state primarily color and parent-container glow/halo, not switching between unrelated art sets. Earned/done checkmark only if genuine source-owned learning completion. No decoration that falsely claims a past Recall or invented due Review.
- Sharky mascot and cinematic poker atmosphere art are NOT interactive glyphs; they can be dimensional, while UI stays crisp vectors. No live board cards, actions, graded states or learner data baked in.
- One rightward arrow for forward primary actions; disclosure chevron only for drill/details. Matching role across Home/Learn/Practice/Review/You/Settings/Decision/Feedback.
- Accessible named hit targets; 44pt taps, color not sole signal, icon semantics checked on real iPhone14Pro.

## Narrow code application and protection

In Draft PR #308 the initial semantic facade is the source file act0_academy_iconography_v1.dart. Flagged EN iPhone14Pro Home ONLY, SHARKY_HOME_NORTH_STAR_PREVIEW=true:
- Home = outlined house; Learn = outlined book; Practice = outlined focus/target; Review = outlined refresh; You = outlined person.
- Recall = outlined history; Learn cycle = same book as Learn tab; Apply = same target as Practice tab.
- Primary CTA uses one outlined rightward arrow; top utility = 3 neutral dots.
- Review's actual source-owned nav cue dot, if present, uses Home teal contrast instead of legacy gold with unrelated table palette.

The first pass using Flutter Material outlined icons was independently **FALSIFIED by the actual 14Pro image**: the book had more fill/weight than the house, target and refresh felt heavier than the remaining glyphs. Replaced this with **EIGHT original Sharky SVG source assets** in assets/design/sharky/iconography/ using a shared 24x24 viewBox, 1.85 stroke, rounded caps and joins: home, book, focus, review, user, recall, forward, more. These paths were authored for Sharky rather than taken from another design reference. The reused source resource is literally identical for Learn tab & phase and Practice tab & Apply phase. All are recolored by the existing Academy semantic palette; none embeds a learner state, grade or live poker card.

**True icon acceptance still needs:** native screenshot of the exact eight-SVG commit, glyph sheet with optical weights/contrast, text alignment and focus/VoiceOver. UI tests and SVG XML invariants are supporting proof only. The current kit may still need one local refinement; do not claim 10/10 based on identical stroke metadata.

Legacy light Academy tabs and protected poker table are unchanged when preview is off. No whole-repo icon replacement is authorized. Exact glyph mapping is tested at 393x852 (preview ON and OFF) plus Dart analyzer; true icon beauty, safe area and AX need actual native iPhone14Pro visual/review before Home visual acceptance.

Related decisions: docs/design/S12V_NORTH_STAR_RESET_OWNER_EXPLORATION_20261025.md, docs/ops/S12V_VISUAL_RESET_PRECODE_GATE_20261025.md, and Issue #287.

## Home premium finish candidate (2026-10-25)

The opt-in Home uses the existing palette owner and SVG facade; no second theme.
24px stage / 22px navigation / 19px forward symbols share the original 1.85
stroke family. Selected phase uses a brighter ring plus its source-owned semantic
label; neutral stages never show earned checkmarks. Navigation retains its
selected underline and text. The CTA is 46pt tall; utility/nav targets retain
44pt minimum hit areas. Decorative imagery is excluded from accessibility.

The single decorative `assets/design/sharky/home/poker_lounge_v1.png` is generated
poker-lounge material with felt, leather, unmarked chips and distant light; it
contains no cards, UI, learner data or current game state. It sits behind native
text, glyphs and controls. Ink scrim protects the lower action/progress surfaces.
Header 18/12pt, introductory title 32pt, source recommendation 24pt, body 13pt;
18pt action radius, 13pt CTA radius, restrained one-phase halo; main spacing
28/22/12pt. Bright aqua indicates the actionable/selected role, never achievement.
The fixed introductory copy claims no identity, completion or elapsed activity.
All recommendation, CTA, phase, progress and streak values keep existing owners.

This is one Home-only owner-review candidate. Other Academy screens adopt these
roles only in later admitted waves. Exact native receipts and visual limitations
belong to the local evidence folder, not to an app-wide or Human PASS claim.
