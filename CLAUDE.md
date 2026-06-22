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
