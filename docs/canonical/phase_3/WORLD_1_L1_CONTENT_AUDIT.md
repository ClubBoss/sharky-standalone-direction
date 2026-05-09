# World 1 L1 Content Audit (Intro Welcome)

## A) L1 module identification
- Module id: intro_welcome
- Content path: content/intro_welcome/v1
- Source of truth: `lib/content/release_content_plan.dart`

## B) Current inventory (counts)
- manifest.json: present
- theory.md: present
- drills.jsonl: 3 items
- quiz.jsonl: 2 items

Schema check (per `CONTENT_SCHEMAS.md`):
- drills.jsonl fields: id, kind, hero_action, villain_action, explanation, tags
  - Missing required fields: none
  - Legacy fields present: none
- quiz.jsonl fields: id, type, prompt, options (mc only), answer, explanation
  - Missing required fields: none
  - Legacy fields present: none

## C) Gap vs targets
- Target drills: 5–8; current: 3
- Target quiz: 2–3; current: 2
- Verdict: NEEDS ENRICHMENT (drills short by 2–5)

## D) Minimal Diff Plan (doc-only)
- Next step should edit:
  - content/intro_welcome/v1/drills.jsonl
- Add 2–5 new drills to reach 5–8 total.
- No new pedagogy: items must be short, deterministic, neutral, decision-first.
- No new modules, no new screens, no telemetry changes.

## E) Validation command (next step)
- `dart run tools/validate_training_content.dart --ci`
