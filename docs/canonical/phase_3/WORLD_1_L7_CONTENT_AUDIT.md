# World 1 L7 Content Audit (Tier 1 Checkpoint)

## Module mapping
- L7 module id: tier_1_checkpoint
- Path: content/tier_1_checkpoint/v1

## Presence check
- manifest.json: present
- drills.jsonl: present
- quiz.jsonl: present
- theory.md: present

## Current counts
- drills: 6
- quiz: 5

## Gap to target (from WORLD_1_CAMPAIGN_SSOT.md)
- Target drills: 4–6
  - Current: 6 (within target)
- Target quiz: 1–2
  - Current: 5 (above target)

## Minimal enrichment plan
- No enrichment needed (already within/above target).
- If trimming is desired later, do not edit in this step.

## Validator plan
- After any future edits: dart run tools/validate_training_content.dart --ci
