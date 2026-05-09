import 'package:flutter/foundation.dart';

const String kCanonicalFirstSessionModuleIdV1 = 'world1_act0_table_literacy';

@immutable
class FirstSessionTrustPlanContractV1 {
  const FirstSessionTrustPlanContractV1({
    required this.titleLine,
    required this.productPromiseLine,
    required this.promiseLine,
    required this.successLine,
    required this.launchSubtitleLine,
    required this.sharkyLine,
  });

  final String titleLine;
  final String productPromiseLine;
  final String promiseLine;
  final String successLine;
  final String launchSubtitleLine;
  final String sharkyLine;
}

@immutable
class FirstSessionAhaContractV1 {
  const FirstSessionAhaContractV1({
    required this.realTableWhyLine,
    required this.continuationLine,
    required this.sharkyLine,
  });

  final String realTableWhyLine;
  final String continuationLine;
  final String sharkyLine;
}

bool isCanonicalFirstSessionModuleV1(String moduleId) =>
    moduleId.trim().toLowerCase() == kCanonicalFirstSessionModuleIdV1;

FirstSessionTrustPlanContractV1? resolveFirstSessionTrustPlanContractV1(
  String moduleId,
) {
  if (!isCanonicalFirstSessionModuleV1(moduleId)) {
    return null;
  }
  return const FirstSessionTrustPlanContractV1(
    titleLine: 'Sharky Poker',
    productPromiseLine:
        'Table-first training so every later poker decision starts from the right seat.',
    promiseLine:
        'Today you will learn who acts first by locating Button, small blind, and big blind.',
    successLine:
        'Success today: name Button, small blind, and big blind without guessing.',
    launchSubtitleLine:
        'Start with the table map: dealer anchor first, then the blind pair.',
    sharkyLine:
        'Sharky: Start with the seat map. The rest of the hand builds from there.',
  );
}

FirstSessionAhaContractV1? resolveFirstSessionAhaContractV1(String moduleId) {
  if (!isCanonicalFirstSessionModuleV1(moduleId)) {
    return null;
  }
  return const FirstSessionAhaContractV1(
    realTableWhyLine:
        'Real-table value: once Button and the blinds are clear, your first action choice has a reason instead of a guess.',
    continuationLine:
        'Next: use this same seat map to choose the first action before the flop.',
    sharkyLine:
        'Sharky: Good. Keep the seat map first and the next spot will read cleaner.',
  );
}
