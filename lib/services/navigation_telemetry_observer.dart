import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/services/ui_telemetry_service.dart';

/// Navigator observer that records approximate push/pop transition durations.
class NavigationTelemetryObserver extends NavigatorObserver {
  final Map<Route<dynamic>, Stopwatch> _pushTimers = {};
  final Map<Route<dynamic>, Stopwatch> _popTimers = {};

  String _name(Route<dynamic>? r) {
    if (r == null) return 'unknown';
    final n = r.settings.name;
    if (n != null && n.isNotEmpty) return n;
    // Fallback to route runtime type if no name provided
    return r.runtimeType.toString();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final sw = Stopwatch()..start();
    _pushTimers[route] = sw;
    // Stop on next frame to approximate the transition
    scheduleMicrotask(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final s = _pushTimers.remove(route);
        if (s == null) return;
        s.stop();
        final ms = s.elapsed.inMilliseconds;
        UiTelemetryService.instance.recordNavigation(_name(route), ms);
      });
    });
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final sw = Stopwatch()..start();
    _popTimers[route] = sw;
    scheduleMicrotask(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final s = _popTimers.remove(route);
        if (s == null) return;
        s.stop();
        final ms = s.elapsed.inMilliseconds;
        UiTelemetryService.instance.recordNavigation(_name(previousRoute), ms);
      });
    });
  }
}
