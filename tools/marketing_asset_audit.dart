import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final auditor = _MarketingAssetAudit();
  final report = auditor.run();
  report.printTable();
  await report.writeReport('release/_reports/marketing_asset_summary.txt');
  report.emitTelemetry();
  if (!report.isClean) {
    exit(1);
  }
}

class _MarketingAssetAudit {
  _AuditReport run() {
    final missingFiles = <String>[];
    final missingPubspec = <String>[];
    final pubspec = File('pubspec.yaml');
    final pubspecContent = pubspec.existsSync()
        ? pubspec.readAsStringSync()
        : '';

    for (final path in _requiredAssets) {
      if (!File(path).existsSync()) {
        missingFiles.add(path);
      }
      if (!pubspecContent.contains(path)) {
        missingPubspec.add(path);
      }
    }

    return _AuditReport(
      missingFiles: missingFiles,
      missingPubspec: missingPubspec,
    );
  }
}

class _AuditReport {
  _AuditReport({required this.missingFiles, required this.missingPubspec});

  final List<String> missingFiles;
  final List<String> missingPubspec;

  bool get isClean => missingFiles.isEmpty && missingPubspec.isEmpty;

  void printTable() {
    final rows = <List<String>>[
      ['Category', 'Details'],
      ['Assets', missingFiles.isEmpty ? 'OK' : missingFiles.join(', ')],
      [
        'pubspec.yaml',
        missingPubspec.isEmpty ? 'OK' : missingPubspec.join(', '),
      ],
      [
        'Summary',
        'missing_files=${missingFiles.length} '
            '| missing_pubspec=${missingPubspec.length}',
      ],
    ];
    _asciiTable(rows);
  }

  Future<void> writeReport(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final buffer = StringBuffer()
      ..writeln('Marketing Asset Audit')
      ..writeln('missing_files=${missingFiles.length}')
      ..writeln('missing_pubspec=${missingPubspec.length}')
      ..writeln('status=${isClean ? 'PASS' : 'FAIL'}');
    await file.writeAsString(buffer.toString());
  }

  void emitTelemetry() {
    final payload = <String, Object>{
      'event': 'marketing_asset_audit_completed',
      'missing_files': missingFiles.length,
      'missing_pubspec': missingPubspec.length,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    stdout.writeln(jsonEncode(payload));
  }

  void _asciiTable(List<List<String>> rows) {
    final widths = List<int>.generate(rows.first.length, (index) => 0);
    for (final row in rows) {
      for (var i = 0; i < row.length; i++) {
        if (row[i].length > widths[i]) {
          widths[i] = row[i].length;
        }
      }
    }
    final border = '+-${'-' * widths[0]}-+-${'-' * widths[1]}-+';
    stdout.writeln(border);
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      stdout.writeln(
        '| ${row[0].padRight(widths[0])} | ${row[1].padRight(widths[1])} |',
      );
      if (i == 0) {
        stdout.writeln(border);
      }
    }
    stdout.writeln(border);
  }
}

const List<String> _requiredAssets = <String>[
  'assets/brand/logo.svg',
  'assets/brand/mascot.svg',
  'assets/brand/icons/app_icon.svg',
];
