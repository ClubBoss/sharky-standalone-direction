import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/navigation/deep_link_target_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/services/app_language_controller.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_canonical_path_root_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
export 'package:poker_analyzer/app/runtime_surface.dart' show appRoot;

const String _deepLinkTargetEnvKey = 'DEEPLINK_TARGET';
const String _deepLinkTargetRaw = String.fromEnvironment(
  _deepLinkTargetEnvKey,
  defaultValue: '',
);
final DeepLinkTargetV1? _deepLinkTarget = parseDeepLinkTargetV1(
  _deepLinkTargetRaw,
);
const bool _allowLegacySurfaces = false;
final ValueNotifier<int> _uiRenderRecoveryTick = ValueNotifier<int>(0);
const Set<String> _legacySurfaceRoutes = <String>{
  '/home',
  '/home_screen',
  '/modules',
  '/modules_screen',
  '/training_home',
  '/training',
  '/ui_v2/progress_map',
};

Route<dynamic>? buildLegacySurfaceRedirectRoute(RouteSettings settings) {
  if (!_allowLegacySurfaces && _legacySurfaceRoutes.contains(settings.name)) {
    debugPrint('Legacy route blocked: ${settings.name}; redirecting to map.');
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => buildCanonicalPathRootV1(),
    );
  }
  return null;
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<AppRoot> createState() => _AppRootState();

  // ---------------------------------------------------------------------------
  // 🚨 STUB API SURFACE (CRITICAL FOR COMPILATION)
  // These members are kept to satisfy static analysis in other parts of the
  // codebase that might reference AppRoot types.
  // DO NOT REMOVE until the Release/Fusion layers are fully restored.
  // ---------------------------------------------------------------------------
  bool get isV4Active => true;
  final Map<String, dynamic> exportInlineExplanationBinderV4 = const {};

  Widget provideV4HelpInfoIcon(String id) => const SizedBox();
  Widget provideV4ExplainSurface(String id) => const SizedBox();
}

class _AppRootState extends State<AppRoot> {
  late final AppLanguageController _languageController;

  @override
  void initState() {
    super.initState();
    _languageController = AppLanguageController()
      ..addListener(_onLocaleChanged);
    unawaited(_languageController.initialize());
  }

  void _onLocaleChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _languageController
      ..removeListener(_onLocaleChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguageController>.value(
      value: _languageController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _languageController.currentLocale,
        // Providing a basic dark theme to ensure text is visible on dark backgrounds
        // defined in AppColors. Complex theme logic will be restored later.
        theme: ThemeData.dark(
          useMaterial3: true,
        ).copyWith(splashFactory: InkRipple.splashFactory),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          if (child == null) {
            return const NonBlankFallbackSurfaceV1(
              title: 'Screen is unavailable',
              message: 'Please retry or go back.',
              retryLabel: null,
            );
          }
          return ValueListenableBuilder<int>(
            valueListenable: _uiRenderRecoveryTick,
            builder: (context, _, __) {
              final media = MediaQuery.of(context);
              final clamped = media.copyWith(
                textScaleFactor: media.textScaleFactor.clamp(1.0, 1.4),
              );
              return _ErrorWidgetBuilderScope(
                onRetry: () {
                  _uiRenderRecoveryTick.value = _uiRenderRecoveryTick.value + 1;
                },
                child: MediaQuery(data: clamped, child: child),
              );
            },
          );
        },
        navigatorKey: widget.navigatorKey,
        onGenerateRoute: buildLegacySurfaceRedirectRoute,
        home: _EntryGate(navigatorKey: widget.navigatorKey),
      ),
    );
  }
}

class _ErrorWidgetBuilderScope extends StatefulWidget {
  const _ErrorWidgetBuilderScope({required this.child, required this.onRetry});

  final Widget child;
  final VoidCallback onRetry;

  @override
  State<_ErrorWidgetBuilderScope> createState() =>
      _ErrorWidgetBuilderScopeState();
}

class _ErrorWidgetBuilderScopeState extends State<_ErrorWidgetBuilderScope> {
  late final ErrorWidgetBuilder _previousBuilder;

  @override
  void initState() {
    super.initState();
    _previousBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return _GlobalRenderFallbackPanel(
        details: details,
        onRetry: widget.onRetry,
      );
    };
  }

  @override
  void dispose() {
    ErrorWidget.builder = _previousBuilder;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _GlobalRenderFallbackPanel extends StatelessWidget {
  const _GlobalRenderFallbackPanel({
    required this.details,
    required this.onRetry,
  });

  final FlutterErrorDetails details;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0E1624),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF13233D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A537A)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Something went wrong',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kReleaseMode
                            ? 'Please retry. Your progress is safe.'
                            : 'Render fallback active.',
                        style: const TextStyle(
                          color: Color(0xFFCDD8EA),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!kReleaseMode) ...[
                        const SizedBox(height: 8),
                        Text(
                          details.exception.runtimeType.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF98B4DE),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onRetry,
                              child: const Text('Retry'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).maybePop();
                              },
                              child: const Text('Back'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NonBlankFallbackSurfaceV1 extends StatelessWidget {
  const NonBlankFallbackSurfaceV1({
    super.key,
    required this.title,
    required this.message,
    this.retryLabel = 'Retry',
    this.onRetry,
  });

  final String title;
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        key: const Key('non_blank_fallback_surface_v1'),
        color: const Color(0xFF0E1624),
        alignment: Alignment.center,
        child: SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF13233D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A537A)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFF98B4DE),
                        size: 22,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFFCDD8EA),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (onRetry != null && retryLabel != null) ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: onRetry,
                                child: Text(retryLabel!),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).maybePop();
                              },
                              child: const Text('Back'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryGate extends StatefulWidget {
  const _EntryGate({this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<_EntryGate> createState() => _EntryGateState();
}

class _EntryGateState extends State<_EntryGate> {
  // Entry Matrix (production parity reference):
  // 1) AppRoot (_EntryGate) -> Act0ShellPreviewScreenV1
  //    file: lib/ui_v2/app_root.dart (build, canonical detached dev branch)
  // 2) Legacy intake/map surfaces remain donor/archive truth only.
  // 3) Today Plan START/CONTINUE (today_plan_start_cta) -> World1FoundationsMicroTaskRunnerScreen
  //    file: lib/ui_v2/screens/universal_intake_plan_screen.dart
  // 4) Today Plan OPEN MAP (today_plan_open_map_cta) -> UiV2ProgressMapScreenV2
  //    file: lib/ui_v2/screens/universal_intake_plan_screen.dart
  // 5) Map NEXT PACK (world_campaign_next_pack_cta) -> World1FoundationsMicroTaskRunnerScreen
  //    file: lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart
  // 6) Map world node (world_campaign_open_N) -> world_detail_sheet_v1 ->
  //    world_detail_primary_cta_v1 -> World1FoundationsMicroTaskRunnerScreen
  //    file: lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart
  // 7) Store parity harness mirrors (4)+(6) via deterministic bounded pumps
  //    file: tools/modern_table_screenshot_v1.dart
  // NOTE: production map and today-plan primary CTAs are aligned to modern runner.
  bool _checked = false;
  bool _entryReady = false;
  bool _showPlacementOnStart = true;
  bool _deepLinkHandled = false;
  final Set<String> _entryErrorsLogged = <String>{};

  Future<void> _safeStart(String label, Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stack) {
      if (_entryErrorsLogged.add(label)) {
        debugPrint('$label entry failed: $error');
        debugPrint(stack.toString());
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checked) return;
    _checked = true;
    unawaited(_bootstrapEntrySurface());
  }

  Future<void> _bootstrapEntrySurface() async {
    const showPlacementOnStart = true;
    if (!mounted) return;
    setState(() {
      _showPlacementOnStart = showPlacementOnStart;
      _entryReady = true;
    });
    await _safeStart('Deep link', _maybeHandleDeepLink);
  }

  Future<void> _maybeHandleDeepLink() async {
    if (_deepLinkHandled || _deepLinkTarget == null) return;
    _deepLinkHandled = true;
    debugPrint(
      'Deep link target ignored during World1 campaign surface lock: $_deepLinkTargetRaw',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_entryReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Act0ShellPreviewScreenV1(
      showPlacementOnStart: _showPlacementOnStart,
    );
  }
}
