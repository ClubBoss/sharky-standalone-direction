const List<String> activeAct0LearnerCopyOwnersV1 = <String>[
  'lib/ui_v2/act0_shell/act0_home_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_play_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_review_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_profile_shell_v1.dart',
  'lib/ui_v2/act0_shell/act0_premium_preview_v1.dart',
  'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
];

const List<String> legacyDormantCopyExclusionRootsV1 = <String>[
  'lib/ui_v2/persona/',
  'lib/ui_v2/ai_coach/',
  'lib/ui_v2/ui_v2_premium_hub.dart',
  'lib/payments/',
  'lib/services/premium_service.dart',
  'lib/services/trial_service_v1.dart',
  'lib/services/subscription_status_v1.dart',
];

const List<String> _forbiddenValueBeforePaywallPhrasesV1 = <String>[
  'unlock w13',
  'upgrade to continue',
  'premium specialization',
  'start your trial',
  'subscribe',
  'purchase',
  'restore purchase',
  'paid depth available now',
  'full cash/mtt tracks',
  'ai fixes your leaks',
  'ai adapts your leaks',
  'mastery path live',
  'become pro',
  'complete volume i now',
  'limited time',
  'ends today',
  'last chance',
  'only today',
  'countdown',
];

List<String> forbiddenValueBeforePaywallFindingsV1(String source) {
  final normalized = source.toLowerCase();
  return <String>[
    for (final phrase in _forbiddenValueBeforePaywallPhrasesV1)
      if (normalized.contains(phrase)) phrase,
  ];
}
