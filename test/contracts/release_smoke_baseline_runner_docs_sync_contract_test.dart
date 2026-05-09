import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('release smoke baseline runner documented', () {
    final rules = File('docs/EXECUTION_RULES.md');
    final script = File('tool/release_smoke_baseline_v1.sh');
    final smokeBaseline = File(
      'docs/release/final_product_smoke_baseline_v1.md',
    );
    if (!rules.existsSync()) {
      fail('Missing docs/EXECUTION_RULES.md');
    }

    final content = rules.readAsStringSync();
    final runnerPath = 'tool/release_smoke_baseline_v1.sh';
    final heading = 'Release Smoke Baseline';
    final scriptContent = script.existsSync() ? script.readAsStringSync() : '';
    final missing = <String>[];

    if (!content.contains(heading)) {
      missing.add('section header "$heading"');
    }
    if (!content.contains(runnerPath)) {
      missing.add('runner path "$runnerPath"');
    }
    if (!content.contains('It remains a bounded smoke family')) {
      missing.add('bounded smoke note in docs/EXECUTION_RULES.md');
    }
    if (!script.existsSync()) {
      missing.add('script file "$runnerPath"');
    }
    if (!smokeBaseline.existsSync()) {
      missing.add('missing docs/release/final_product_smoke_baseline_v1.md');
    }
    if (!scriptContent.contains('set -euo pipefail')) {
      missing.add('script must enable "set -euo pipefail"');
    }

    const steps = <String>[
      'test/guards/app_boot_release_smoke_test.dart',
      'test/ui_v2/onboarding_first_win_test.dart',
      'test/guards/world1_intake_plan_flow_contract_test.dart',
      'test/ui_v2/session_result_world1_onboarding_payoff_test.dart',
      'test/ui_v2/today_plan_entitlement_truth_v1_test.dart',
      'test/ui_v2/premium_hub_access_state_v1_test.dart',
      'today plan gates world5 placement behind premium preview and restore unblocks next attempt',
      'today plan allows trial-active entitlement to open premium-target placement deterministically',
      'test/guards/module_launcher_legacy_bridge_boundary_contract_test.dart',
      'test/ui_v2/legal_screen_v1_test.dart',
    ];
    final indices = <int>[];
    for (final step in steps) {
      indices.add(scriptContent.indexOf(step));
      if (!scriptContent.contains(step)) {
        missing.add('script missing step: $step');
      }
    }
    for (var i = 1; i < indices.length; i++) {
      if (indices[i - 1] >= 0 &&
          indices[i] >= 0 &&
          indices[i] <= indices[i - 1]) {
        missing.add('script steps out of order near: ${steps[i]}');
      }
    }

    if (missing.isNotEmpty) {
      final buffer = StringBuffer()
        ..writeln(
          'Release smoke baseline runner docs contract failed: update docs/EXECUTION_RULES.md and tool/release_smoke_baseline_v1.sh.',
        )
        ..writeln(missing.map((line) => '- $line').join('\n'));
      fail(buffer.toString());
    }
  });
}
