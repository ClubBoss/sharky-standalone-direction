# Module Bundle Template v1

Use this template to create a new canonical module bundle under:

`content/<module_id>/v1/`

Create exactly these files:

## `theory.md`

```md
# <Module Title>

## Key Idea

2-4 short lines that state the core concept in beginner-safe language.

## Mini-Example

One short concrete spot with plain actions and outcome.

## Working Rules

- Rule 1 (factual, short, concrete).
- Rule 2 (factual, short, concrete).
- Rule 3 (factual, short, concrete).
- Rule 4 (factual, short, concrete).

## Quick Check

- One fast self-check question.
- One common mistake to avoid.
```

## `drills.jsonl`

Use unique IDs with the module prefix (`<module_id>_01`, `<module_id>_02`, ...).

```jsonl
{"id":"<module_id>_01","type":"mcq","prompt":"<Prompt 1>","options":["<A>","<B>","<C>"],"correct":"<A>","explanation":"<Why A is correct>","difficulty":1}
{"id":"<module_id>_02","type":"mcq","prompt":"<Prompt 2>","options":["<A>","<B>","<C>"],"correct":"<B>","explanation":"<Why B is correct>","difficulty":1}
{"id":"<module_id>_03","type":"mcq","prompt":"<Prompt 3>","options":["<A>","<B>","<C>"],"correct":"<C>","explanation":"<Why C is correct>","difficulty":2}
```

## `manifest.json`

```json
{
  "id": "<module_id>",
  "order": 0,
  "title": "<Module Title>",
  "description": "<One-line learner-facing description>",
  "tier": "A",
  "version": "v1",
  "difficulty_tier": 1,
  "error_class": "<module_id>",
  "reasoning": "<One-line statement of what this module teaches>",
  "availability": "available"
}
```

## Authoring constraints

- Keep paragraphs short and deterministic.
- Avoid unexplained jargon in beginner modules.
- Keep drills unambiguous with one correct answer.
- Do not add authored content under `assets/content/` or `lib/content/`.
