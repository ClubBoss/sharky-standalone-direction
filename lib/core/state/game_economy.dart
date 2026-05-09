import 'package:flutter/foundation.dart';

class GameEconomy extends ChangeNotifier {
  static const int maxFreeRefill = 200;
  static const int refillAmount = 100;
  static final Duration refillInterval = Duration(hours: 4);

  int _currentChips = 1000;
  DateTime _lastRefillTime = DateTime.now();

  int get bankroll => _currentChips;

  void earn(int amount) {
    _currentChips += amount;
    notifyListeners();
  }

  void lose(int amount) {
    _currentChips -= amount;
    if (_currentChips < 0) {
      _currentChips = 0;
    }
    notifyListeners();
  }

  bool payEntryFee(int cost) {
    if (_currentChips >= cost) {
      _currentChips -= cost;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool checkRefill() {
    if (_currentChips >= 50) return false;
    final now = DateTime.now();
    if (now.difference(_lastRefillTime) >= refillInterval) {
      _currentChips = refillAmount;
      _lastRefillTime = now;
      notifyListeners();
      return true;
    }
    return false;
  }

  Duration timeUntilRefill() {
    final now = DateTime.now();
    final remaining = refillInterval - now.difference(_lastRefillTime);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool isBusted() => _currentChips <= 0;
}
