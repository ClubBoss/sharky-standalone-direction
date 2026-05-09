import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('store assets confidence gate contract stays stable', () async {
    final script = File('tools/store_assets_v1.sh');
    expect(script.existsSync(), isTrue, reason: 'missing store assets script');
    final scriptBody = script.readAsStringSync();

    final required = <String>[
      'modern_table_default.png',
      'modern_table_json.png',
      'modern_table_asset.png',
      'modern_table_default_portrait.png',
      'modern_table_json_portrait.png',
      'modern_table_asset_portrait.png',
      'modern_table_action_context.png',
      'modern_table_action_context_portrait.png',
      'runner_outcome_store.png',
      'campaign_map_duolingo_v1.png',
      'campaign_map_single_spine_v2.png',
      'runner_portrait_fullwidth_v1.png',
      'runner_vertical_final_v1.png',
      'device_entry_path_parity_v1.png',
      'intake_seat_order_v1.png',
      'today_plan_runner_vertical_proof_v1.png',
      'intake_table_vertical_proof_v1.png',
      'runner_table_first_iphone_v1.png',
      'map_ladder_iphone_v1.png',
      'seat_quiz_order_v1.png',
      'modern_table_screenshots_v1.zip',
    ];

    for (final name in required) {
      expect(
        scriptBody.contains(name),
        isTrue,
        reason: 'store_assets_v1.sh no longer references required asset $name',
      );
    }

    final requiredThresholds = <String>[
      'png_min_bytes=5000',
      'zip_min_bytes=20000',
    ];
    for (final threshold in requiredThresholds) {
      expect(
        scriptBody.contains(threshold),
        isTrue,
        reason: 'store_assets_v1.sh missing confidence threshold: $threshold',
      );
    }
  });
}
