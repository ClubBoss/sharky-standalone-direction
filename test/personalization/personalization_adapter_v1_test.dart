import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/personalization_adapter_v1.dart';

Map<String, Object?> _json({bool? ok}) => {'ok': ok};

void main() {
  test('idle when all ok', () {
    final recommendation = recommendFromReports(
      phase1ReportJson: _json(ok: true),
      phase2ReportJson: _json(ok: true),
      phase3ReportJson: _json(ok: true),
    );
    expect(recommendation.action.name, 'idle');
  });

  test('repeat for failing phase2', () {
    final recommendation = recommendFromReports(
      phase1ReportJson: _json(ok: true),
      phase2ReportJson: _json(ok: false),
    );
    expect(recommendation.action.name, 'run_phase2');
  });

  test('run phase3 when missing', () {
    final recommendation = recommendFromReports(
      phase1ReportJson: _json(ok: true),
      phase2ReportJson: _json(ok: true),
    );
    expect(recommendation.action.name, 'run_phase3');
  });

  test('handles null reports gracefully', () {
    final recommendation = recommendFromReports();
    expect(recommendation.action.name, 'idle');
    expect(recommendation.reason, contains('inputs=none'));
  });
}
