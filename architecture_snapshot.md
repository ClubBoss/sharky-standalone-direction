## App root flow
- `lib/main.dart` wraps `runApp(AppRoot())` inside `runZonedGuarded`; Firebase init commented out.
- `AppRoot` (`lib/ui_v2/app_root.dart`) builds a `ChangeNotifierProvider` for `GameEconomy`, then a `MaterialApp` (dark theme, debug banner off) with `home: SagaMapScreen` and route `PreflopTrainerScreen.routeName`.
- AppRoot includes stubbed V4 helpers (`isV4Active`, `exportInlineExplanationBinderV4`, `provideV4HelpInfoIcon`, `provideV4ExplainSurface`) to satisfy references elsewhere.
- Navigation beyond the initial screen uses standard Navigator routes (no custom router observed in AppRoot); additional domain routers exist per-feature (persona/fusion/hints, see project_map.txt).

## State management in use
- Provider/ChangeNotifier: `ChangeNotifierProvider` with `GameEconomy` at the root; indicates Provider is the active state-management pattern in this entry build.
- No Riverpod/BLoC setup detected in `main.dart`/`AppRoot`; other patterns may exist deeper, but root wiring currently relies on Provider.

## Content contract (current implementation)
- Loader: `lib/services/content_module_loader_service.dart`.
- Index: expects `assets/theory_index.json` listing modules (id/title/category) -> deserialized into `ModuleMetadata`.
- Per-module assets loaded via `rootBundle` with fallbacks:
  - `assets/content/<moduleId>/theory.md` (fallback `.../v1/theory.md`).
  - `assets/content/<moduleId>/drills.jsonl` and `demos.jsonl` (JSON arrays).
  - Additional file lookups allow `assets/content/<moduleId>/<fileName>` or `.../v1/<legacyFileName>` via `_loadFirstAvailableAsset`.
- Output structure: `TrainingModule` with `id`, `title`, `category`, `theory` (markdown string), `drills` (list), `demos` (list), `isCompleted` flag via optional `ModuleProgressService`.
- Behavior on missing assets: falls back gracefully (warnings printed, returns empty index/cache); TODO stubs remain for singleton accessors and spot/title helpers.
