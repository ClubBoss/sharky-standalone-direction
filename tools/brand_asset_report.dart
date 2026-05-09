// ASCII-only CLI tool to audit brand assets and write a simple report.
import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final report = await BrandAssetReport().run();
  stdout.writeln(report.summaryLine);
}

class BrandAssetReportResult {
  BrandAssetReportResult({
    required this.logoFound,
    required this.logoPath,
    required this.mascotCount,
    required this.iconCount,
    required this.outputPath,
  });

  final bool logoFound;
  final String logoPath;
  final int mascotCount;
  final int iconCount;
  final String outputPath;

  String get summaryLine =>
      'brand_asset_audit_completed: logoFound=${logoFound ? 'yes' : 'no'}, mascots=$mascotCount, icons=$iconCount -> $outputPath';
}

class BrandAssetReport {
  Future<BrandAssetReportResult> run() async {
    final projectRoot = Directory.current.path;
    final brandDir = Directory('assets/brand');
    final mascotDir = Directory('assets/brand/mascot');
    final iconDir = Directory('assets/brand/icons');

    final hasBrandDir = brandDir.existsSync();
    final logo = hasBrandDir
        ? _findFirst(brandDir, [
            'logo.png',
            'logo.jpg',
            'logo.jpeg',
            'logo.svg',
          ])
        : null;
    final logoFound = logo != null;
    final logoPath = logoFound ? logo.path : '';

    final mascots = mascotDir.existsSync()
        ? mascotDir
              .listSync()
              .whereType<File>()
              .where((f) => _isImageOrSvg(f.path))
              .toList()
        : <File>[];
    final icons = iconDir.existsSync()
        ? iconDir
              .listSync()
              .whereType<File>()
              .where((f) => _isImageOrSvg(f.path))
              .toList()
        : <File>[];

    final outDir = Directory('release/_reports');
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }
    final outPath = '${outDir.path}/brand_asset_report.txt';
    final sink = File(outPath).openWrite();

    final now = DateTime.now().toUtc().toIso8601String();
    sink.writeln('Brand Asset Report');
    sink.writeln('Timestamp: $now');
    sink.writeln('Project: $projectRoot');
    sink.writeln('');
    sink.writeln('assets/brand/        : ${hasBrandDir ? 'OK' : 'MISSING'}');
    sink.writeln(
      'logo                  : ${logoFound ? 'OK -> $logoPath' : 'MISSING'}',
    );
    sink.writeln(
      'mascot set (count)    : ${mascots.length > 0 ? 'OK -> ${mascots.length}' : 'MISSING'}',
    );
    sink.writeln(
      'icon set (count)      : ${icons.length > 0 ? 'OK -> ${icons.length}' : 'MISSING'}',
    );
    sink.writeln('');
    sink.writeln('Details:');
    if (logoFound) sink.writeln(' - logo: $logoPath');
    if (mascots.isNotEmpty) {
      for (final f in mascots) {
        sink.writeln(' - mascot: ${f.path}');
      }
    }
    if (icons.isNotEmpty) {
      for (final f in icons) {
        sink.writeln(' - icon: ${f.path}');
      }
    }
    await sink.close();

    // Emit simple file-based telemetry JSONL (no external deps)
    final telemetryPath = '${outDir.path}/telemetry.jsonl';
    final telemetryFile = File(telemetryPath);
    final telemetry = {
      'event': 'brand_asset_audit_completed',
      'timestamp': now,
      'logo_found': logoFound,
      'mascot_count': mascots.length,
      'icon_count': icons.length,
      'report_path': outPath,
    };
    telemetryFile.writeAsStringSync(
      jsonEncode(telemetry) + '\n',
      mode: FileMode.append,
    );

    return BrandAssetReportResult(
      logoFound: logoFound,
      logoPath: logoPath,
      mascotCount: mascots.length,
      iconCount: icons.length,
      outputPath: outPath,
    );
  }

  File? _findFirst(Directory dir, List<String> names) {
    for (final name in names) {
      final f = File('${dir.path}/$name');
      if (f.existsSync()) return f;
    }
    return null;
  }

  bool _isImageOrSvg(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.svg');
  }
}
