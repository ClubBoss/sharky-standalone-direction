import 'dart:collection';
import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) {
  final options = _CommandOptions.parse(arguments);
  final runner = _LocalizationCore(Directory.current);

  if (!options.scanRequested && options.applyLanguage == null) {
    _printUsage();
    exitCode = 64; // EX_USAGE
    return;
  }

  if (options.scanRequested) {
    runner.runScan();
  }

  final lang = options.applyLanguage;
  if (lang != null) {
    runner.runApply(lang);
  }
}

void _printUsage() {
  stdout.writeln(
    'Usage: dart run tools/localization_core.dart [--scan] [--apply=<lang>]',
  );
  stdout.writeln(
    '  --scan         Extract English source strings and update translation memory.',
  );
  stdout.writeln(
    '  --apply=<lang> Generate localized copies using existing translations for <lang>.',
  );
}

class _CommandOptions {
  _CommandOptions({required this.scanRequested, required this.applyLanguage});

  final bool scanRequested;
  final String? applyLanguage;

  static _CommandOptions parse(List<String> args) {
    bool scan = false;
    String? apply;

    for (final arg in args) {
      if (arg == '--scan') {
        scan = true;
      } else if (arg.startsWith('--apply=')) {
        apply = arg.substring('--apply='.length).trim();
        if (apply.isEmpty) {
          apply = null;
        }
      } else if (arg == '--help' || arg == '-h') {
        _printUsage();
        exit(0);
      } else {
        stderr.writeln('Unrecognized option: $arg');
        _printUsage();
        exit(64);
      }
    }

    return _CommandOptions(scanRequested: scan, applyLanguage: apply);
  }
}

class _LocalizationCore {
  _LocalizationCore(this.root);

  final Directory root;

  static const _reportsDir = 'tools/_reports';
  static const _stringsIndexPath = '$_reportsDir/strings_en.json';
  static const _translationMemoryPath = '$_reportsDir/translation_memory.json';
  static const _localizedRoot = '$_reportsDir/localized';

  void runScan() {
    final contentRoot = Directory.fromUri(root.uri.resolve('content/'));
    if (!contentRoot.existsSync()) {
      stderr.writeln('No content/ directory found. Nothing to scan.');
      return;
    }

    final files = <File>[];
    for (final entity in contentRoot.listSync(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }
      final relPath = _relativePath(entity.path);
      if (!_matchesTargetPath(relPath)) {
        continue;
      }
      if (!_isSupportedSource(relPath)) {
        continue;
      }
      files.add(entity);
    }

    files.sort(
      (a, b) => _relativePath(a.path).compareTo(_relativePath(b.path)),
    );

    final aggregator = _ExtractionAggregator();
    for (final file in files) {
      final relPath = _relativePath(file.path);
      final segments = _extractSegments(file, relPath);
      if (segments.isNotEmpty) {
        aggregator.addFileSegments(relPath, segments);
      }
    }

    final translationMemory = _TranslationMemory.load(_translationMemoryPath);
    for (final segment in aggregator.allSegments) {
      translationMemory.ensureEntry(segment.hash, segment.source);
    }
    translationMemory.save(_translationMemoryPath);

    final index = _StringsIndex(files: aggregator.fileEntries);
    index.save(_stringsIndexPath);

    stdout.writeln(
      'Scan complete: ${aggregator.fileEntries.length} files, ${aggregator.allSegments.length} unique segments.',
    );
  }

  void runApply(String languageCode) {
    final index = _StringsIndex.load(_stringsIndexPath);
    final translationMemory = _TranslationMemory.load(_translationMemoryPath);
    if (index.files.isEmpty) {
      stdout.writeln('No strings to apply. Did you run with --scan?');
      return;
    }

    final outputRoot = Directory.fromUri(
      root.uri.resolve('$_localizedRoot/$languageCode/'),
    );
    if (!outputRoot.existsSync()) {
      outputRoot.createSync(recursive: true);
    }

    int updatedFiles = 0;
    for (final entry in index.files) {
      final sourceFile = File.fromUri(root.uri.resolve(entry.path));
      if (!sourceFile.existsSync()) {
        stderr.writeln('Source file missing during apply: ${entry.path}');
        continue;
      }

      final localizedContent = switch (entry.kind) {
        _SegmentKind.markdown => _applyMarkdown(
          sourceFile,
          entry,
          translationMemory,
          languageCode,
        ),
        _SegmentKind.jsonl => _applyJsonl(
          sourceFile,
          entry,
          translationMemory,
          languageCode,
        ),
      };

      if (localizedContent == null) {
        continue;
      }

      final outputFile = File.fromUri(outputRoot.uri.resolve(entry.path));
      outputFile.parent.createSync(recursive: true);
      outputFile.writeAsStringSync(localizedContent);
      updatedFiles += 1;
    }

    stdout.writeln(
      'Apply complete: wrote $updatedFiles files to ${outputRoot.path}.',
    );
  }

  String _relativePath(String absolutePath) {
    final normalized = absolutePath.replaceAll('\\', '/');
    final rootPath = root.path.replaceAll('\\', '/');
    if (normalized.startsWith('$rootPath/')) {
      return normalized.substring(rootPath.length + 1);
    }
    return normalized;
  }

  bool _matchesTargetPath(String relativePath) {
    final normalized = relativePath.replaceAll('\\', '/');
    final match = RegExp(r'^content/.*/v\d+/.+').hasMatch(normalized);
    return match;
  }

  bool _isSupportedSource(String path) {
    return path.endsWith('.md') || path.endsWith('.jsonl');
  }

  List<_Segment> _extractSegments(File file, String relativePath) {
    if (relativePath.endsWith('.md')) {
      return _MarkdownExtractor(relativePath, file).extract();
    }
    if (relativePath.endsWith('.jsonl')) {
      return _JsonlExtractor(relativePath, file).extract();
    }
    return const <_Segment>[];
  }

  String? _applyMarkdown(
    File file,
    _FileSegments entry,
    _TranslationMemory memory,
    String languageCode,
  ) {
    final lines = file.readAsLinesSync();
    var didChange = false;

    for (final segment in entry.segments) {
      final translation = memory.lookupTranslation(segment.hash, languageCode);
      if (translation == null) {
        continue;
      }
      final int lineIndex = segment.line - 1;
      if (lineIndex < 0 || lineIndex >= lines.length) {
        continue;
      }
      final context = segment.context;
      final leading = context['leading'] as String? ?? '';
      final trailing = context['trailing'] as String? ?? '';
      lines[lineIndex] = '$leading$translation$trailing';
      didChange = true;
    }

    if (!didChange) {
      return null;
    }

    return lines.join('\n');
  }

  String? _applyJsonl(
    File file,
    _FileSegments entry,
    _TranslationMemory memory,
    String languageCode,
  ) {
    final sourceLines = file.readAsLinesSync();
    if (sourceLines.isEmpty) {
      return null;
    }

    final lineGroups = <int, List<_Segment>>{};
    for (final segment in entry.segments) {
      lineGroups.putIfAbsent(segment.line, () => <_Segment>[]).add(segment);
    }

    final buffer = StringBuffer();
    bool didChange = false;

    for (var index = 0; index < sourceLines.length; index += 1) {
      final lineNumber = index + 1;
      final line = sourceLines[index].trim();
      if (line.isEmpty) {
        buffer.writeln();
        continue;
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(line);
      } catch (_) {
        buffer.writeln(sourceLines[index]);
        continue;
      }

      final segments = lineGroups[lineNumber];
      if (segments != null && segments.isNotEmpty) {
        for (final segment in segments) {
          final translation = memory.lookupTranslation(
            segment.hash,
            languageCode,
          );
          if (translation == null) {
            continue;
          }
          if (segment.context case {'pointer': final String pointer}) {
            if (_JsonPointerUpdater.replace(decoded, pointer, translation)) {
              didChange = true;
            }
          }
        }
      }

      final encoded = jsonEncode(decoded);
      buffer.writeln(encoded);
    }

    if (!didChange) {
      return null;
    }

    return buffer.toString();
  }
}

class _ExtractionAggregator {
  final List<_FileSegments> fileEntries = <_FileSegments>[];
  final Map<String, _Segment> _uniqueSegments = <String, _Segment>{};

  void addFileSegments(String path, List<_Segment> segments) {
    segments.sort((a, b) => a.line.compareTo(b.line));
    fileEntries.add(
      _FileSegments(
        path: path,
        segments: List<_Segment>.unmodifiable(segments),
      ),
    );
    for (final segment in segments) {
      _uniqueSegments.putIfAbsent(segment.hash, () => segment);
    }
  }

  Iterable<_Segment> get allSegments => _uniqueSegments.values;
}

class _FileSegments {
  _FileSegments({required this.path, required this.segments});

  final String path;
  final List<_Segment> segments;

  _SegmentKind get kind {
    if (path.endsWith('.md')) {
      return _SegmentKind.markdown;
    }
    return _SegmentKind.jsonl;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'path': path,
      'kind': kind.name,
      'segments': segments.map((segment) => segment.toJson()).toList(),
    };
  }

  static _FileSegments fromJson(Map<String, dynamic> json) {
    final path = json['path'] as String;
    final rawSegments = json['segments'] as List<dynamic>? ?? const <dynamic>[];
    final segments = rawSegments
        .map((item) => _Segment.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    return _FileSegments(path: path, segments: segments);
  }
}

enum _SegmentKind { markdown, jsonl }

class _Segment {
  _Segment({
    required this.hash,
    required this.source,
    required this.line,
    required this.context,
  });

  final String hash;
  final String source;
  final int line;
  final Map<String, dynamic> context;

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'hash': hash,
      'source': source,
      'line': line,
    };
    if (context.isNotEmpty) {
      final orderedContext = LinkedHashMap<String, dynamic>.fromEntries(
        context.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
      payload['context'] = orderedContext;
    }
    return payload;
  }

  static _Segment fromJson(Map<String, dynamic> json) {
    final hash = json['hash'] as String;
    final source = json['source'] as String? ?? '';
    final line = json['line'] as int? ?? 0;
    final contextRaw =
        json['context'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final orderedContext = LinkedHashMap<String, dynamic>.fromEntries(
      contextRaw.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return _Segment(
      hash: hash,
      source: source,
      line: line,
      context: orderedContext,
    );
  }
}

class _StringsIndex {
  _StringsIndex({required this.files});

  final List<_FileSegments> files;

  void save(String relativePath) {
    files.sort((a, b) => a.path.compareTo(b.path));
    final payload = <String, dynamic>{
      'files': files.map((file) => file.toJson()).toList(),
    };
    final encoder = JsonEncoder.withIndent('  ');
    final encoded = encoder.convert(payload);
    final normalized = _AsciiNormalizer.normalize(encoded);
    final outputFile = File(relativePath);
    outputFile.parent.createSync(recursive: true);
    outputFile.writeAsStringSync('$normalized\n');
  }

  static _StringsIndex load(String relativePath) {
    final sourceFile = File(relativePath);
    if (!sourceFile.existsSync()) {
      return _StringsIndex(files: const <_FileSegments>[]);
    }
    final content = sourceFile.readAsStringSync();
    final decoded = jsonDecode(content) as Map<String, dynamic>;
    final rawFiles = decoded['files'] as List<dynamic>? ?? const <dynamic>[];
    final files = rawFiles
        .map((item) => _FileSegments.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    return _StringsIndex(files: files);
  }
}

class _TranslationMemoryEntry {
  _TranslationMemoryEntry({
    required this.hash,
    required this.source,
    Map<String, String>? translations,
  }) : translations = translations != null
           ? LinkedHashMap<String, String>.fromEntries(
               translations.entries.toList()
                 ..sort((a, b) => a.key.compareTo(b.key)),
             )
           : LinkedHashMap<String, String>();

  final String hash;
  final String source;
  final LinkedHashMap<String, String> translations;

  Map<String, dynamic> toJson() {
    final orderedTranslations = LinkedHashMap<String, String>.fromEntries(
      translations.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return <String, dynamic>{
      'hash': hash,
      'source': source,
      'translations': orderedTranslations,
    };
  }

  static _TranslationMemoryEntry fromJson(Map<String, dynamic> json) {
    final hash = json['hash'] as String;
    final source = json['source'] as String? ?? '';
    final translationsRaw =
        json['translations'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final translations = LinkedHashMap<String, String>.fromEntries(
      translationsRaw.entries
          .map((entry) => MapEntry(entry.key, entry.value.toString()))
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );
    return _TranslationMemoryEntry(
      hash: hash,
      source: source,
      translations: translations,
    );
  }
}

class _TranslationMemory {
  _TranslationMemory(this._entries);

  final LinkedHashMap<String, _TranslationMemoryEntry> _entries;

  void ensureEntry(String hash, String source) {
    _entries.putIfAbsent(hash, () {
      return _TranslationMemoryEntry(hash: hash, source: source);
    });
  }

  String? lookupTranslation(String hash, String languageCode) {
    final entry = _entries[hash];
    if (entry == null) {
      return null;
    }
    return entry.translations[languageCode];
  }

  void save(String relativePath) {
    final sortedEntries = _entries.values.toList()
      ..sort((a, b) => a.hash.compareTo(b.hash));
    final payload = <String, dynamic>{
      'entries': sortedEntries.map((entry) => entry.toJson()).toList(),
    };
    final encoder = JsonEncoder.withIndent('  ');
    final encoded = encoder.convert(payload);
    final normalized = _AsciiNormalizer.normalize(encoded);
    final file = File(relativePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('$normalized\n');
  }

  static _TranslationMemory load(String relativePath) {
    final file = File(relativePath);
    if (!file.existsSync()) {
      return _TranslationMemory(
        LinkedHashMap<String, _TranslationMemoryEntry>(),
      );
    }
    final content = file.readAsStringSync();
    if (content.trim().isEmpty) {
      return _TranslationMemory(
        LinkedHashMap<String, _TranslationMemoryEntry>(),
      );
    }
    final decoded = jsonDecode(content) as Map<String, dynamic>;
    final rawEntries =
        decoded['entries'] as List<dynamic>? ?? const <dynamic>[];
    final ordered = LinkedHashMap<String, _TranslationMemoryEntry>();
    for (final item in rawEntries) {
      final entry = _TranslationMemoryEntry.fromJson(
        item as Map<String, dynamic>,
      );
      ordered[entry.hash] = entry;
    }
    return _TranslationMemory(ordered);
  }
}

abstract class _AsciiNormalizer {
  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final code in input.codeUnits) {
      if (_isSafeAscii(code)) {
        buffer.writeCharCode(code);
      } else {
        buffer.write(_encodeCodeUnit(code));
      }
    }
    return buffer.toString();
  }

  static bool _isSafeAscii(int code) {
    return (code >= 32 && code <= 126) || code == 10 || code == 13 || code == 9;
  }

  static String _encodeCodeUnit(int code) {
    final hex = code.toRadixString(16).padLeft(4, '0');
    return '\\u$hex';
  }
}

class _MarkdownExtractor {
  _MarkdownExtractor(this.relativePath, this.file);

  final String relativePath;
  final File file;

  List<_Segment> extract() {
    final List<String> lines;
    try {
      lines = file.readAsLinesSync();
    } catch (_) {
      return const <_Segment>[];
    }

    final segments = <_Segment>[];
    var inCodeBlock = false;

    for (var index = 0; index < lines.length; index += 1) {
      final lineNumber = index + 1;
      final line = lines[index];
      final trimmedLeft = line.trimLeft();
      if (trimmedLeft.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        continue;
      }
      if (inCodeBlock) {
        continue;
      }
      final parsed = _MarkdownLineInfo.parse(line);
      if (parsed == null) {
        continue;
      }
      if (!_TextFilters.looksEnglish(parsed.content)) {
        continue;
      }
      final normalized = _TextFilters.normalize(parsed.content);
      if (normalized.isEmpty) {
        continue;
      }
      final hash = _TextFilters.hash(normalized);
      segments.add(
        _Segment(
          hash: hash,
          source: parsed.content,
          line: lineNumber,
          context: <String, dynamic>{
            'leading': parsed.leading,
            'trailing': parsed.trailing,
          },
        ),
      );
    }

    return segments;
  }
}

class _JsonlExtractor {
  _JsonlExtractor(this.relativePath, this.file);

  final String relativePath;
  final File file;

  List<_Segment> extract() {
    final segments = <_Segment>[];
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index += 1) {
      final lineNumber = index + 1;
      final line = lines[index].trim();
      if (line.isEmpty) {
        continue;
      }
      dynamic decoded;
      try {
        decoded = jsonDecode(line);
      } catch (_) {
        continue;
      }
      _walk(decoded, '', (pointer, value) {
        final normalized = _TextFilters.normalize(value);
        if (normalized.isEmpty) {
          return;
        }
        final hash = _TextFilters.hash(normalized);
        segments.add(
          _Segment(
            hash: hash,
            source: value,
            line: lineNumber,
            context: <String, dynamic>{'pointer': pointer},
          ),
        );
      });
    }
    return segments;
  }

  void _walk(
    dynamic node,
    String pointer,
    void Function(String pointer, String value) add,
  ) {
    if (node is Map) {
      final keys = node.keys.map((key) => key.toString()).toList()..sort();
      for (final key in keys) {
        final value = node[key];
        final nextPointer = '$pointer/$key';
        _walk(value, nextPointer, add);
      }
      return;
    }
    if (node is List) {
      for (var i = 0; i < node.length; i += 1) {
        final nextPointer = '$pointer/$i';
        _walk(node[i], nextPointer, add);
      }
      return;
    }
    if (node is String) {
      if (_TextFilters.looksEnglish(node)) {
        add(pointer.isEmpty ? '/' : pointer, node);
      }
    }
  }
}

abstract class _JsonPointerUpdater {
  static bool replace(dynamic root, String pointer, String newValue) {
    if (!pointer.startsWith('/')) {
      return false;
    }
    final segments = pointer.split('/').skip(1).map(_unescape).toList();
    if (segments.isEmpty) {
      return false;
    }
    dynamic current = root;
    for (var i = 0; i < segments.length - 1; i += 1) {
      final segment = segments[i];
      if (current is Map<String, dynamic>) {
        current = current[segment];
      } else if (current is List) {
        final index = int.tryParse(segment);
        if (index == null || index < 0 || index >= current.length) {
          return false;
        }
        current = current[index];
      } else {
        return false;
      }
      if (current == null) {
        return false;
      }
    }
    final lastSegment = segments.last;
    if (current is Map<String, dynamic>) {
      if (!current.containsKey(lastSegment)) {
        return false;
      }
      current[lastSegment] = newValue;
      return true;
    }
    if (current is List) {
      final index = int.tryParse(lastSegment);
      if (index == null || index < 0 || index >= current.length) {
        return false;
      }
      current[index] = newValue;
      return true;
    }
    return false;
  }

  static String _unescape(String value) {
    return value.replaceAll('~1', '/').replaceAll('~0', '~');
  }
}

abstract class _TextFilters {
  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _englishLetters = RegExp(r'[A-Za-z]');

  static bool looksEnglish(String input) {
    return _englishLetters.hasMatch(input);
  }

  static String normalize(String input) {
    final sanitized = input.replaceAll(_whitespace, ' ').trim();
    return sanitized;
  }

  static String hash(String input) {
    final bytes = input.codeUnits;
    const int fnvOffset = 0xcbf29ce484222325;
    const int fnvPrime = 0x100000001b3;
    int hash = fnvOffset;
    for (final unit in bytes) {
      hash ^= unit;
      hash = (hash * fnvPrime) & _mask64;
    }
    final value = hash & _mask64;
    return value.toRadixString(16).padLeft(16, '0');
  }

  static const int _mask64 = 0xFFFFFFFFFFFFFFFF;
}

class _MarkdownLineInfo {
  _MarkdownLineInfo({
    required this.leading,
    required this.content,
    required this.trailing,
  });

  final String leading;
  final String content;
  final String trailing;

  static final RegExp _bulletPrefix = RegExp(r'^([-*+]|\d+\.)\s+');
  static final RegExp _headingPrefix = RegExp(r'^#{1,6}\s+');
  static final RegExp _blockquotePrefix = RegExp(r'^>\s+');

  static _MarkdownLineInfo? parse(String line) {
    if (line.trim().isEmpty) {
      return null;
    }

    final withoutTrailing = line.replaceAll(RegExp(r'\s+$'), '');
    final trailing = line.substring(withoutTrailing.length);
    final leadingWhitespaceLength =
        withoutTrailing.length - withoutTrailing.trimLeft().length;
    final afterWhitespace = withoutTrailing.substring(leadingWhitespaceLength);

    var prefixLength = 0;
    final heading = _headingPrefix.matchAsPrefix(afterWhitespace);
    if (heading != null) {
      prefixLength = heading.end;
    } else {
      final bullet = _bulletPrefix.matchAsPrefix(afterWhitespace);
      if (bullet != null) {
        prefixLength = bullet.end;
      } else {
        final quote = _blockquotePrefix.matchAsPrefix(afterWhitespace);
        if (quote != null) {
          prefixLength = quote.end;
        }
      }
    }

    final contentStart = leadingWhitespaceLength + prefixLength;
    if (contentStart >= withoutTrailing.length) {
      return null;
    }
    final content = withoutTrailing.substring(contentStart).trim();
    if (content.isEmpty) {
      return null;
    }
    final leading = line.substring(0, contentStart);
    return _MarkdownLineInfo(
      leading: leading,
      content: content,
      trailing: trailing,
    );
  }
}
