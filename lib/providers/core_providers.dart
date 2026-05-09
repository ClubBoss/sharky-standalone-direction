import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../services/auth_service.dart';
import '../services/remote_config_service.dart';
import '../services/ab_test_engine.dart';
import '../services/theme_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/app_info_service.dart';
import '../services/content_module_loader_service.dart';
import '../services/module_progress_service.dart';
import '../services/xp_service.dart';
import '../services/app_language_controller.dart';
import '../payments/payment_service.dart';
import '../widgets/player_zone_widget.dart';
import 'provider_globals.dart';
import '../utils/loadable_extension.dart';

final AppLanguageController _appLanguageController = AppLanguageController();

/// Core application providers such as authentication and configuration.
List<SingleChildWidget> buildCoreProviders(CloudSyncService cloud) {
  _appLanguageController.initialize();
  // Create progress service first
  final progressService = ModuleProgressService()..initialize();
  // Create XP service
  final xpService = XpService()..initialize();

  // Create content loader and set progress service
  final contentLoader = ContentModuleLoaderService()..initialize();
  contentLoader.setProgressService(progressService);

  return [
    ChangeNotifierProvider<AuthService>.value(value: auth),
    ChangeNotifierProvider<RemoteConfigService>.value(value: rc),
    ChangeNotifierProvider<AbTestEngine>.value(value: ab),
    ChangeNotifierProvider(create: (_) => ThemeService()..init()),
    // Stage D16: Add language controller provider
    ChangeNotifierProvider<AppLanguageController>.value(
      value: _appLanguageController,
    ),
    ChangeNotifierProvider<PaymentService>.value(
      value: PaymentService.instance,
    ),
    Provider<CloudSyncService>.value(value: cloud),
    Provider(create: (_) => PlayerZoneRegistry()),
    Provider(create: (_) => AppInfoService()),
    Provider<ModuleProgressService>.value(value: progressService),
    Provider<XpService>.value(value: xpService),
    Provider<ContentModuleLoaderService>.value(value: contentLoader),
  ];
}
