import 'config/app_flags.dart';

class AppConfig {
  AppConfig._();
  static final instance = AppConfig._();
  bool archiveAutoClean = false;
  bool showSmartPathHints = true;
  bool devUnlockOverride = false;
  // Runtime toggle to enable the new experimental UI (v2).
  // Default is true (production default as of Stage 18A).
  bool useUiV2 = true;
  bool useUiV3 = kUseUiV3;
}

final appConfig = AppConfig.instance;
