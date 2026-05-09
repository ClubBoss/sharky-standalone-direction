# Runner Reveal Intent Contract v1

Purpose:

- define the minimal shared contract behind opening fuller prompt/details content
- separate shared reveal intent from host-local shell and chrome behavior

## Shared Product Intent

- a compatible runner may expose a user request to reveal fuller prompt/details content for the active node
- the revealed content comes from the already-resolved fuller prompt/details source, not from host-local chrome text

## Allowed Inputs

| Input | Meaning |
| --- | --- |
| `detailsPrompt` | the already-resolved fuller prompt/details text from the prompt source seam |
| `sourceId` | optional stable identity for the active node or step when the host needs to scope the request |

## Shared Outputs / State

| Field | Meaning |
| --- | --- |
| `canReveal` | whether fuller prompt/details content exists and is meaningful to open |
| `revealedText` | the fuller prompt/details text that should be shown when reveal is requested |
| `sourceId` | optional active source identity carried with the reveal request |

## Precedence Rules

1. reveal intent may only use the resolved `detailsPrompt` from the prompt source contract
2. if `detailsPrompt` is empty, `canReveal` is false
3. reveal intent does not choose shell, placement, or visual treatment

## Explicitly Host-Local

- affordance placement
- whether reveal opens from a compact header tap, app-bar CTA, inline expand, or some other local trigger
- modal sheet vs inline expansion vs another shell
- header chrome, labels, icons, and compact/expanded layout
- additional local detail rows beyond the shared `revealedText`

## Why This Seam Is Shared

- both compatible hosts expose the same underlying product action:
  - request fuller prompt/details content for the active node
- the actual opening surface differs, but the intent behind the request is shared

## R278 Decision

- contract status:
  - defined
- extraction status:
  - STOP
- why:
  - the shared seam is real at the contract level, but extracting code now would only wrap already-trivial state while the real behavior differences still live in host-local reveal triggers and shells
  - centralizing more than the contract would broaden into runner-state or shell redesign
