# M6 Visual Perfection Done v1

- Status: M6 v1 DONE (PR1 and PR2 complete), including map hygiene follow-up.

- What was unified:
  - Removed ad-hoc `Colors.white` text usage on core surfaces and replaced with `SharkyTokensV1` text tokens.
  - Unified map shell and map fallback/loading surfaces to `SharkyTokensV1` palette; removed `AppColors` dependence in map screen.
  - Tokenized runner chip and board-strip pill styling (radius and shadow palette) to align with map/intake token language.
  - Applied map placeholder hygiene: unavailable nodes are hidden from user path rendering, and internal slot IDs are not shown in map UI.

- Proof commands:
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test test/guards/world_campaign_map_home_contract_test.dart`
  - `./tools/fast_loop_world1_v1.sh`
  - Expected signature: `FAST LOOP PASS`

- Out of scope in M6 v1:
  - New dependencies.
  - Heavy visual effects (for example BackdropFilter stacks or layered opacity effects beyond existing patterns).
  - Redesign work not tied to concrete inconsistency fixes.
  - Content, tools, or schema changes.

- Deferred next (only if SSOT later requires):
  - Table realism polish pass (felt/rail realism refinements).
  - Additional chip marker visual refinements.
  - Optional micro visual cleanup items that are currently wishlist-only.
