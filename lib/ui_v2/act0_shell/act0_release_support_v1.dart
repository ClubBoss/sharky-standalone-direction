import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Set to the owner-approved address in release builds.
const act0SupportEmailV1 = String.fromEnvironment('SHARKY_SUPPORT_EMAIL');

class Act0ReleaseSupportV1 {
  static int _frameworkErrors = 0;
  static int _uncaughtErrors = 0;

  static Future<String> version() async {
    if (kIsWeb) return 'Version and build unavailable';
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty && info.buildNumber.isNotEmpty) {
        return 'Version ${info.version} (build ${info.buildNumber})';
      }
    } catch (_) {
      // Metadata is unavailable on some hosts, including widget tests.
    }
    return 'Version and build unavailable';
  }

  /// Count failures during this run without retaining error messages, stack
  /// traces, or any learner data. Preserve the platform's error handling.
  static void observeErrors() {
    final frameworkHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      _frameworkErrors++;
      frameworkHandler?.call(details);
    };
    final dispatcher = PlatformDispatcher.instance;
    final platformHandler = dispatcher.onError;
    dispatcher.onError = (error, stack) {
      _uncaughtErrors++;
      return platformHandler?.call(error, stack) ?? false;
    };
  }

  static Future<String> diagnostics() async => [
    'Sharky Poker',
    await version(),
    'Platform: ${defaultTargetPlatform.name}',
    'Framework errors this session: $_frameworkErrors',
    'Uncaught errors this session: $_uncaughtErrors',
  ].join('\n');
}
