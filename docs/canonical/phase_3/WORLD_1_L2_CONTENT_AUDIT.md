# World 1 L2 Content Audit (Game Types + Game Flow)

## 1) Module identification
- L2 module per WORLD_1_CAMPAIGN_SSOT.md:
  - intro_game_types
    - path: content/intro_game_types/v1
- Note: intro_game_flow is deferred post-launch per updated SSOT.

Files present:
- intro_game_types: manifest.json, drills.jsonl, quiz.jsonl, theory.md
- intro_game_flow: manifest.json, drills.jsonl, quiz.jsonl, theory.md

## 2) Current counts
- intro_game_types
  - drills.jsonl: 1
  - quiz.jsonl: 4
- intro_game_flow
  - drills.jsonl: 3
  - quiz.jsonl: 2

## 3) Target vs gap (L2)
Target for L2 (combined, per SSOT): 8–10 drills, 3–4 quiz items.
- Current total drills: 4 (1 + 3)
- Current total quiz: 6 (4 + 2)

Delta needed:
- Drills: +4 to +6
- Quiz: -2 to -3 (already above target; no additions needed)

## 4) Minimal enrichment plan (max 2 files)
- Files to edit next:
  - content/intro_game_types/v1/drills.jsonl
  - content/intro_game_flow/v1/drills.jsonl
- Append 4–6 drills total across those two files to reach 8–10 drills combined.
- Constraints: neutral, deterministic, schema-conformant, ASCII-only, decision-first.

## 5) Validator note
- Step 11 will run: dart run tools/validate_training_content.dart --ci
