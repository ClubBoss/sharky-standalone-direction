# Table Identity Semantic Metadata Seam v1

## 1. Chosen metadata owner

`Act0TeachingStepV1` owns the field. Identity relevance is a fact about what a
teaching beat is instructing the learner to notice, not an intrinsic poker-table
fact and not a route/widget decision.

## 2. Exact enum/field

`Act0TableIdentityTeachingSemanticsV1`:

- `legacy`
- `learnerOnly`
- `position`
- `dealerOrder`

`Act0TeachingStepV1.identityTeachingSemantics` defaults to `legacy`.

## 3. Why existing fields are insufficient

`focusSeatIds`, `focusCardIds`, `focusLabels`, `instructionAnchor`, and
`isDealerButton` identify table facts or free-form instruction support. None
states whether position or dealer order is the instructional fact. Deriving
that meaning from labels/copy, route IDs, world IDs, widget state, or table
layout is forbidden and would be unreliable.

## 4. Legacy/default behavior

Unannotated steps resolve to
`Act0TableIdentityPolicyV1.currentProduction`. This is an explicit compatibility
default: it changes no existing production identity/disc behavior until a step
is source-migrated.

## 5. Pilot annotations

The bounded first annotation is the existing `This is a poker table.` teaching
step in the pilot source sequence, marked `position`. No broad migration was
performed. Dealer-order and learner-only semantics are covered by typed mapping
tests but await source-owned step admission before annotation.

## 6. Resolver mapping

`act0TableIdentityPolicyForTeachingSemanticsV1` maps the teaching field to the
existing config policy:

- `legacy` -> `currentProduction`
- `learnerOnly` -> `learnerOnly`
- `position` -> `learnerPosition`
- `dealerOrder` -> `learnerPositionAndDealerOrder`

The resolver accepts no copy, localization, route, world, layout, or runner
private input.

## 7. Files changed

- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `lib/ui_v2/act0_shell/act0_table_presentation_config_v1.dart`
- `test/ui_v2/table_identity_semantic_metadata_seam_v1_test.dart`

## 8. Tests

Focused tests prove unannotated legacy behavior and all three teaching semantic
mappings. Analyzer passes for all touched files.

## 9. Regression risks

The field is deliberately inert until Phase A wires the resolved policy through
the scene/table/seat-marker path. The primary migration risk is incorrectly
annotating a source step; bounded annotation and the legacy default contain it.

## 10. Whether Phase A is now admitted

Yes. The source-owned semantic distinction now exists, has an explicit legacy
default, and maps into the existing presentation config without a parallel
identity contract. Phase A may wire that config through the table scene next.
