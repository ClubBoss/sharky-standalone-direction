import 'dart:convert';
import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> main(List<String> args) async {
  final tmp = Directory.systemTemp.createTempSync('export_validation_');
  final csvPath = await _writeCsv(tmp);
  final pdfPath = await _writePdf(tmp);

  final csvBytes = await File(csvPath).length();
  final pdfBytes = await File(pdfPath).length();

  final files = [
    {'path': csvPath, 'bytes': csvBytes},
    {'path': pdfPath, 'bytes': pdfBytes},
  ];
  final total = csvBytes + pdfBytes;
  final minB = [csvBytes, pdfBytes].reduce((a, b) => a < b ? a : b);
  final metrics = {
    'count': files.length,
    'totalBytes': total,
    'minBytes': minB,
    'files': files,
  };

  await File('export_metrics.json').writeAsString(jsonEncode(metrics));
  stdout.writeln(jsonEncode(metrics));
}

Future<String> _writeCsv(Directory dir) async {
  final file = File('${dir.path}/validation_export.csv');
  final buf = StringBuffer();
  buf.writeln('Date;Duration;Count;Correct;EV;ICM');
  final now = DateTime.now();
  for (int i = 0; i < 200; i++) {
    final d = now.subtract(Duration(days: i));
    final dur = Duration(minutes: 30 + (i % 90));
    final count = 20 + (i % 30);
    final correct = 10 + (i % 20);
    final ev = (i % 100) / 10.0;
    final icm = (i % 80) / 12.0;
    buf.writeln(
      '${_date(d)};${_dur(dur)};$count;$correct;${ev.toStringAsFixed(2)};${icm.toStringAsFixed(2)}',
    );
  }
  await file.writeAsString(buf.toString());
  return file.path;
}

Future<String> _writePdf(Directory dir) async {
  final pdf = pw.Document();
  final regular = pw.Font.helvetica();
  final bold = pw.Font.helveticaBold();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => [
        pw.Text(
          'Export Validation Report',
          style: pw.TextStyle(font: bold, fontSize: 24),
        ),
        pw.SizedBox(height: 12),
        for (int i = 0; i < 50; i++)
          pw.Text(
            'Row ${i + 1}: summary line of export content',
            style: pw.TextStyle(font: regular, fontSize: 12),
          ),
      ],
    ),
  );
  final bytes = await pdf.save();
  final file = File('${dir.path}/validation_export.pdf');
  await file.writeAsBytes(bytes);
  return file.path;
}

String _date(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String _dur(Duration d) => '${d.inMinutes}m';
