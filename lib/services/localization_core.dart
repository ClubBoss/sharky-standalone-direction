import 'dart:convert';
import 'dart:io';

const String _i18nDir = 'assets/i18n';
const String _missingSummaryPath = 'release/_reports/i18n_missing_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _glossaryPath = 'release/_reports/localization_glossary.json';
const String kLocalizationFallbackPath =
    'release/_reports/i18n_fallback_strings.txt';

Future<void> main(List<String> args) async {
  final cli = LocalizationCoreCli();
  final ok = await cli.run();
  if (!ok) {
    exitCode = 2;
  }
}

class LocalizationCoreCli {
  Future<bool> run() async {
    final core = LocalizationCore.instance;
    await core.load();
    final missing = core.computeMissingKeys();
    final hasMissing = missing.values.any((set) => set.isNotEmpty);

    await _withReportsWritable(() async {
      await _writeSummary(core.languages, missing);
      await _emitTelemetry(core.languages, missing, hasMissing);
    });

    return !hasMissing;
  }

  Future<void> _writeSummary(
    List<String> languages,
    Map<String, Set<String>> missing,
  ) async {
    final buffer = StringBuffer()
      ..writeln('I18N MISSING SUMMARY')
      ..writeln('=====================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Languages loaded: ${languages.join(', ')}')
      ..writeln();

    final entries = missing.entries.where((entry) => entry.value.isNotEmpty);
    if (entries.isEmpty) {
      buffer.writeln('All languages contain the same keys.');
    } else {
      for (final entry in entries) {
        buffer.writeln('- Missing keys for ${entry.key}:');
        for (final key in entry.value) {
          buffer.writeln('  • $key');
        }
      }
    }

    await File(_missingSummaryPath).writeAsString(buffer.toString());
  }

  Future<void> _emitTelemetry(
    List<String> languages,
    Map<String, Set<String>> missing,
    bool hasMissing,
  ) async {
    final payload = <String, Object?>{
      'event': 'i18n_missing_detected',
      'timestamp': DateTime.now().toIso8601String(),
      'languages': languages,
      'missing': missing.map((lang, keys) => MapEntry(lang, keys.toList())),
      'verdict': hasMissing ? 'FAIL' : 'PASS',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class LocalizationCore {
  LocalizationCore._();

  factory LocalizationCore() => instance;

  static final LocalizationCore instance = LocalizationCore._();

  final Map<String, Map<String, String>> _translations = {};
  final Map<String, String> _glossary = <String, String>{};
  bool _loaded = false;

  List<String> get languages => _translations.keys.toList()..sort();

  Future<void> load() async {
    if (_loaded) return;
    await _loadAsync();
  }

  Future<void> _loadAsync() async {
    final dir = Directory(_i18nDir);
    if (!await dir.exists()) {
      throw StateError('Localization directory not found: $_i18nDir');
    }
    await for (final entity in dir.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      final lang = entity.uri.pathSegments.last.split('.').first;
      final parsed = await _readJsonFile(entity);
      _translations[lang] = parsed;
    }
    _loaded = true;
  }

  void _ensureLoadedSync() {
    if (_loaded) return;
    final dir = Directory(_i18nDir);
    if (!dir.existsSync()) {
      throw StateError('Localization directory not found: $_i18nDir');
    }
    for (final entity in dir.listSync()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      final lang = entity.uri.pathSegments.last.split('.').first;
      final parsed = _readJsonFileSync(entity);
      _translations[lang] = parsed;
    }
    _loaded = true;
  }

  Future<Map<String, String>> _readJsonFile(File file) async {
    final Map<String, dynamic> decoded =
        json.decode(await file.readAsString()) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry('$key', value?.toString() ?? ''),
    );
  }

  Map<String, String> _readJsonFileSync(File file) {
    final Map<String, dynamic> decoded =
        json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry('$key', value?.toString() ?? ''),
    );
  }

  String translate(String key, String lang, {String fallbackLang = 'en'}) {
    _ensureLoadedSync();
    final langMap = _translations[lang];
    if (langMap != null && langMap.containsKey(key)) {
      return langMap[key]!;
    }
    final fallback = _translations[fallbackLang];
    if (fallback != null && fallback.containsKey(key)) {
      return fallback[key]!;
    }
    return '[$key]';
  }

  bool hasKey(String langOrKey, [String? maybeKey]) {
    _ensureLoadedSync();
    if (maybeKey == null) {
      return _translations.values.any((map) => map.containsKey(langOrKey));
    }
    return _translations[langOrKey]?.containsKey(maybeKey) ?? false;
  }

  bool validateString(String value) =>
      value.codeUnits.every((code) => code <= 0x7F);

  Future<void> reportMissingKeys(Set<String> keys) async {
    if (keys.isEmpty) return;
    await _withReportsWritable(() async {
      final sink = File(_missingSummaryPath).openWrite(mode: FileMode.append);
      sink.writeln('MISSING KEYS @ ${DateTime.now().toIso8601String()}');
      for (final key in keys) {
        sink.writeln('- $key');
      }
      await sink.close();
    });
  }

  Map<String, String> translationsForLanguage(String lang) {
    _ensureLoadedSync();
    return Map<String, String>.from(_translations[lang] ?? const {});
  }

  Map<String, String> glossaryEntries() => Map<String, String>.from(_glossary);

  Future<void> loadGlossary() async {
    final file = File(_glossaryPath);
    if (!await file.exists()) {
      _glossary.clear();
      return;
    }
    final Map<String, dynamic> decoded =
        json.decode(await file.readAsString()) as Map<String, dynamic>;
    _glossary
      ..clear()
      ..addEntries(
        decoded.entries.map(
          (entry) => MapEntry(entry.key, entry.value?.toString() ?? ''),
        ),
      );
  }

  Future<void> saveGlossary(Map<String, String> entries) async {
    final file = File(_glossaryPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(entries));
    _glossary
      ..clear()
      ..addAll(entries);
  }

  void addTranslation({
    required String source,
    required String languageCode,
    required String translation,
  }) {
    _ensureLoadedSync();
    final langMap = _translations.putIfAbsent(languageCode, () => {});
    langMap[source] = translation;
  }

  String postEdit(String text) => text.replaceAll('  ', ' ').trim();

  Map<String, Set<String>> computeMissingKeys() {
    _ensureLoadedSync();
    final union = <String>{};
    for (final entries in _translations.values) {
      union.addAll(entries.keys);
    }
    final missing = <String, Set<String>>{};
    for (final lang in _translations.keys) {
      final langKeys = _translations[lang]!.keys.toSet();
      final gaps = union.difference(langKeys);
      missing[lang] = gaps;
    }
    return missing;
  }
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}
