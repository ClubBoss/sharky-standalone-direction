import 'package:flutter/foundation.dart';

const act0CurriculumPilotEnabledV1 =
    kDebugMode && bool.fromEnvironment('SHARKY_W13_PLUS_PILOT');

const act0LastCurriculumWorldV1 = act0CurriculumPilotEnabledV1 ? 24 : 12;
