# CONTENT FILE SCHEMAS

## drills.jsonl / demos.jsonl
- One JSON object per line.
- Fields: id, kind, hero_action, villain_action, explanation, tags

## quiz.jsonl
- One JSON object per line.
- Fields:
  - id: string
  - type: 'mc' | 'tf'
  - prompt: string
  - options: array of strings (for mc only)
  - answer: index (mc) or bool (tf)
  - explanation: string

## recap.md
- Markdown summary of key concepts.

## labels.txt
- Single label for the module.

## paths.txt
- Optional remap/alias file.
