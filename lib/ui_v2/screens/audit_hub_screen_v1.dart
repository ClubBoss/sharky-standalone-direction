import 'dart:io';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/audit_hub_v1/audit_hub_operational_builder_v1.dart';
import 'package:poker_analyzer/audit_hub_v1/audit_hub_operational_models_v1.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const _auditHubSnapshotPathV1 = 'assets/audit_hub_v1/operational_snapshot.json';

Route<void> auditHubRouteV1() {
  return MaterialPageRoute<void>(
    builder: (_) => const AuditHubScreenV1(),
  );
}

class AuditHubScreenV1 extends StatefulWidget {
  const AuditHubScreenV1({super.key});

  @override
  State<AuditHubScreenV1> createState() => _AuditHubScreenV1State();
}

class _AuditHubScreenV1State extends State<AuditHubScreenV1> {
  late Future<AuditHubOperationalDashboardV1> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<AuditHubOperationalDashboardV1> _loadDashboard() async {
    if (!File(_auditHubSnapshotPathV1).existsSync()) {
      throw StateError(
        'Audit Hub snapshot not found at $_auditHubSnapshotPathV1. '
        'Run `dart run tools/audit_hub_refresh_v1.dart` first.',
      );
    }
    return readAuditHubOperationalDashboardFromSnapshotFileV1(
      _auditHubSnapshotPathV1,
    );
  }

  void _reload() {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: SharkyTokensV1.textPrimary,
        elevation: 0,
        title: const Text('Audit Hub v1'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reload snapshot',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<AuditHubOperationalDashboardV1>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  '${snapshot.error}',
                  style: AppTypography.body.copyWith(
                    color: SharkyTokensV1.textPrimary,
                  ),
                ),
              ),
            );
          }
          final dashboard = snapshot.requireData;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              _SectionCardV1(
                title: 'Canonical Readiness (SSOT)',
                subtitle:
                    'These values come directly from the readiness SSOT and are not mutated by the hub.',
                child: _CanonicalReadinessViewV1(
                  readiness: dashboard.canonicalReadiness,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionCardV1(
                title: 'Readiness Recalibration Candidate',
                subtitle:
                    'Live truth may justify a recalibration wave, but it does not silently change canonical percentages.',
                child: _RecalibrationCandidateViewV1(
                  candidate: dashboard.recalibrationCandidate,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCardV1 extends StatelessWidget {
  const _SectionCardV1({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SharkyTokensV1.slate600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppTypography.h3.copyWith(
              color: SharkyTokensV1.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.body.copyWith(
              color: SharkyTokensV1.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _CanonicalReadinessViewV1 extends StatelessWidget {
  const _CanonicalReadinessViewV1({required this.readiness});

  final CanonicalReadinessV1 readiness;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _kv('Source SSOT', readiness.sourceSsotPath),
        _kv('Core Product Readiness', '${readiness.coreReadinessPercent.toStringAsFixed(1)} / 100'),
        _kv('Ship / Distribution Readiness', '${readiness.shipReadinessPercent.toStringAsFixed(1)} / 100'),
        _kv('Final Product Readiness', '${readiness.finalReadinessPercent.toStringAsFixed(1)} / 100'),
        _kv('Top bottleneck block', readiness.topBottleneckBlock),
        _kv('Top bottleneck epic', readiness.topBottleneckEpic),
        _kv('Confidence note', readiness.confidenceNote),
      ],
    );
  }
}

class _RecalibrationCandidateViewV1 extends StatelessWidget {
  const _RecalibrationCandidateViewV1({required this.candidate});

  final ReadinessRecalibrationCandidateV1 candidate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _kv('Canonical readiness source path', candidate.canonicalReadinessSourcePath),
        _kv('Status', candidate.status.wireValue),
        _kv(
          'Canonical scores',
          'Core ${candidate.canonicalReadiness.coreReadinessPercent.toStringAsFixed(1)} | Ship ${candidate.canonicalReadiness.shipReadinessPercent.toStringAsFixed(1)} | Final ${candidate.canonicalReadiness.finalReadinessPercent.toStringAsFixed(1)}',
        ),
        _kv(
          'Candidate score deltas',
          'Core ${candidate.candidateScoreDeltas.coreDelta.toStringAsFixed(1)}, Ship ${candidate.candidateScoreDeltas.shipDelta.toStringAsFixed(1)}, Final ${candidate.candidateScoreDeltas.finalDelta.toStringAsFixed(1)}',
        ),
        _kv(
          'Recalibration justified now',
          candidate.recalibrationJustifiedNow ? 'yes' : 'no',
        ),
        _kv('Recalibration reason', candidate.recalibrationReason),
        _kv('Raw vs effective note', candidate.rawVsEffectiveNote),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Candidate Block Movements',
          style: AppTypography.body.copyWith(
            color: SharkyTokensV1.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (candidate.candidateBlockMovements.isEmpty)
          _emptyRow('No justified readiness change')
        else
          ...candidate.candidateBlockMovements.map(_buildBlockMovement),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Candidate Epic Movements',
          style: AppTypography.body.copyWith(
            color: SharkyTokensV1.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (candidate.candidateEpicMovements.isEmpty)
          _emptyRow('No justified readiness change')
        else
          ...candidate.candidateEpicMovements.map(_buildEpicMovement),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Proof Gaps If Not Justified',
          style: AppTypography.body.copyWith(
            color: SharkyTokensV1.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (candidate.proofGapsIfNotJustified.isEmpty)
          _emptyRow('None')
        else
          ...candidate.proofGapsIfNotJustified.map(_buildProofGap),
      ],
    );
  }

  Widget _buildBlockMovement(CandidateBlockMovementV1 movement) {
    return _structuredRow(
      title: '${movement.blockId} ${movement.blockTitle}',
      lines: <String>[
        'raw ${movement.rawScoreBefore.toStringAsFixed(2)} -> ${movement.rawScoreAfter.toStringAsFixed(2)}',
        'effective ${movement.effectiveScoreBefore.toStringAsFixed(2)} -> ${movement.effectiveScoreAfter.toStringAsFixed(2)}',
        if ((movement.effectiveCapReason ?? '').isNotEmpty)
          'cap: ${movement.effectiveCapReason}',
      ],
    );
  }

  Widget _buildEpicMovement(CandidateEpicMovementV1 movement) {
    return _structuredRow(
      title: '${movement.epicId} ${movement.direction.wireValue}',
      lines: <String>[
        '${movement.canonicalStatus.wireValue} -> ${movement.candidateStatus.wireValue}',
        movement.reason,
        if (movement.evidenceRefs.isNotEmpty)
          'evidence: ${movement.evidenceRefs.join(' | ')}',
      ],
    );
  }

  Widget _buildProofGap(String gap) => _structuredRow(title: gap, lines: const <String>[]);

  Widget _emptyRow(String label) => _structuredRow(title: label, lines: const <String>[]);
}

Widget _structuredRow({
  required String title,
  required List<String> lines,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SharkyTokensV1.slate600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppTypography.body.copyWith(
              color: SharkyTokensV1.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          for (final line in lines) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              line,
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textSecondary,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _kv(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: SharkyTokensV1.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.body.copyWith(
            color: SharkyTokensV1.textPrimary,
          ),
        ),
      ],
    ),
  );
}
