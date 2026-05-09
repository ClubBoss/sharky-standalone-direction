import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/v2/training_pack_template.dart' as tpl_v2;
import '../models/v2/training_pack_spot.dart';
import '../models/v2/hero_position.dart';
import '../models/v2/training_pack_template_v2.dart';
import '../screens/v2/training_pack_play_screen.dart';
import 'smart_resuggestion_engine.dart';
import 'session_log_service.dart';
import 'suggested_weak_tag_pack_service.dart' hide TrainingPackTemplateV2;
import 'dormant_tag_suggestion_service.dart';
import 'suggestion_cooldown_manager.dart';
import 'training_session_service.dart';
import 'suggestion_banner_ab_test_service.dart';
import 'learning_path_personalization_service.dart';
import 'suggested_training_packs_history_service.dart';
import 'user_action_logger.dart';

class SuggestionBannerData {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  SuggestionBannerData({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });
}

class _SuggestionBannerCandidate {
  final bool match;
  final Future<SuggestionBannerData?> Function() build;
  _SuggestionBannerCandidate(this.match, this.build);
}

class SuggestionBannerEngine {
  final SessionLogService logs;
  final SuggestedWeakTagPackService _weakTagService;
  final DormantTagSuggestionService _dormantService;
  final SmartReSuggestionEngine _resuggestionEngine;

  SuggestionBannerEngine({
    required this.logs,
    SuggestedWeakTagPackService? weakTagService,
    DormantTagSuggestionService? dormantService,
    SmartReSuggestionEngine? resuggestionEngine,
  }) : _weakTagService = weakTagService ?? SuggestedWeakTagPackService(),
       _dormantService = dormantService ?? DormantTagSuggestionService(),
       _resuggestionEngine =
           resuggestionEngine ?? SmartReSuggestionEngine(logs: logs);

  Future<bool> shouldShowBanner() async => true;

  Future<SuggestionBannerData?> getBanner() async {
    if (!await shouldShowBanner()) return null;

    final variant = SuggestionBannerABTestService.instance.getVariant();
    final isAggressive = variant == SuggestionBannerVariant.aggressiveText;
    final weakest = LearningPathPersonalizationService.instance
        .getWeakestTags(limit: 3)
        .map((e) => e.trim().toLowerCase())
        .toList();

    bool matches(TrainingPackTemplateV2? tpl) {
      if (tpl == null) return false;
      final tags = <String>{
        ...tpl.tags.map((e) => e.trim().toLowerCase()),
        if (tpl.category != null) tpl.category!.trim().toLowerCase(),
      }..removeWhere((e) => e.isEmpty);
      return tags.any(weakest.contains);
    }

    final weakPreview = await _weakTagService.suggestPack();
    final dormantPreview = await _dormantService.suggestPack();
    final resPreview = await _resuggestionEngine.previewNext();

    final matchWeak = matches(weakPreview.pack);
    final matchDormant = matches(dormantPreview);
    final matchResuggest = matches(resPreview);

    Future<SuggestionBannerData?> weakBanner(bool match) async {
      final tpl = weakPreview.pack;
      if (tpl == null) return null;
      await SuggestionCooldownManager.markSuggested(tpl.id);
      final data = _dataFor(
        tpl: tpl,
        title: isAggressive ? '🔥 Срочно укрепи базу' : '💡 Укрепи базу',
        buttonLabel: isAggressive ? 'Заняться' : 'Начать тренировку',
      );
      await UserActionLogger.instance.logEvent({
        'event': 'suggestion_banner.shown',
        'variant': variant.name,
        'type': 'weak',
        'match': match,
      });
      return data;
    }

    Future<SuggestionBannerData?> dormantBanner(bool match) async {
      final dormant = dormantPreview;
      if (dormant == null) return null;
      final data = _dataFor(
        tpl: dormant,
        title: isAggressive ? '⚡ Верни навык прямо сейчас' : '🔁 Освежи навык',
        buttonLabel: isAggressive ? 'Go!' : 'Начать тренировку',
      );
      await UserActionLogger.instance.logEvent({
        'event': 'suggestion_banner.shown',
        'variant': variant.name,
        'type': 'dormant',
        'match': match,
      });
      return data;
    }

    Future<SuggestionBannerData?> resuggestBanner(bool match) async {
      final re = resPreview;
      if (re == null) return null;
      await SuggestionCooldownManager.markSuggested(re.id);
      await SuggestedTrainingPacksHistoryService.logSuggestion(
        packId: re.id,
        source: 'resuggestion_engine',
      );
      final data = _dataFor(
        tpl: re,
        title: isAggressive ? '🚀 Продолжи обучение!' : '♻️ Продолжи обучение',
        buttonLabel: isAggressive ? 'Поехали' : 'Начать тренировку',
      );
      await UserActionLogger.instance.logEvent({
        'event': 'suggestion_banner.shown',
        'variant': variant.name,
        'type': 'resuggest',
        'match': match,
      });
      return data;
    }

    late final List<_SuggestionBannerCandidate> order;
    switch (variant) {
      case SuggestionBannerVariant.layoutA:
        order = [
          _SuggestionBannerCandidate(
            matchResuggest,
            () => resuggestBanner(matchResuggest),
          ),
          _SuggestionBannerCandidate(
            matchDormant,
            () => dormantBanner(matchDormant),
          ),
          _SuggestionBannerCandidate(matchWeak, () => weakBanner(matchWeak)),
        ];
        break;
      case SuggestionBannerVariant.layoutB:
        order = [
          _SuggestionBannerCandidate(
            matchDormant,
            () => dormantBanner(matchDormant),
          ),
          _SuggestionBannerCandidate(matchWeak, () => weakBanner(matchWeak)),
          _SuggestionBannerCandidate(
            matchResuggest,
            () => resuggestBanner(matchResuggest),
          ),
        ];
        break;
      default:
        order = [
          _SuggestionBannerCandidate(matchWeak, () => weakBanner(matchWeak)),
          _SuggestionBannerCandidate(
            matchDormant,
            () => dormantBanner(matchDormant),
          ),
          _SuggestionBannerCandidate(
            matchResuggest,
            () => resuggestBanner(matchResuggest),
          ),
        ];
    }

    order.sort((a, b) {
      if (a.match == b.match) return 0;
      return a.match ? -1 : 1;
    });

    for (final c in order) {
      final result = await c.build();
      if (result != null) return result;
    }

    return null;
  }

  tpl_v2.TrainingPackTemplate _runtimeTemplate(TrainingPackTemplateV2 pack) {
    final spots = <TrainingPackSpot>[
      for (final s in pack.spots) TrainingPackSpot.fromJson(s.toJson()),
    ];
    final heroSpot = spots.isNotEmpty ? spots.first : null;
    final heroKey = heroSpot?.hand.heroIndex.toString() ?? '0';
    final heroStack = heroSpot?.hand.stacks[heroKey]?.round() ?? 10;
    final stacks = heroSpot != null && heroSpot.hand.stacks.isNotEmpty
        ? heroSpot.hand.stacks.values.map((e) => e.round()).toList()
        : [heroStack, heroStack];
    final meta = Map<String, dynamic>.from(pack.meta);
    meta.putIfAbsent('origin', () => 'suggestion-banner');
    return tpl_v2.TrainingPackTemplate(
      id: pack.id,
      name: pack.name,
      description: pack.description,
      goal: pack.goal,
      category: pack.category ?? (pack.tags.isNotEmpty ? pack.tags.first : ''),
      gameType: pack.gameType,
      spots: spots,
      tags: List<String>.from(pack.tags),
      focusTags: const [],
      focusHandTypes: const [],
      requiredBoardClusters: const [],
      excludedBoardClusters: const [],
      difficulty: meta['difficulty']?.toString(),
      heroBbStack: heroStack,
      playerStacksBb: stacks,
      heroPos: heroSpot?.hand.position ?? HeroPosition.sb,
      spotCount: spots.length,
      bbCallPct: meta['bbCallPct'] is int ? meta['bbCallPct'] as int : 20,
      anteBb: heroSpot?.hand.anteBb ?? 0,
      minEvForCorrect: (meta['minEvForCorrect'] as num?)?.toDouble() ?? 0.01,
      heroRange: (meta['heroRange'] as List?)?.cast<String>(),
      createdAt: pack.created,
      meta: meta,
      recommended: pack.recommended,
    );
  }

  SuggestionBannerData _dataFor({
    required TrainingPackTemplateV2 tpl,
    required String title,
    String buttonLabel = 'Начать тренировку',
  }) => SuggestionBannerData(
    title: title,
    subtitle: 'Пак: ${tpl.name}',
    buttonLabel: buttonLabel,
    onTap: () async {
      final ctx = navigatorKey.currentContext;
      if (ctx == null) return;
      final runtime = _runtimeTemplate(tpl);
      await ctx.read<TrainingSessionService>().startSession(runtime);
      if (!ctx.mounted) return;
      await Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (_) =>
              TrainingPackPlayScreen(template: runtime, original: runtime),
        ),
      );
    },
  );
}
