import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart'
    as campaign_registry;
import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart';
import 'package:poker_analyzer/core/training/library/training_pack_library_v2.dart';
import 'package:poker_analyzer/models/v2/training_pack_template.dart'
    as runtime_template;
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/screens/v2/training_pack_play_screen.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:poker_analyzer/ui_v2/ui_v2_beta_shell.dart';
import 'package:poker_analyzer/ui_v2/screens/audit_hub_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

import '../components/design_launcher_tile.dart';
import '../components/design_panel.dart';

enum ModuleLauncherBranch { cash, mtt }

class _BranchPackEntry {
  const _BranchPackEntry(this.id, this.title, this.subtitle);

  final String id;
  final String title;
  final String subtitle;
}

const List<_BranchPackEntry> _cashBranchPacks = <_BranchPackEntry>[
  _BranchPackEntry('cash:l3:v1', 'Cash L3 Core', 'Branch progression session'),
];

const List<_BranchPackEntry> _mttBranchPacks = <_BranchPackEntry>[
  _BranchPackEntry('mtt:l4:v1', 'MTT L4 Core', 'Branch progression session'),
];

class CanonicalDevHubNodeEntryV1 {
  const CanonicalDevHubNodeEntryV1({
    required this.packId,
    required this.nodeTitle,
    required this.world,
    required this.lessonNumber,
    required this.maxHandIndex,
    required this.hostType,
    required this.modeFamily,
    required this.status,
    required this.skeletonReadiness,
    required this.launchesSessionDrill,
  });

  final String packId;
  final String nodeTitle;
  final int world;
  final int lessonNumber;
  final int maxHandIndex;
  final String hostType;
  final String modeFamily;
  final CanonicalTruthStatusV1 status;
  final CanonicalTruthSkeletonReadinessV1 skeletonReadiness;
  final bool launchesSessionDrill;
}

class CanonicalDevHubWorldEntryV1 {
  const CanonicalDevHubWorldEntryV1({required this.world, required this.nodes});

  final int world;
  final List<CanonicalDevHubNodeEntryV1> nodes;
}

String _canonicalDevHubHostTypeLabelV1(
  CanonicalTruthHostSurfaceV1 hostSurface,
) {
  switch (hostSurface) {
    case CanonicalTruthHostSurfaceV1.world1FoundationsRunner:
      return 'Campaign Runner';
    case CanonicalTruthHostSurfaceV1.sessionDrillPlayer:
      return 'Session Player';
  }
}

String _canonicalDevHubModeFamilyLabelV1(
  CanonicalTruthModeFamilyV1 modeFamily,
) {
  switch (modeFamily) {
    case CanonicalTruthModeFamilyV1.seatQuiz:
      return 'seat_quiz';
    case CanonicalTruthModeFamilyV1.campaignSpine:
      return 'campaign_spine';
    case CanonicalTruthModeFamilyV1.sessionDrillSingleStep:
      return 'session_drill';
    case CanonicalTruthModeFamilyV1.handChain:
      return 'hand_chain';
  }
}

String _canonicalDevHubStatusLabelV1(CanonicalTruthStatusV1 status) {
  switch (status) {
    case CanonicalTruthStatusV1.productionLive:
      return 'production_live';
    case CanonicalTruthStatusV1.pilotLive:
      return 'pilot_live';
    case CanonicalTruthStatusV1.placeholder:
      return 'placeholder';
    case CanonicalTruthStatusV1.scaffold:
      return 'scaffold';
    case CanonicalTruthStatusV1.legacy:
      return 'legacy';
    case CanonicalTruthStatusV1.devOnly:
      return 'dev_only';
    case CanonicalTruthStatusV1.productionLiveModernized:
      return 'production_live_modernized';
    case CanonicalTruthStatusV1.productionLiveLegacy:
      return 'production_live_legacy';
  }
}

String _canonicalDevHubSkeletonReadinessLabelV1(
  CanonicalTruthSkeletonReadinessV1 readiness,
) {
  switch (readiness) {
    case CanonicalTruthSkeletonReadinessV1.representedReady:
      return 'represented_ready';
    case CanonicalTruthSkeletonReadinessV1.needsSkeletonShell:
      return 'needs_skeleton_shell';
  }
}

Color _canonicalDevHubStatusColorV1(CanonicalTruthStatusV1 status) {
  switch (status) {
    case CanonicalTruthStatusV1.productionLive:
      return Colors.greenAccent.shade100;
    case CanonicalTruthStatusV1.pilotLive:
      return Colors.lightBlueAccent.shade100;
    case CanonicalTruthStatusV1.placeholder:
      return Colors.orangeAccent.shade100;
    case CanonicalTruthStatusV1.scaffold:
      return Colors.amberAccent.shade100;
    case CanonicalTruthStatusV1.legacy:
      return Colors.redAccent.shade100;
    case CanonicalTruthStatusV1.devOnly:
      return Colors.purpleAccent.shade100;
    case CanonicalTruthStatusV1.productionLiveModernized:
      return Colors.tealAccent.shade100;
    case CanonicalTruthStatusV1.productionLiveLegacy:
      return Colors.deepOrangeAccent.shade100;
  }
}

String _canonicalDevHubNodeTitleForPackV1({
  required String packId,
  required int world,
  required int lessonNumber,
}) {
  final normalized = packId.trim().toLowerCase();
  if (normalized.contains('table_literacy')) {
    return 'Table Basics';
  }
  if (normalized.contains('action_literacy')) {
    return 'Action Order';
  }
  if (normalized.contains('street_flow')) {
    return 'Street Flow';
  }
  if (normalized.contains('followup_v1_b0')) {
    return 'Practice 1';
  }
  if (normalized.contains('followup_v1_b1')) {
    return 'Practice 2';
  }
  if (normalized.contains('followup_v1_b2')) {
    return 'Practice 3';
  }
  if (normalized.contains('spine_campaign_v1')) {
    return recommendedModuleTitleForId(packId);
  }
  return 'World $world Lesson $lessonNumber';
}

String _canonicalDevHubNodeTitleForSessionV1(String sessionId) {
  switch (sessionId.trim().toLowerCase()) {
    case 'w2.s01':
      return 'Showdown Comparison';
    case 'w2.s02':
      return 'Position Thinking';
    case 'w2.s03':
      return 'Initiative / Aggressor';
    case 'w2.s04':
      return 'Board Texture';
    case 'w2.s05':
      return 'World 2 Review';
    case 'w2.s06':
      return 'Outs Counting';
    case 'w2.s07':
      return 'Position -> Initiative';
    case 'w2.s08':
      return 'Texture -> Outs';
    case 'w2.s09':
      return 'Position -> Initiative -> Texture';
    case 'w2.s10':
      return 'Texture -> Outs -> Action';
    case 'w2.s11':
      return 'Position -> Initiative -> Action';
    case 'w2.s12':
      return 'World 2 Capstone';
    case 'w2.s13':
      return 'Continue Intuition';
    case 'w2.s14':
      return 'Fold Intuition';
    case 'w3.s11':
      return 'Preflop Framework Intro';
    case 'w3.s12':
      return 'Preflop Continue vs Fold';
    case 'w3.s13':
      return 'Preflop Open vs Fold';
    case 'w3.s14':
      return 'Position-Sensitive Open vs Fold';
  }
  return sessionId;
}

String _worldLaunchShapeSummaryV1(CanonicalDevHubWorldEntryV1 worldEntry) {
  final sessionHostCount = worldEntry.nodes
      .where((node) => node.launchesSessionDrill)
      .length;
  final campaignHostCount = worldEntry.nodes.length - sessionHostCount;
  if (sessionHostCount > 1 && campaignHostCount == 0) {
    return '$sessionHostCount session-host nodes · grouped family slice';
  }
  if (sessionHostCount == 1 && campaignHostCount == 0) {
    return '1 session-host node · single live pilot';
  }
  if (sessionHostCount > 0 && campaignHostCount > 0) {
    return '$campaignHostCount campaign nodes · $sessionHostCount session-host nodes';
  }
  return '$campaignHostCount campaign nodes';
}

List<CanonicalDevHubWorldEntryV1> debugCanonicalDevHubWorldEntriesV1() {
  final worlds = canonicalTruthWorldEntriesV1();
  return worlds
      .map((worldEntry) {
        final campaignNodes = List<CanonicalDevHubNodeEntryV1>.generate(
          worldEntry.nodes.length,
          (index) => CanonicalDevHubNodeEntryV1(
            packId: worldEntry.nodes[index].packId,
            nodeTitle: _canonicalDevHubNodeTitleForPackV1(
              packId: worldEntry.nodes[index].packId,
              world: worldEntry.world,
              lessonNumber: index + 1,
            ),
            world: worldEntry.world,
            lessonNumber: index + 1,
            maxHandIndex:
                (campaign_registry.campaignHandCountForPackIdV1(
                          worldEntry.nodes[index].packId,
                        ) -
                        1)
                    .clamp(0, 9999),
            hostType: _canonicalDevHubHostTypeLabelV1(
              worldEntry.nodes[index].hostSurface,
            ),
            modeFamily: _canonicalDevHubModeFamilyLabelV1(
              worldEntry.nodes[index].modeFamily,
            ),
            status: worldEntry.nodes[index].status,
            skeletonReadiness: worldEntry.nodes[index].skeletonReadiness,
            launchesSessionDrill: false,
          ),
          growable: false,
        );
        final sessionEntries = canonicalTruthPlayableSessionEntriesForWorldV1(
          worldEntry.world,
        );
        final sessionNodes = List<CanonicalDevHubNodeEntryV1>.generate(
          sessionEntries.length,
          (index) => CanonicalDevHubNodeEntryV1(
            packId: sessionEntries[index].sessionId,
            nodeTitle: _canonicalDevHubNodeTitleForSessionV1(
              sessionEntries[index].sessionId,
            ),
            world: worldEntry.world,
            lessonNumber: campaignNodes.length + index + 1,
            maxHandIndex: 0,
            hostType: _canonicalDevHubHostTypeLabelV1(
              sessionEntries[index].hostSurface,
            ),
            modeFamily: _canonicalDevHubModeFamilyLabelV1(
              sessionEntries[index].modeFamily,
            ),
            status: sessionEntries[index].status,
            skeletonReadiness: sessionEntries[index].skeletonReadiness,
            launchesSessionDrill: true,
          ),
          growable: false,
        );
        final preferPlayableSessionsOnly =
            worldEntry.world > 1 && sessionNodes.isNotEmpty;
        return CanonicalDevHubWorldEntryV1(
          world: worldEntry.world,
          nodes: List<CanonicalDevHubNodeEntryV1>.unmodifiable(
            preferPlayableSessionsOnly
                ? sessionNodes
                : <CanonicalDevHubNodeEntryV1>[
                    ...campaignNodes,
                    ...sessionNodes,
                  ],
          ),
        );
      })
      .toList(growable: false);
}

class _CanonicalDevAccessHubScreenV1 extends StatefulWidget {
  const _CanonicalDevAccessHubScreenV1();

  @override
  State<_CanonicalDevAccessHubScreenV1> createState() =>
      _CanonicalDevAccessHubScreenV1State();
}

class _CanonicalDevAccessHubScreenV1State
    extends State<_CanonicalDevAccessHubScreenV1> {
  late final TextEditingController _stepIndexControllerV1;
  bool _resettingProgressV1 = false;

  @override
  void initState() {
    super.initState();
    _stepIndexControllerV1 = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _stepIndexControllerV1.dispose();
    super.dispose();
  }

  int _requestedStepIndexV1() {
    final parsed = int.tryParse(_stepIndexControllerV1.text.trim());
    if (parsed == null || parsed < 0) {
      return 0;
    }
    return parsed;
  }

  Future<void> _resetProgressAndReturnToCanonicalPathV1() async {
    if (_resettingProgressV1) return;
    setState(() => _resettingProgressV1 = true);
    try {
      await ProgressService.resetSpineProgressV1();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => buildCanonicalPathRootV1()),
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() => _resettingProgressV1 = false);
      }
    }
  }

  String _worldStatusSummaryV1(CanonicalDevHubWorldEntryV1 worldEntry) {
    final counts = <CanonicalTruthStatusV1, int>{};
    for (final node in worldEntry.nodes) {
      counts.update(node.status, (value) => value + 1, ifAbsent: () => 1);
    }
    final orderedStatuses = CanonicalTruthStatusV1.values.where(
      counts.containsKey,
    );
    return orderedStatuses
        .map(
          (status) =>
              '${counts[status]} ${_canonicalDevHubStatusLabelV1(status)}',
        )
        .join(' · ');
  }

  String _worldSkeletonGapSummaryV1(CanonicalDevHubWorldEntryV1 worldEntry) {
    final counts = <CanonicalTruthSkeletonReadinessV1, int>{};
    for (final node in worldEntry.nodes) {
      counts.update(
        node.skeletonReadiness,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    final orderedReadiness = CanonicalTruthSkeletonReadinessV1.values.where(
      counts.containsKey,
    );
    return orderedReadiness
        .map(
          (readiness) =>
              '${counts[readiness]} ${_canonicalDevHubSkeletonReadinessLabelV1(readiness)}',
        )
        .join(' · ');
  }

  Future<void> _launchCampaignNode(
    BuildContext context,
    CanonicalDevHubNodeEntryV1 entry,
  ) async {
    if (entry.launchesSessionDrill) {
      await Navigator.of(
        context,
      ).push<void>(canonicalSessionDrillRouteV1(sessionId: entry.packId));
      return;
    }
    final startHandIndex = _requestedStepIndexV1().clamp(0, entry.maxHandIndex);
    await pushWorld1FoundationsRunnerV1<void>(
      context,
      moduleId: entry.packId,
      moduleTitle: recommendedModuleTitleForId(entry.packId),
      mode: kWorld1RunnerModeCampaignSpine,
      startHandIndex: startHandIndex,
    );
  }

  Widget _buildNodeStatusChipV1(CanonicalDevHubNodeEntryV1 entry) {
    return Container(
      key: Key('canonical_dev_hub_status_${entry.packId}_v1'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _canonicalDevHubStatusColorV1(entry.status).withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _canonicalDevHubStatusColorV1(entry.status).withOpacity(0.55),
        ),
      ),
      child: Text(
        _canonicalDevHubStatusLabelV1(entry.status),
        style: AppTypography.caption.copyWith(
          color: SharkyTokensV1.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCanonicalNodeTileV1(
    BuildContext context,
    CanonicalDevHubNodeEntryV1 entry,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('canonical_dev_hub_launch_${entry.packId}_v1'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => _launchCampaignNode(context, entry),
        child: Container(
          decoration: BoxDecoration(
            color: SharkyTokensV1.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SharkyTokensV1.slate600.withOpacity(0.45),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.developer_mode_outlined,
                color: SharkyTokensV1.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.nodeTitle,
                          style: AppTypography.h3.copyWith(
                            color: SharkyTokensV1.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildNodeStatusChipV1(entry),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      entry.launchesSessionDrill
                          ? '${entry.packId} · authored session flow'
                          : '${entry.packId} · i=0-${entry.maxHandIndex}',
                      style: AppTypography.caption.copyWith(
                        color: SharkyTokensV1.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Text(
                          entry.hostType,
                          key: Key('canonical_dev_hub_host_${entry.packId}_v1'),
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '·',
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textSecondary,
                          ),
                        ),
                        Text(
                          entry.modeFamily,
                          key: Key('canonical_dev_hub_mode_${entry.packId}_v1'),
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _canonicalDevHubSkeletonReadinessLabelV1(
                        entry.skeletonReadiness,
                      ),
                      key: Key('canonical_dev_hub_gap_${entry.packId}_v1'),
                      style: AppTypography.caption.copyWith(
                        color: SharkyTokensV1.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepTargetCardV1() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Launch Step Index',
            key: const Key('canonical_dev_hub_step_target_label_v1'),
            style: AppTypography.h3.copyWith(
              color: SharkyTokensV1.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Applies to every launch and clamps to the real pack length.',
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: 140,
            child: TextField(
              key: const Key('canonical_dev_hub_step_target_input_v1'),
              controller: _stepIndexControllerV1,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'handIndex',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostTruthCardV1() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Host Truth',
            key: const Key('canonical_dev_hub_host_truth_label_v1'),
            style: AppTypography.h3.copyWith(
              color: SharkyTokensV1.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Campaign Runner and Session Player are intentional staged host families.',
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Worlds without explicit playable-session truth still use Campaign Runner. Explicit playable-session entries use Session Player.',
            key: const Key('canonical_dev_hub_host_truth_body_v1'),
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetProgressCardV1() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reset Progress',
            style: AppTypography.h3.copyWith(
              color: SharkyTokensV1.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Clears spine progress and returns to the canonical map root.',
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              key: const Key('canonical_dev_hub_reset_progress_v1'),
              onPressed: _resettingProgressV1
                  ? null
                  : _resetProgressAndReturnToCanonicalPathV1,
              child: Text(
                _resettingProgressV1 ? 'RESETTING...' : 'RESET PROGRESS',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final worlds = debugCanonicalDevHubWorldEntriesV1();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: SharkyTokensV1.textPrimary,
        title: const Text('Canonical Dev Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildResetProgressCardV1(),
          const SizedBox(height: AppSpacing.lg),
          _buildHostTruthCardV1(),
          const SizedBox(height: AppSpacing.lg),
          _buildStepTargetCardV1(),
          const SizedBox(height: AppSpacing.lg),
          for (final worldEntry in worlds) ...[
            Text(
              'World ${worldEntry.world}',
              key: Key('canonical_dev_hub_world_${worldEntry.world}_v1'),
              style: AppTypography.h3.copyWith(
                color: SharkyTokensV1.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _worldStatusSummaryV1(worldEntry),
              key: Key(
                'canonical_dev_hub_world_summary_${worldEntry.world}_v1',
              ),
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _worldLaunchShapeSummaryV1(worldEntry),
              key: Key('canonical_dev_hub_world_shape_${worldEntry.world}_v1'),
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _worldSkeletonGapSummaryV1(worldEntry),
              key: Key(
                'canonical_dev_hub_world_gap_summary_${worldEntry.world}_v1',
              ),
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < worldEntry.nodes.length; i++) ...[
              _buildCanonicalNodeTileV1(context, worldEntry.nodes[i]),
              if (i < worldEntry.nodes.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

Route<void> canonicalDevAccessHubRouteV1() {
  return MaterialPageRoute<void>(
    builder: (_) => const _CanonicalDevAccessHubScreenV1(),
  );
}

class ModuleLauncherScreen extends StatelessWidget {
  const ModuleLauncherScreen({super.key, this.branch});

  final ModuleLauncherBranch? branch;

  Future<void> _launchBranchPack(
    BuildContext context, {
    required String packId,
  }) async {
    var template = TrainingPackLibraryV2.instance.getById(packId);
    if (template == null) {
      await TrainingPackLibraryV2.instance.loadFromFolder();
      template = TrainingPackLibraryV2.instance.getById(packId);
    }
    if (template == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Pack unavailable: $packId')));
      return;
    }
    final runtimeTemplate = runtime_template.TrainingPackTemplate.fromJson(
      template.toJson(),
    );
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrainingPackPlayScreen(
          template: runtimeTemplate,
          original: runtimeTemplate,
        ),
        settings: RouteSettings(
          name: 'branch_launcher_${branch?.name ?? 'unknown'}',
        ),
      ),
    );
  }

  Widget _buildBranchProgression(BuildContext context) {
    final isCash = branch == ModuleLauncherBranch.cash;
    final title = isCash ? 'Cash Progression' : 'MTT Progression';
    final entries = isCash ? _cashBranchPacks : _mttBranchPacks;
    final branchTileKey = isCash
        ? const Key('cash_branch_entry_tile')
        : const Key('mtt_branch_entry_tile');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: DesignPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.h1.copyWith(
                    color: SharkyTokensV1.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (var i = 0; i < entries.length; i++) ...[
                  DesignLauncherTile(
                    key: i == 0 ? branchTileKey : Key('branch_pack_tile_$i'),
                    title: entries[i].title,
                    subtitle: entries[i].subtitle,
                    icon: Icons.play_circle_outline,
                    onTap: () =>
                        _launchBranchPack(context, packId: entries[i].id),
                  ),
                  if (i < entries.length - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (branch != null) {
      return _buildBranchProgression(context);
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: DesignPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Training Launcher',
                    style: AppTypography.h1.copyWith(
                      color: SharkyTokensV1.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DesignLauncherTile(
                    title: 'Cash Training',
                    subtitle: 'Improve stack work vs effective players',
                    icon: Icons.money,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DesignLauncherTile(
                    title: 'MTT Training',
                    subtitle: 'Endgame and tournament pacing drills',
                    icon: Icons.timeline,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DesignLauncherTile(
                    title: 'ICM Packs',
                    subtitle: 'Risk-adjusted pushes + folds',
                    icon: Icons.scale,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DesignLauncherTile(
                    title: 'Import / Paste Spots',
                    subtitle: 'Bring your own hands and examples',
                    icon: Icons.upload_file,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DesignLauncherTile(
                    title: 'Tools / Settings',
                    subtitle: 'Customization and utilities',
                    icon: Icons.settings,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FutureBuilder<List<String>>(
                    future: const DrillRuntimeAdapterV1()
                        .listSessionIdsWithDrillsV1(),
                    builder: (context, snapshot) {
                      final sessionIds = snapshot.data ?? const <String>[];
                      if (sessionIds.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session Drills',
                            style: AppTypography.h3.copyWith(
                              color: SharkyTokensV1.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          for (var i = 0; i < sessionIds.length; i++) ...[
                            DesignLauncherTile(
                              key: Key(
                                'session_drill_player_entry_${sessionIds[i]}_v1',
                              ),
                              title: sessionIds[i],
                              subtitle: 'Session drills',
                              icon: Icons.play_lesson_outlined,
                              onTap: () {
                                Navigator.of(context).push(
                                  canonicalSessionDrillRouteV1(
                                    sessionId: sessionIds[i],
                                  ),
                                );
                              },
                            ),
                            if (i < sessionIds.length - 1)
                              const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      );
                    },
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Developer Tools',
                      style: AppTypography.h3.copyWith(
                        color: SharkyTokensV1.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DesignLauncherTile(
                      key: const Key('canonical_dev_hub_entry_tile_v1'),
                      title: 'Canonical Dev Hub',
                      subtitle:
                          'Open real campaign nodes from production truth',
                      icon: Icons.hub_outlined,
                      onTap: () => Navigator.of(
                        context,
                      ).push(canonicalDevAccessHubRouteV1()),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DesignLauncherTile(
                      key: const Key('audit_hub_entry_tile_v1'),
                      title: 'Audit Hub v1',
                      subtitle:
                          'Inspect canonical readiness and recalibration candidate truth',
                      icon: Icons.monitor_heart_outlined,
                      onTap: () => Navigator.of(context).push(auditHubRouteV1()),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
