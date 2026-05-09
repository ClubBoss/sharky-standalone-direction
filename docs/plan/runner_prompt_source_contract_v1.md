# Runner Prompt Source Contract v1

Purpose:

- define the minimal shared source contract for prompt/details text resolution across compatible runners
- centralize precedence and fallback without redesigning host-local runner modes

## Shared Product Intent

- every compatible runner surface resolves:
  - one short top prompt for the active host chrome
  - one fuller reveal/details prompt for expanded or sheet-based disclosure
- both values should come from one canonical source rule rather than ad hoc per-screen fallback code

## Allowed Inputs

| Input | Meaning |
| --- | --- |
| `canonicalPrompt` | the authored default prompt for the active node or step |
| `shortPromptOverride` | optional host-local override when a runner mode intentionally shortens or rewrites the top prompt |
| `detailsPromptOverride` | optional host-local override when the details/full-condition reveal should show different text than the short prompt |

## Resolved Outputs

| Output | Meaning |
| --- | --- |
| `shortPrompt` | text used in the always-visible top prompt surface |
| `detailsPrompt` | text used in fuller reveal/details surfaces |

## Precedence Rules

1. `shortPrompt`
   - use `shortPromptOverride` when it is non-empty
   - otherwise use `canonicalPrompt`
2. `detailsPrompt`
   - use `detailsPromptOverride` when it is non-empty
   - otherwise fall back to resolved `shortPrompt`

## Explicitly Host-Local

- intro / caption / seat-quiz / hand-loop mode decisions
- whether a host chooses to show a modal sheet, inline details, or no reveal surface
- header visuals, badges, icons, compact/expanded layout, and modal shell styling

## Current Bounded Extraction

- shared seam:
  - precedence and fallback resolution only
- host-local callers:
  - World 1 computes mode-specific overrides, then delegates final prompt resolution
  - World 2 computes chain-step overrides, then delegates final prompt resolution

## Why This Seam Is Shared

- both hosts perform the same final product job: resolve a short prompt and a fuller reveal prompt from authored source plus optional host-local overrides
- centralizing that rule reduces drift without forcing broader runner-state unification
