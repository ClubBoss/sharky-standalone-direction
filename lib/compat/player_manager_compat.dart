import 'package:poker_analyzer/services/player_manager_service.dart';
import 'package:poker_analyzer/models/player_model.dart';
import 'package:poker_analyzer/models/action_entry.dart';
import 'package:poker_analyzer/models/card_model.dart';

extension PlayerManagerServiceCompat on PlayerManagerService {
  void updatePlayer(
    int index, {
    required int stack,
    required PlayerType type,
    required bool isHero,
    required List<CardModel> cards,
    bool disableCards = false,
  }) {}
  void setInitialStack(int index, int stack) {}
  void removePlayer(
    int index, {
    required int heroIndexOverride,
    required List<ActionEntry> actions,
    required List<bool> hintFlags,
  }) {}
  void selectCard(int playerIndex, CardModel card) {}
  void setPlayerCard(int playerIndex, int cardIndex, CardModel card) {}
  void setRevealedCard(int playerIndex, int cardIndex, CardModel card) {}
}
