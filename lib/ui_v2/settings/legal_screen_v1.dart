import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/services/learning_path_progress_service.dart';
import 'package:poker_analyzer/services/learning_path_progress_snapshot_service.dart';
import 'package:poker_analyzer/services/training_session_fingerprint_logger_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/ui/settings/privacy_terms.dart';

class LegalScreenV1 extends StatefulWidget {
  const LegalScreenV1({
    super.key,
    this.progressService,
    this.snapshotService,
    this.sessionFingerprintService,
  });

  final LearningPathProgressService? progressService;
  final LearningPathProgressSnapshotService? snapshotService;
  final TrainingSessionFingerprintLoggerService? sessionFingerprintService;

  @visibleForTesting
  static LearningPathProgressService? overrideProgressService;

  @visibleForTesting
  static LearningPathProgressSnapshotService? overrideSnapshotService;

  @visibleForTesting
  static TrainingSessionFingerprintLoggerService?
  overrideSessionFingerprintService;

  @override
  State<LegalScreenV1> createState() => _LegalScreenV1State();
}

class _LegalScreenV1State extends State<LegalScreenV1> {
  late final LearningPathProgressService _progressService;
  late final LearningPathProgressSnapshotService _snapshotService;
  late final TrainingSessionFingerprintLoggerService _sessionFingerprintService;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _progressService =
        widget.progressService ??
        LegalScreenV1.overrideProgressService ??
        LearningPathProgressService.instance;
    _snapshotService =
        widget.snapshotService ??
        LegalScreenV1.overrideSnapshotService ??
        LearningPathProgressSnapshotService.instance;
    _sessionFingerprintService =
        widget.sessionFingerprintService ??
        LegalScreenV1.overrideSessionFingerprintService ??
        TrainingSessionFingerprintLoggerService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Telemetry.logEvent(TelemetryEvents.legalOpened, {'source': 'settings'});
    });
  }

  Future<void> _openPrivacyPolicy() async {
    Telemetry.logEvent(TelemetryEvents.privacyOpened, {
      'source': 'legal_screen',
    });
    if (!mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PrivacyScreen()));
  }

  Future<void> _openTermsOfUse() async {
    Telemetry.logEvent(TelemetryEvents.termsOpened, {'source': 'legal_screen'});
    if (!mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const TermsScreen()));
  }

  Future<void> _handlePolicyTap(Future<void> Function() action) async {
    await action();
  }

  Future<void> _confirmDelete() async {
    if (_isDeleting) return;
    Telemetry.logEvent(TelemetryEvents.deleteDataRequested, {
      'source': 'legal_screen',
    });
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.legalDeleteConfirmationTitle),
          content: Text(l10n.legalDeleteConfirmationBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    Telemetry.logEvent(TelemetryEvents.deleteDataConfirmed, {
      'source': 'legal_screen',
    });
    await _performDelete();
  }

  Future<void> _performDelete() async {
    setState(() => _isDeleting = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await Future.wait([
        _progressService.resetAll(),
        _snapshotService.deleteAllSnapshots(),
        _sessionFingerprintService.clear(),
      ]);
      Telemetry.logEvent(TelemetryEvents.deleteDataCompleted, {
        'source': 'legal_screen',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.legalDeleteSuccess)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.legalDeleteFailure)));
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brand = Theme.of(context).extension<BrandTheme>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.legalScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: brand?.primaryBrand ?? Colors.teal),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            _SectionLabel(title: l10n.legalPoliciesSectionTitle),
            const SizedBox(height: 12),
            _ActionTile(
              title: l10n.privacyPolicy,
              subtitle: l10n.privacyPolicySubtitle,
              icon: Icons.privacy_tip,
              onTap: () => _handlePolicyTap(_openPrivacyPolicy),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              title: l10n.termsOfUse,
              subtitle: l10n.termsOfUseSubtitle,
              icon: Icons.article,
              onTap: () => _handlePolicyTap(_openTermsOfUse),
            ),
            const SizedBox(height: 28),
            _SectionLabel(title: l10n.legalDataSectionTitle),
            const SizedBox(height: 12),
            _DeleteTile(
              title: l10n.legalDeleteDataTitle,
              subtitle: l10n.legalDeleteDataSubtitle,
              icon: Icons.delete_forever,
              isDeleting: _isDeleting,
              onTap: _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    return Text(
      title,
      style: AppTypography.h3.copyWith(
        fontWeight: brand?.fontWeightSemiBold ?? FontWeight.w600,
        color: brand?.textPrimary ?? AppColors.textPrimaryDark,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.02),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Icon(icon, color: brand?.primaryBrand ?? Colors.teal, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        fontWeight: brand?.fontWeightMedium ?? FontWeight.w500,
                        color: brand?.textPrimary ?? AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color:
                            brand?.textSecondary ?? AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new,
                color: brand?.textSecondary ?? AppColors.textSecondaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteTile extends StatelessWidget {
  const _DeleteTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.isDeleting,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDeleting ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.red.withOpacity(0.04),
            border: Border.all(color: Colors.red.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.redAccent, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        fontWeight: brand?.fontWeightMedium ?? FontWeight.w500,
                        color: brand?.textPrimary ?? AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color:
                            brand?.textSecondary ?? AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDeleting) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
