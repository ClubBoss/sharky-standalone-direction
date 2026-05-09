import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/xp_milestone_service.dart';
import '../services/xp_service.dart';

/// Screen displaying XP milestone achievements with claim functionality.
///
/// Features:
/// - Grid of milestone cards (10, 50, 100, 250, 500, 1000 XP)
/// - Visual states: locked (grey), unlocked (colored + claimable), claimed (checkmark)
/// - Claim button triggers confetti-style feedback
/// - Consistent with XP badge/recap styling
class XpMilestoneScreen extends StatefulWidget {
  final XpService xpService;

  XpMilestoneScreen({super.key, required this.xpService});

  @override
  State<XpMilestoneScreen> createState() => _XpMilestoneScreenState();
}

class _XpMilestoneScreenState extends State<XpMilestoneScreen> {
  final XpMilestoneService _milestoneService = XpMilestoneService();
  Map<int, MilestoneStatus> _milestoneStatuses = {};
  int _totalXp = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMilestones();
  }

  Future<void> _loadMilestones() async {
    setState(() => _isLoading = true);

    await widget.xpService.initialize();
    _totalXp = widget.xpService.getTotalXp();

    final statuses = <int, MilestoneStatus>{};
    for (final milestone in XpMilestoneService.milestones) {
      statuses[milestone] = await _milestoneService.getMilestoneStatus(
        milestone,
        _totalXp,
      );
    }

    setState(() {
      _milestoneStatuses = statuses;
      _isLoading = false;
    });
  }

  Future<void> _claimMilestone(int value) async {
    await _milestoneService.markMilestoneClaimed(value);

    // Show confetti-style snackbar
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.amber),
              const SizedBox(width: 12),
              Text(l10n.xpMilestoneClaimedMessage(value)),
            ],
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Reload to update UI
    await _loadMilestones();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.xpMilestoneTitle), elevation: 2),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(l10n),
                  const SizedBox(height: 24),
                  _buildMilestoneGrid(l10n),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber[700], size: 32),
              const SizedBox(width: 12),
              Text(
                l10n.xpMilestoneHeaderTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.xpMilestoneTotalXp(_totalXp),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.xpMilestoneUnlockHint,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    ),
  );

  Widget _buildMilestoneGrid(AppLocalizations l10n) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
    ),
    itemCount: XpMilestoneService.milestones.length,
    itemBuilder: (context, index) {
      final milestone = XpMilestoneService.milestones[index];
      final status = _milestoneStatuses[milestone] ?? MilestoneStatus.locked;
      return _MilestoneCard(
        value: milestone,
        status: status,
        onClaim: () => _claimMilestone(milestone),
        l10n: l10n,
      );
    },
  );
}

/// Card widget for a single milestone.
class _MilestoneCard extends StatelessWidget {
  final int value;
  final MilestoneStatus status;
  final VoidCallback onClaim;
  final AppLocalizations l10n;

  const _MilestoneCard({
    required this.value,
    required this.status,
    required this.onClaim,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(l10n, status);

    return Card(
      elevation: status == MilestoneStatus.locked ? 1 : 3,
      color: config.backgroundColor,
      child: InkWell(
        onTap: status == MilestoneStatus.unlocked ? onClaim : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(config.icon, size: 48, color: config.iconColor),
              const SizedBox(height: 12),
              Text(
                '$value XP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: config.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                config.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: config.textColor.withValues(alpha: 0.8),
                ),
              ),
              if (status == MilestoneStatus.unlocked) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(l10n.xpMilestoneClaimButton),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _MilestoneConfig _getStatusConfig(
    AppLocalizations l10n,
    MilestoneStatus status,
  ) {
    switch (status) {
      case MilestoneStatus.locked:
        return _MilestoneConfig(
          icon: Icons.lock_outline,
          iconColor: Colors.grey[400]!,
          textColor: Colors.grey[600]!,
          backgroundColor: Colors.grey[200]!,
          label: l10n.xpMilestoneLockedLabel,
        );
      case MilestoneStatus.unlocked:
        return _MilestoneConfig(
          icon: Icons.star,
          iconColor: Colors.amber,
          textColor: Colors.black87,
          backgroundColor: Colors.amber[50]!,
          label: l10n.xpMilestoneUnlockedLabel,
        );
      case MilestoneStatus.claimed:
        return _MilestoneConfig(
          icon: Icons.check_circle,
          iconColor: Colors.green,
          textColor: Colors.black87,
          backgroundColor: Colors.green[50]!,
          label: l10n.xpMilestoneClaimedLabel,
        );
    }
  }
}

/// Helper class for milestone card configuration.
class _MilestoneConfig {
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final String label;

  _MilestoneConfig({
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.backgroundColor,
    required this.label,
  });
}
