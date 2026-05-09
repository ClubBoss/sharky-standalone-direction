import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/services/outcome_summary_v1.dart';

enum FocusRecommendationKindV1 {
  continueCampaign,
  reviewFocus,
  repeatPack,
  nextModule,
  backToMap,
  none,
}

class FocusRecommendationV1 {
  const FocusRecommendationV1({
    required this.kind,
    required this.reason,
    required this.priority,
  });

  final FocusRecommendationKindV1 kind;
  final String reason;

  /// Higher number means stronger recommendation priority.
  final int priority;

  @override
  bool operator ==(Object other) {
    return other is FocusRecommendationV1 &&
        other.kind == kind &&
        other.reason == reason &&
        other.priority == priority;
  }

  @override
  int get hashCode => Object.hash(kind, reason, priority);

  @override
  String toString() =>
      'FocusRecommendationV1(kind: $kind, reason: $reason, priority: $priority)';
}

class FocusRecommendationInputsV1 {
  const FocusRecommendationInputsV1({
    required this.isCampaignSession,
    required this.focusReviewDue,
    this.focusLabel,
    this.campaignOutcomeSummary,
    this.campaignPersonalizationHint,
    this.personalizationResultV1,
    this.topErrorBuckets = const <MapEntry<String, int>>[],
  });

  final bool isCampaignSession;
  final bool focusReviewDue;
  final String? focusLabel;
  final OutcomeSummaryV1? campaignOutcomeSummary;
  final String? campaignPersonalizationHint;
  final PersonalizedRecommendationV1? personalizationResultV1;
  final Iterable<MapEntry<String, int>> topErrorBuckets;
}

class FocusRecommendationRouterV1 {
  FocusRecommendationRouterV1._();

  static const int priorityFocusReviewDue = 500;
  static const int priorityRepeatPack = 400;
  static const int priorityTopLeak = 300;
  static const int priorityContinueCampaign = 200;
  static const int priorityNextModule = 100;
  static const int priorityNone = 0;
  static const int priorityPersonalizedRepeatPack = 425;
  static const int priorityPersonalizedReviewFocus = 350;
  static const int priorityPersonalizedContinue = 250;

  static FocusRecommendationV1 route(FocusRecommendationInputsV1 input) {
    if (input.focusReviewDue) {
      return const FocusRecommendationV1(
        kind: FocusRecommendationKindV1.reviewFocus,
        reason: 'Focus review due',
        priority: priorityFocusReviewDue,
      );
    }

    final personalizationResult = input.personalizationResultV1;
    if (personalizationResult != null) {
      return _routePersonalizationResult(personalizationResult);
    }

    final summary = input.campaignOutcomeSummary;
    final campaignHasMistake =
        summary != null && summary.outcomeKind == OutcomeKindV1.mistake;
    if (campaignHasMistake) {
      return const FocusRecommendationV1(
        kind: FocusRecommendationKindV1.repeatPack,
        reason: 'Fix recent mistakes',
        priority: priorityRepeatPack,
      );
    }

    final topBucket = _firstValidBucketLabel(input.topErrorBuckets);
    if (input.isCampaignSession && topBucket != null) {
      return FocusRecommendationV1(
        kind: FocusRecommendationKindV1.reviewFocus,
        reason: _clampAsciiReason('Top leak: $topBucket'),
        priority: priorityTopLeak,
      );
    }

    if (input.isCampaignSession) {
      return const FocusRecommendationV1(
        kind: FocusRecommendationKindV1.continueCampaign,
        reason: 'Continue campaign',
        priority: priorityContinueCampaign,
      );
    }

    return const FocusRecommendationV1(
      kind: FocusRecommendationKindV1.nextModule,
      reason: 'Continue',
      priority: priorityNextModule,
    );
  }

  static String? _firstValidBucketLabel(
    Iterable<MapEntry<String, int>> buckets,
  ) {
    for (final entry in buckets) {
      if (entry.value <= 0) continue;
      final normalized = entry.key.trim();
      if (normalized.isEmpty) continue;
      if (normalized.toLowerCase() == 'none') continue;
      return _asciiToken(normalized);
    }
    return null;
  }

  static String _asciiToken(String value) {
    final ascii = value.replaceAll(RegExp(r'[^ -~]'), '').trim();
    return ascii.isEmpty ? 'Logic' : ascii;
  }

  static String _clampAsciiReason(String value) {
    final ascii = value.replaceAll(RegExp(r'[^ -~]'), '').trim();
    if (ascii.length <= 32) return ascii;
    return ascii.substring(0, 32).trimRight();
  }

  static FocusRecommendationV1 _routePersonalizationResult(
    PersonalizedRecommendationV1 result,
  ) {
    final reason = _clampAsciiReason(
      _personalizedReasonSummary(result.shortHintText),
    );
    switch (result.recommendedNextAction) {
      case PersonalizedNextActionV1.reviewFocus:
        return FocusRecommendationV1(
          kind: FocusRecommendationKindV1.reviewFocus,
          reason: reason,
          priority: priorityPersonalizedReviewFocus,
        );
      case PersonalizedNextActionV1.repeatPack:
        return FocusRecommendationV1(
          kind: FocusRecommendationKindV1.repeatPack,
          reason: reason,
          priority: priorityPersonalizedRepeatPack,
        );
      case PersonalizedNextActionV1.continueCampaign:
        return FocusRecommendationV1(
          kind: FocusRecommendationKindV1.continueCampaign,
          reason: reason,
          priority: priorityPersonalizedContinue,
        );
      case PersonalizedNextActionV1.nextModule:
        return FocusRecommendationV1(
          kind: FocusRecommendationKindV1.nextModule,
          reason: reason,
          priority: priorityNextModule,
        );
    }
  }

  static String _personalizedReasonSummary(String hint) {
    final normalized = hint.trim();
    if (normalized.isEmpty) return normalized;
    final firstSentenceEnd = normalized.indexOf('.');
    if (firstSentenceEnd <= 0) {
      return normalized;
    }
    return normalized.substring(0, firstSentenceEnd).trim();
  }
}
