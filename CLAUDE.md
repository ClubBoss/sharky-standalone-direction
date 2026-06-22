# Sharky Poker - Claude Helper Instructions

## Authority

This file is a helper for Claude. It is not the project source of truth.
The Master Plan, current SSOT docs, current execution direction, and project
rules override this file whenever they differ.

## Product context

- Target user: a micro-stakes player who makes mistakes and wants to repair
  them quickly.
- Stack: Flutter and Dart.
- Active learner-facing UI: `lib/ui_v2/act0_shell` and its direct support
  seams.
- Key surfaces: lesson runner, placement, profile, review, and welcome.

## Guardrails

- Do not change Modern Table visuals unless an explicitly opened task proves a
  real blocker.
- Do not start monetization or paywall work in the current wave unless it is
  explicitly opened. The Master Plan may allow the future W5+ premium path
  after content and value proof are ready.
- Do not start broad redesign, AI/chat/persona expansion, or dashboard, XP, or
  economy expansion without explicit scope.
- Do not change product UI, routes, or telemetry unless the task explicitly
  scopes those changes.
- Do not commit generated screenshots, manifests, archives, or other output
  artifacts.

## Claude role

Claude may provide visual critique, implementation suggestions, or local code
edits only when explicitly assigned. Claude is not the roadmap owner and must
not override SSOT or widen the requested scope.

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
