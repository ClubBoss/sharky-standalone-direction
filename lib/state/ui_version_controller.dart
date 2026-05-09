import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/config/app_flags.dart';

class UiVersionController extends ValueNotifier<bool> {
  UiVersionController() : super(kUseUiV3);
}

final UiVersionController uiVersionController = UiVersionController();
