import 'package:flutter/material.dart';
import 'package:poker_analyzer/models/v2/training_pack_v2.dart';
import 'package:poker_analyzer/models/v2/training_session.dart';
import 'package:poker_analyzer/screens/training_session_screen.dart';

enum CanonicalLegacyTrainingLaunchFamilyV1 { pack, session }

class CanonicalLegacyTrainingLaunchInputV1 {
  const CanonicalLegacyTrainingLaunchInputV1._({
    required this.family,
    this.pack,
    this.session,
    this.startIndex = 0,
    this.source,
    this.onSessionEnd,
  });

  const CanonicalLegacyTrainingLaunchInputV1.pack({
    required TrainingPackV2 pack,
    int startIndex = 0,
    String? source,
    VoidCallback? onSessionEnd,
  }) : this._(
         family: CanonicalLegacyTrainingLaunchFamilyV1.pack,
         pack: pack,
         startIndex: startIndex,
         source: source,
         onSessionEnd: onSessionEnd,
       );

  const CanonicalLegacyTrainingLaunchInputV1.session({
    required TrainingSession session,
    int startIndex = 0,
    String? source,
    VoidCallback? onSessionEnd,
  }) : this._(
         family: CanonicalLegacyTrainingLaunchFamilyV1.session,
         session: session,
         startIndex: startIndex,
         source: source,
         onSessionEnd: onSessionEnd,
       );

  final CanonicalLegacyTrainingLaunchFamilyV1 family;
  final TrainingPackV2? pack;
  final TrainingSession? session;
  final int startIndex;
  final String? source;
  final VoidCallback? onSessionEnd;

  bool get launchesPack => family == CanonicalLegacyTrainingLaunchFamilyV1.pack;

  bool get launchesSession =>
      family == CanonicalLegacyTrainingLaunchFamilyV1.session;
}

TrainingSessionScreen buildCanonicalLegacyTrainingScreenV1(
  CanonicalLegacyTrainingLaunchInputV1 input,
) {
  return TrainingSessionScreen(
    pack: input.pack,
    session: input.session,
    startIndex: input.startIndex,
    source: input.source,
    onSessionEnd: input.onSessionEnd,
  );
}

Route<T> canonicalLegacyTrainingRouteV1<T>({
  required CanonicalLegacyTrainingLaunchInputV1 input,
}) {
  return MaterialPageRoute<T>(
    builder: (_) => buildCanonicalLegacyTrainingScreenV1(input),
  );
}

Future<T?> pushCanonicalLegacyTrainingV1<T>(
  BuildContext context, {
  required CanonicalLegacyTrainingLaunchInputV1 input,
}) async {
  if (!context.mounted) return null;
  return Navigator.of(
    context,
  ).push<T>(canonicalLegacyTrainingRouteV1<T>(input: input));
}

Future<T?> pushReplacementCanonicalLegacyTrainingV1<T, TO>(
  BuildContext context, {
  required CanonicalLegacyTrainingLaunchInputV1 input,
}) async {
  if (!context.mounted) return null;
  return Navigator.of(
    context,
  ).pushReplacement<T, TO>(canonicalLegacyTrainingRouteV1<T>(input: input));
}
