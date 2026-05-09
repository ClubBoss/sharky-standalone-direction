import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../plugins/LocalEvPlugin.dart';
import '../core/error_logger.dart';
import '../services/service_registry.dart';
import 'converter_discovery_plugin.dart';
import 'converter_plugin.dart';
import 'gg_poker_converter_plugin.dart';
import 'plugin.dart';
import 'plugin_manager.dart';
import 'poker_stars_converter_plugin.dart';
import 'sample_logging_plugin.dart';
import 'converters/888poker_hand_history_converter.dart';
import 'converters/ggpoker_hand_history_converter.dart';
import 'converters/ipoker_hand_history_converter.dart';
import 'converters/partypoker_hand_history_converter.dart';
import 'converters/poker_analyzer_json_converter.dart';
import 'converters/pokerstars_hand_history_converter.dart';
import 'converters/simple_hand_history_converter.dart';
import 'converters/winamax_hand_history_converter.dart';
import 'converters/wpn_hand_history_converter.dart';
import 'ipoker_converter_plugin.dart';
import 'partypoker_converter_plugin.dart';

/// Minimal web plugin loader used in non-web builds.
///
/// The original implementation relied on `dart:html` and `dart:indexed_db`,
/// which are not available in Flutter desktop/mobile environments.  This stub
/// keeps the public surface intact so the rest of the app can compile while
/// marking the missing behaviour for future work.
class PluginLoader {
  static const String _suffix = 'Plugin.dart';

  PluginLoader();

  Map<String, bool>? _config;

  /// Returns the cached configuration or an empty map.
  Future<Map<String, bool>> loadConfig() async {
    _config ??= <String, bool>{};
    return _config!;
  }

  /// Returns the built-in plugins bundled with the application.
  List<Plugin> loadBuiltInPlugins() {
    final converters = <ConverterPlugin>[
      PokerAnalyzerJsonConverter(),
      SimpleHandHistoryConverter(),
      PokerStarsHandHistoryConverter(),
      GGPokerHandHistoryConverter(),
      WinamaxHandHistoryConverter(),
      PartypokerHandHistoryConverter(),
      WpnHandHistoryConverter(),
      Poker888HandHistoryConverter(),
      IpokerHandHistoryConverter(),
    ];
    return <Plugin>[
      SampleLoggingPlugin(),
      ConverterDiscoveryPlugin(converters),
      LocalEvPlugin(),
    ];
  }

  Plugin? _createByName(String name) {
    switch (name) {
      case 'SampleLoggingPlugin':
        return SampleLoggingPlugin();
      case 'ConverterDiscoveryPlugin':
        return ConverterDiscoveryPlugin(<ConverterPlugin>[
          PokerAnalyzerJsonConverter(),
          SimpleHandHistoryConverter(),
          PokerStarsHandHistoryConverter(),
          GGPokerHandHistoryConverter(),
          WinamaxHandHistoryConverter(),
          PartypokerHandHistoryConverter(),
          WpnHandHistoryConverter(),
          Poker888HandHistoryConverter(),
          IpokerHandHistoryConverter(),
        ]);
      case 'PokerStarsConverterPlugin':
        return PokerStarsConverterPlugin();
      case 'GGPokerConverterPlugin':
        return GGPokerConverterPlugin();
      case 'PartyPokerConverterPlugin':
        return PartyPokerConverterPlugin();
      case 'IpokerConverterPlugin':
        return IpokerConverterPlugin();
      case 'LocalEvPlugin':
        return LocalEvPlugin();
    }
    return null;
  }

  /// Attempts to load an external plugin file.
  ///
  /// Web plugin loading is currently unsupported in this stub and will log the
  /// status as skipped.
  Future<Plugin?> loadFromFile(String name, PluginManager manager) async {
    if (!name.endsWith(_suffix)) return null;
    await manager.logStatus(name, 'unsupported');
    ErrorLogger.instance.logError(
      'Plugin loading unavailable on this platform',
    );
    return null;
  }

  /// Downloads a plugin from [url].
  ///
  /// Returns `false` because the functionality is not implemented.
  Future<bool> downloadFromUrl(String url, {String? checksum}) async {
    // TODO(web plugin loader): implement web plugin downloading for Flutter web.
    return false;
  }

  /// Deletes a previously downloaded plugin.
  Future<void> delete(String name) async {
    // TODO(web plugin loader): persist downloaded plugins.
    _config?.remove(name);
  }

  /// Loads built-in and (if available) external plugins.
  Future<void> loadAll(
    ServiceRegistry registry,
    PluginManager manager, {
    void Function(double progress)? onProgress,
    BuildContext? context,
  }) async {
    final builtIn = loadBuiltInPlugins();
    if (builtIn.isEmpty) return;

    final pluginNames = <String>[];
    final loadedPlugins = <Plugin>[];
    for (final plugin in builtIn) {
      final name = plugin.runtimeType.toString();
      pluginNames.add(name);
      loadedPlugins.add(plugin);
    }

    final total = loadedPlugins.length;
    var completed = 0;
    for (final plugin in loadedPlugins) {
      manager.load(plugin);
      completed++;
      onProgress?.call(completed / total);
    }

    await manager.logStatus('builtIn', 'loaded:${pluginNames.join(',')}');
    manager.initializeAll(registry);
  }
}
