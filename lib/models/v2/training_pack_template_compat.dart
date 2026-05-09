library training_pack_template_compat;

import 'dart:core';

import 'training_pack_template_v2.dart';
import 'dart:core' as core;

extension TrainingPackTemplateLegacyCompat on TrainingPackTemplateV2 {
  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.String? get slug => null;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  set slug(core.String? value) {}

  @core.Deprecated('Migrate to V2 stack model')
  core.int? get heroBbStack => null;

  @core.Deprecated('Migrate to V2 positions model')
  core.Object? get heroPos => positions.isNotEmpty ? positions.first : null;

  @core.Deprecated('Migrate to V2 positions model')
  set heroPos(core.Object? value) {}

  @core.Deprecated('Migrate to V2 stacks model')
  core.List<core.int>? get playerStacksBb => null;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.List<core.String>? get heroRange => null;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.List<core.Object?> get focusTags => const <core.Object?>[];

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.List<core.Object?> get focusHandTypes => const <core.Object?>[];

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.List<core.Object?> get requiredBoardClusters => const <core.Object?>[];

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.List<core.Object?> get excludedBoardClusters => const <core.Object?>[];

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.String? get difficulty => null;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.int get bbCallPct => 0;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.int get anteBb => 0;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.double? get minEvForCorrect => null;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.bool get goalAchieved => false;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  set goalAchieved(core.bool value) {}

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.int get goalTarget => 0;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.int get goalProgress => 0;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  set goalProgress(core.int value) {}

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  set goalTarget(core.int value) {}

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.bool get isDraft => false;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  set isDraft(core.bool value) {}

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.bool get isBuiltIn => false;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  set isBuiltIn(core.bool value) {}

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.String? get png => null;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.bool get isFavorite => false;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  set isFavorite(core.bool value) {}

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.bool get isPinned => false;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  set isPinned(core.bool value) {}

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.bool get trending => false;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.bool get isPlayable => false;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.int get spotCount => 0;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.int get totalSpots => 0;

  @core.Deprecated('Migrate to V2 variants API')
  core.List<core.Object?> playableVariants({
    core.bool groupByPosition = false,
  }) => const <core.Object?>[];

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  void ensurePlayableVariants() {}

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.bool hasPlayableVariants() => false;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.String? firstPlayableVariant() => null;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.String? variantById(core.String? id) => null;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.Map<core.String, core.Object?> toJson() =>
      const <core.String, core.Object?>{};

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.Object? asPack() => null;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.Object? toPack() => null;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.bool hasPlayableContent() => false;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.String posRangeLabel() => '';

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.String handTypeSummary([core.Object? spot]) => '';

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.DateTime? get updatedDate => null;

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.List<core.int> streetTotals([core.Object? _]) => const <core.int>[
    0,
    0,
    0,
    0,
  ];

  @core.Deprecated('Migrate to TrainingPackTemplateV2 API')
  core.List<core.int> streetCovered([core.Object? _]) => const <core.int>[
    0,
    0,
    0,
    0,
  ];

  @core.Deprecated('Migrate to V2 copy semantics')
  TrainingPackTemplateV2 copyWith({
    core.String? id,
    core.String? slug,
    core.String? name,
    core.String? description,
    core.String? goal,
    core.String? category,
    core.int? streetGoal,
    core.String? targetStreet,
    core.int? heroBbStack,
    core.Object? heroPos,
    core.List<core.int>? playerStacksBb,
    core.List<core.Object?>? playableVariants,
    core.List<core.Object?>? spots,
  }) => this;
}
