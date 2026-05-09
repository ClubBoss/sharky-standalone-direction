import 'dart:convert';
import 'dart:io';

class LayoutCohesionBundle {
  LayoutCohesionBundle({required this.stats, required this.anomalies});

  final Map<String, Object?> stats;
  final List<String> anomalies;
}

class LayoutCohesionExtractorService {
  const LayoutCohesionExtractorService();

  Future<LayoutCohesionBundle> extract() async {
    final stats = {
      'padding': <double>{},
      'margin': <double>{},
      'sizedbox_heights': <double>{},
      'sizedbox_widths': <double>{},
      'container_constraints': <String>{},
      'rows': 0,
      'columns': 0,
      'grids': 0,
      'alignment': <String>{},
      'fixed_sizes': <double>{},
    };
    final anomalies = <String>[];
    final paddingRegex = RegExp(
      r'EdgeInsets\.(?:all|symmetric|only)\(([^)]*)\)',
    );
    final sizeRegex = RegExp(
      r'SizedBox\s*\(\s*(?:height\s*:\s*([\d.]+))?[^,]*?(?:width\s*:\s*([\d.]+))?',
    );
    final containerRegex = RegExp(
      r'Container\([^)]*constraints:\s*BoxConstraints\(([^)]*)\)',
    );
    final rowRegex = RegExp(r'\bRow\b');
    final columnRegex = RegExp(r'\bColumn\b');
    final gridRegex = RegExp(r'\bGridView\b');
    final alignmentRegex = RegExp(
      r'(alignment|crossAxisAlignment|mainAxisAlignment)\s*:\s*([A-Za-z0-9_.]+)',
    );
    final fixedSizeRegex = RegExp(r'(width|height)\s*:\s*([\d.]+)');
    final directories = ['lib/screens', 'lib/widgets'];
    final stackDepthThreshold = 3;
    for (final dir in directories) {
      final base = Directory(dir);
      if (!await base.exists()) {
        throw StateError('Missing directory: $dir');
      }
      await for (final entity in base.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) continue;
        final path = entity.path;
        final content = await _readAscii(path);
        final lines = content.split(RegExp(r'\r?\n'));
        var rowDepth = 0;
        var columnDepth = 0;
        for (final line in lines) {
          _extractPadding(line, paddingRegex, stats, anomalies);
          _extractMargin(line, paddingRegex, stats);
          _extractSizedBox(line, sizeRegex, stats, anomalies);
          _extractContainer(line, containerRegex, stats);
          _extractFixedSizes(line, fixedSizeRegex, stats, anomalies);
          _checkAlignment(line, alignmentRegex, stats);
          if (rowRegex.hasMatch(line)) {
            stats['rows'] = (stats['rows'] as int) + 1;
            rowDepth++;
            if (rowDepth > stackDepthThreshold) {
              anomalies.add('deep_row_nesting at $path');
            }
          }
          if (columnRegex.hasMatch(line)) {
            stats['columns'] = (stats['columns'] as int) + 1;
            columnDepth++;
            if (columnDepth > stackDepthThreshold) {
              anomalies.add('deep_column_nesting at $path');
            }
          }
          if (gridRegex.hasMatch(line)) {
            stats['grids'] = (stats['grids'] as int) + 1;
          }
        }
        rowDepth = 0;
        columnDepth = 0;
      }
    }
    final bundleStats = {
      'padding': (stats['padding'] as Set<double>).toList(),
      'margin': (stats['margin'] as Set<double>).toList(),
      'sizedbox_heights': (stats['sizedbox_heights'] as Set<double>).toList(),
      'sizedbox_widths': (stats['sizedbox_widths'] as Set<double>).toList(),
      'container_constraints': (stats['container_constraints'] as Set<String>)
          .toList(),
      'rows': stats['rows'],
      'columns': stats['columns'],
      'grids': stats['grids'],
      'alignment': (stats['alignment'] as Set<String>).toList(),
      'fixed_sizes': (stats['fixed_sizes'] as Set<double>).toList(),
    };
    return LayoutCohesionBundle(stats: bundleStats, anomalies: anomalies);
  }

  Future<String> _readAscii(String path) async {
    final file = File(path);
    final content = await file.readAsBytes();
    if (!_isAscii(content)) {
      throw StateError('Non-ASCII file: $path');
    }
    return utf8.decode(content);
  }

  bool _isAscii(List<int> bytes) => bytes.every((b) => b >= 0 && b <= 127);

  void _extractPadding(
    String line,
    RegExp regex,
    Map<String, Object?> stats,
    List<String> anomalies,
  ) {
    final match = regex.firstMatch(line);
    if (match == null) return;
    final value = _extractNumber(match.group(1));
    if (value != null) {
      (stats['padding'] as Set<double>).add(value);
      if (value > 48) anomalies.add('wide_padding: $value');
    }
  }

  void _extractMargin(String line, RegExp regex, Map<String, Object?> stats) {
    final match = regex.firstMatch(line);
    if (match == null) return;
    final value = _extractNumber(match.group(1));
    if (value != null) {
      (stats['margin'] as Set<double>).add(value);
    }
  }

  void _extractSizedBox(
    String line,
    RegExp regex,
    Map<String, Object?> stats,
    List<String> anomalies,
  ) {
    final match = regex.firstMatch(line);
    if (match == null) return;
    final height = _extractNumber(match.group(1));
    final width = _extractNumber(match.group(2));
    if (height != null) {
      (stats['sizedbox_heights'] as Set<double>).add(height);
      if (height < 0) anomalies.add('negative_height: $height');
    }
    if (width != null) {
      (stats['sizedbox_widths'] as Set<double>).add(width);
      if (width < 0) anomalies.add('negative_width: $width');
    }
  }

  void _extractContainer(
    String line,
    RegExp regex,
    Map<String, Object?> stats,
  ) {
    final match = regex.firstMatch(line);
    if (match == null) return;
    (stats['container_constraints'] as Set<String>).add(match.group(1) ?? '');
  }

  void _extractFixedSizes(
    String line,
    RegExp regex,
    Map<String, Object?> stats,
    List<String> anomalies,
  ) {
    final match = regex.firstMatch(line);
    if (match == null) return;
    final value = _extractNumber(match.group(2));
    if (value != null) {
      (stats['fixed_sizes'] as Set<double>).add(value);
      if (value < 0) anomalies.add('negative_fixed_size: $value');
    }
  }

  void _checkAlignment(String line, RegExp regex, Map<String, Object?> stats) {
    final match = regex.firstMatch(line);
    if (match == null) return;
    final value = match.group(2);
    if (value != null) {
      (stats['alignment'] as Set<String>).add(value);
    }
  }

  double? _extractNumber(String? value) {
    if (value == null) return null;
    final clean = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean);
  }
}
