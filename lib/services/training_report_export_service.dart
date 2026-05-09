import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../services/session_log_service.dart';
import '../services/skill_summary_service.dart';
import '../services/weekly_loop_service.dart';

class TrainingReportExportService {
  static final TrainingReportExportService instance =
      TrainingReportExportService._privateConstructor();

  TrainingReportExportService._privateConstructor();

  Future<File> exportToFile() async {
    final pdf = pw.Document();

    // Fetch data
    final sessionCounts = await SessionLogService.instance.getSessionCounts();
    final topTopics = await SkillSummaryService.instance
        .getTopPracticedTopics();
    final skillSummary = await SkillSummaryService.instance.getSkillSummary();
    final loopStats = await WeeklyLoopService.instance.getLoopStats();

    // Add content to PDF
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Training Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Date Range: Last 30 days'),
            pw.SizedBox(height: 16),

            // Sessions Completed
            pw.Text(
              'Sessions Completed',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Last 7 days: ${sessionCounts['last7Days']}'),
            pw.Text('Last 30 days: ${sessionCounts['last30Days']}'),
            pw.SizedBox(height: 16),

            // Topics Practiced
            pw.Text(
              'Topics Practiced',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            ...topTopics.map(
              (topic) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(topic['name'] as String),
                  pw.Text('${topic['count']}'),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Skill Summary
            pw.Text(
              'Your Skill Summary',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Strong topics: ${skillSummary['strong']}'),
            pw.Text('Weak topics: ${skillSummary['weak']}'),
            pw.Text('New topics: ${skillSummary['new']}'),
            pw.SizedBox(height: 16),

            // Loop Completions
            pw.Text(
              'Loop Completions',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Current streak: ${loopStats['currentStreak']}'),
            pw.Text('Total this week: ${loopStats['totalThisWeek']}'),
          ],
        ),
      ),
    );

    // Save PDF to file
    final outputDir = await getApplicationDocumentsDirectory();
    final file = File('${outputDir.path}/training_report.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
