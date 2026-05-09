import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/screens/v2/training_pack_template_list_screen.dart';
import 'package:poker_analyzer/services/training_spot_storage_service.dart';
import 'package:poker_analyzer/models/training_spot.dart';
import 'package:poker_analyzer/models/card_model.dart';
import 'package:poker_analyzer/models/action_entry.dart';
import 'package:poker_analyzer/models/player_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTrainingSpotService extends TrainingSpotStorageService {
  _FakeTrainingSpotService(this.spots) : super();
  final List<TrainingSpot> spots;
  @override
  Future<List<TrainingSpot>> load() async => spots;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('favorites generation logs history', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final spot = TrainingSpot(
      playerCards: [
        [CardModel(rank: 'A', suit: '♠'), CardModel(rank: 'K', suit: '♦')),
        [CardModel(rank: 'Q', suit: '♠'), CardModel(rank: 'J', suit: '♣')),
      ],
      boardCards: [],
      actions: [ActionEntry(0, 0, 'push')),
      heroIndex: 0,
      numberOfPlayers: 2,
      playerTypes: [PlayerType.unknown, PlayerType.unknown],
      positions: ['SB', 'BB'],
      stacks: [10, 10],
      tags: ['favorite'],
    );
    final service = _FakeTrainingSpotService([spot]);
    await tester.pumpWidget(
      ChangeNotifierProvider<TrainingSpotStorageService>.value(
        value: service,
        child: MaterialApp(home: TrainingPackTemplateListScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorites Pack'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recent Generated Packs'));
    await tester.pumpAndSettle();
    expect(find.text('Favorites'), findsOneWidget);
  });
}
