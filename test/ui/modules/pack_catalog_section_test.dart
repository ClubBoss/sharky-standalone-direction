import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/models/training_pack_meta.dart';
import 'package:poker_analyzer/ui/modules/modules_screen.dart';

void main() {
  testWidgets('locked pack renders difficulty label and badge once', (
    tester,
  ) async {
    const meta = TrainingPackMeta(
      id: 'advanced_pushfold_15bb',
      title: 'Advanced Push/Fold 15bb',
      skillLevel: 'advanced',
      tags: ['advanced', 'pushfold'],
      trainingType: TrainingType.pushFold,
      difficultyTier: 3,
      availability: PackAvailabilityV1.locked,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PackCatalogTile(meta: meta)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Locked'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);
  });
}
