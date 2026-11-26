# B108 · E35 external entries — cold/warm state contract

Scope: `a85177b9` (`origin/main` at package start), production Act0 route and direct seams. Cold means empty learner preferences; warm means an active answer or placement. The widget guard mounts `AppRoot` (not a debug-injected learner model) and uses the real channel, lifecycle, navigation and Review UI boundaries. Flutter execution is pending CI.

| Entry / disposition | Handler file(s) | State it must respect / guard |
|---|---|---|
| iOS `sharky://open/v1/learn` and Home fallback (including unknown sharky destinations) | `ios/Runner/Info.plist`, `ios/Runner/AppDelegate.swift` (`application` launch URL, `open url`, pending URL/`takeLink`); `act0_growth_v1.dart`, `act0_growth_links_v1.dart`, `act0_shell_preview_growth_v1.dart` | Cold: bootstrap/first-start before navigation. Warm: active answer and stored learner truth unchanged; defer until explicit runner exit. Placement must keep its gate; apply queued Learn after placement exit. Both destinations tested; Home uses the parser's fallback path. |
| Ordinary launch / foreground return (also what a practice-reminder tap can currently do) | `lib/main.dart`, `lib/ui_v2/app_root.dart` (`_EntryGate`); `act0_shell_preview_screen_v1.dart` (`_reviewLifecycleV1.onHide/onResume`); `act0_practice_reminder_v1.dart`, `ios/Runner/AppDelegate.swift` | Cold: no bypass of first start. Warm: actual lifecycle hide/pause/resume preserves the selected answer, lesson, evidence/XP and durable resume task. Reminder native code schedules notifications, retrieves permission/time and cancels; there is **no inbound notification-tap destination callback** on this baseline. Tests exercise ordinary launch/lifecycle, not an invented native event. |
| Learner-initiated hand-history paste (B67 area) | `act0_attempt_archive_screen_v1.dart` (`_import`); `act0_attempt_archive_v1.dart` (`importPokerStars`); `act0_review_shell_v1.dart`, `academy_leaves/act0_academy_review_leaf_v1.dart`, `act0_academy_runtime_adapter_v1.dart`, `act0_shell_preview_screen_v1.dart` (`onOpenOwnHands`, `onOwnHandsChanged`) | Cold: no Own hands/import/replay before the first-start gate. Warm: no import while the answer is active; explicit exit to Review allows paste and replay, but must preserve existing learner attempts, completion/evidence/XP and saved lesson. Current main exposes PokerStars text only; no external file picker, clipboard listener, or GGPoker route. Manual entry/removal are internal learner actions sharing the same archive callback, not separate external entry mechanisms. |
| Flutter platform named route (`/home`, `/home_screen`, `/modules`, `/modules_screen`, `/training_home`, `/training`, `/ui_v2/progress_map`) | `lib/ui_v2/app_root.dart` (`onGenerateRoute`, `buildLegacySurfaceRedirectRoute`); `act0_canonical_path_root_v1.dart` | Cold: only one gated learner shell. Warm: no route stacked over the active runner or second owner of progress. **Known defect; both `/home` cases skipped** (shared handler for all listed aliases). |
| `DEEPLINK_TARGET` compile-time capture/legacy target | `lib/ui_v2/app_root.dart` (`_maybeHandleDeepLink`), `lib/navigation/deep_link_target_v1.dart` | Inert: handler explicitly ignores the target; not a runtime delivery mechanism. |
| Debug proof entry (`Uri.base` query, `SHARKY_CAPTURE_SURFACE`, visual audit channel) | `lib/ui_v2/app_root.dart`, `ios/Runner/AppDelegate.swift` | Debug-only injection, not a learner entry. `kReleaseMode` blocks use of the query/capture payload and proof locale; visual channel additionally requires the build flag. No cold/warm learner-state assertion for intentionally injected proof states. |
| Settings lifecycle refresh and attempt replay lifecycle pause | `act0_academy_runtime_adapter_v1.dart`, `act0_attempt_replay_screen_v1.dart` | Existing mounted screens only: refresh reminder permission/pause playback, no entry navigation. Ordinary shell resume guard above covers learner state. |
| Share result / StoreKit / Android launcher and other host runners | `act0_growth_v1.dart`, `ios/Runner/AppDelegate.swift`, `android/app/src/main/AndroidManifest.xml`, desktop/web runner files, `pubspec.yaml` | Outbound share and StoreKit only; shared incoming Sharky URL goes through the growth bridge. No receive-share intent, Android VIEW/SEND registration, associated-domain or desktop-specific learner entry was found. The Android MAIN/LAUNCHER and desktop launcher use ordinary AppRoot. The `file_picker` dependency has no Act0 consumer. |

Act0 file paths above are relative to `lib/ui_v2/act0_shell/` unless fully qualified.

## Defect and execution limits

- **Legacy named-route cold/warm:** `AppRoot.onGenerateRoute` returns a `MaterialPageRoute` building `buildCanonicalPathRootV1()` instead of reusing the `_EntryGate` shell. That function unconditionally makes a fresh `Act0ShellPreviewScreenV1(showPlacementOnStart: true)`. Flutter's initial named-route stack can instantiate both `/` and `/home`; a warm platform push stacks another shell above the active one. This violates the single state owner contract even if both shells eventually read the same preferences. Two actionable regression bodies are marked `skip: true` with the source-based reason in their test names; no product fix. Not a runtime-reproduced result.
- No notification-tap Dart handler or inbound share handler exists: do not claim native delivery coverage. Native bridge dispatch is inspected; the widget tests inject at the real Flutter boundary, not through UIKit.
- The ratchet scans Act0, AppRoot/main, first-hop project imports/exports, platform runner source/config and pubspec for known ingress registrations, callbacks, platform declarations and import seams. It compares an exact sorted multiset of candidate lines (including duplicates and outbound/inert candidates), so a new registration even in an inventoried file fails. Synthetic detector controls cover a duplicate registration, new link stream, native message and SEND intent. It does not prove arbitrary novel custom API names or transitively hidden implementations; extending the detector and reviewing cold/warm behavior is required for a new ingress shape. This is an inventory ratchet, not a general semantic linter.

## Machine-readable reviewed ingress signatures

Do not update this census just to make CI green: classify a new/changed candidate in the table and add the relevant cold/warm checks first. Duplicate lines are intentional (multiple registrations).

<!-- ingress-signatures:start -->
```text
android/app/src/main/AndroidManifest.xml | <action android:name="android.intent.action.MAIN"/>
android/app/src/main/AndroidManifest.xml | <intent-filter>
ios/Runner/AppDelegate.swift | case "getTime":
ios/Runner/AppDelegate.swift | case "permissionDenied":
ios/Runner/AppDelegate.swift | case "requestReview":
ios/Runner/AppDelegate.swift | case "setEnabled":
ios/Runner/AppDelegate.swift | case "setTime":
ios/Runner/AppDelegate.swift | case "sync":
ios/Runner/AppDelegate.swift | case "takeLink":
ios/Runner/AppDelegate.swift | channel.setMethodCallHandler { [weak self] call, result in
ios/Runner/AppDelegate.swift | channel.setMethodCallHandler { [weak self] call, result in
ios/Runner/AppDelegate.swift | didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
ios/Runner/AppDelegate.swift | didFinishLaunchingWithOptions: launchOptions
ios/Runner/AppDelegate.swift | growthChannel?.invokeMethod("openLink", arguments: url.absoluteString)
ios/Runner/AppDelegate.swift | guard call.method == "visualAuditPayload" else {
ios/Runner/AppDelegate.swift | if let url = launchOptions?[.url] as? URL, url.scheme == "sharky" {
ios/Runner/AppDelegate.swift | let channel = FlutterMethodChannel(
ios/Runner/AppDelegate.swift | let channel = FlutterMethodChannel(
ios/Runner/AppDelegate.swift | let visualAuditChannel = FlutterMethodChannel(
ios/Runner/AppDelegate.swift | name: "com.clubboss.sharky/growth_v1",
ios/Runner/AppDelegate.swift | name: "com.clubboss.sharky/practice_reminder_v1",
ios/Runner/AppDelegate.swift | name: "com.clubboss.sharky/visual_audit_v1",
ios/Runner/AppDelegate.swift | open url: URL,
ios/Runner/AppDelegate.swift | private var growthChannel: FlutterMethodChannel?
ios/Runner/AppDelegate.swift | visualAuditChannel.setMethodCallHandler { call, result in
ios/Runner/Info.plist | <key>CFBundleURLName</key>
ios/Runner/Info.plist | <key>CFBundleURLSchemes</key>
ios/Runner/Info.plist | <key>CFBundleURLTypes</key>
lib/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart | final VoidCallback? onOpenOwnHands;
lib/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart | if (input.onOpenOwnHands != null)
lib/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart | onTap: input.onOpenOwnHands,
lib/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart | this.onOpenOwnHands,
lib/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart | onOpenOwnHands: _guard(isCurrent, legacy.onOpenOwnHands),
lib/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart | void didChangeAppLifecycleState(AppLifecycleState state) {
lib/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart | with WidgetsBindingObserver {
lib/ui_v2/act0_shell/act0_attempt_archive_screen_v1.dart | final ValueChanged<Act0AttemptArchiveV1> onOwnHandsChanged;
lib/ui_v2/act0_shell/act0_attempt_archive_screen_v1.dart | final next = widget.archive.importPokerStars(source);
lib/ui_v2/act0_shell/act0_attempt_archive_screen_v1.dart | onPressed: _import,
lib/ui_v2/act0_shell/act0_attempt_archive_screen_v1.dart | required this.onOwnHandsChanged,
lib/ui_v2/act0_shell/act0_attempt_archive_screen_v1.dart | widget.onOwnHandsChanged(updated);
lib/ui_v2/act0_shell/act0_attempt_archive_screen_v1.dart | widget.onOwnHandsChanged(widget.archive.removeImportedHand(hand.sourceKey));
lib/ui_v2/act0_shell/act0_attempt_archive_screen_v1.dart | widget.onOwnHandsChanged(widget.archive.saveManualHand(hand));
lib/ui_v2/act0_shell/act0_attempt_archive_v1.dart | Act0AttemptArchiveV1 importPokerStars(String text) {
lib/ui_v2/act0_shell/act0_attempt_replay_screen_v1.dart | void didChangeAppLifecycleState(AppLifecycleState state) {
lib/ui_v2/act0_shell/act0_attempt_replay_screen_v1.dart | with WidgetsBindingObserver {
lib/ui_v2/act0_shell/act0_growth_v1.dart | const act0GrowthChannelV1 = MethodChannel('com.clubboss.sharky/growth_v1');
lib/ui_v2/act0_shell/act0_practice_reminder_v1.dart | static const _channel = MethodChannel(
lib/ui_v2/act0_shell/act0_review_shell_v1.dart | final VoidCallback? onOpenOwnHands;
lib/ui_v2/act0_shell/act0_review_shell_v1.dart | if (onOpenOwnHands != null)
lib/ui_v2/act0_shell/act0_review_shell_v1.dart | onTap: onOpenOwnHands,
lib/ui_v2/act0_shell/act0_review_shell_v1.dart | this.onOpenOwnHands,
lib/ui_v2/act0_shell/act0_shell_preview_growth_v1.dart | 'takeLink',
lib/ui_v2/act0_shell/act0_shell_preview_growth_v1.dart | act0GrowthChannelV1.setMethodCallHandler((call) async {
lib/ui_v2/act0_shell/act0_shell_preview_growth_v1.dart | if (call.method == 'openLink' && call.arguments is String) {
lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart | _reviewLifecycleV1 = AppLifecycleListener(
lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart | act0GrowthChannelV1.setMethodCallHandler(null);
lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart | late final AppLifecycleListener _reviewLifecycleV1;
lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart | onHide: () {
lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart | onOpenOwnHands: () {
lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart | onOwnHandsChanged: (archive) {
lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart | onResume: () {
lib/ui_v2/app_root.dart | : act0CommercialProofLocaleOverrideV1(Uri.base);
lib/ui_v2/app_root.dart | : parseAct0ControlledDemoHarnessEntryV1(Uri.base) ??
lib/ui_v2/app_root.dart | Future<void> _maybeHandleDeepLink() async {
lib/ui_v2/app_root.dart | await _safeStart('Deep link', _maybeHandleDeepLink);
lib/ui_v2/app_root.dart | const MethodChannel _sharkyVisualAuditChannel = MethodChannel(
lib/ui_v2/app_root.dart | const String _deepLinkTargetEnvKey = 'DEEPLINK_TARGET';
lib/ui_v2/app_root.dart | onGenerateRoute: buildLegacySurfaceRedirectRoute,
pubspec.yaml | file_picker: ^6.2.1
pubspec.yaml | share_plus: ^7.0.0
```
<!-- ingress-signatures:end -->
