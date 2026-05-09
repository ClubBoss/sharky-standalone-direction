import 'package:flutter/foundation.dart';

class V4ThemeController extends ChangeNotifier {
  V4ThemeController({required this.isActive});

  bool isActive;

  bool get isV4Active => isActive;

  void toggle() {
    isActive = !isActive;
    notifyListeners();
  }

  void setActive(bool next) {
    if (isActive == next) return;
    isActive = next;
    notifyListeners();
  }

  Listenable get listenable => this;
}
