import 'package:flutter/material.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/services/reward_economy_service.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class RewardShopScreen extends StatefulWidget {
  static const String routeName = '/v3/reward-shop';

  const RewardShopScreen({super.key});

  @override
  State<RewardShopScreen> createState() => _RewardShopScreenState();
}

class _RewardShopScreenState extends State<RewardShopScreen> {
  int _balance = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final value = await RewardEconomyService.instance.getBalance();
    if (!mounted) return;
    setState(() {
      _balance = value;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rewards = RewardEconomyService.instance.listRewards();
    return Theme(
      data: VisualThemeV3.theme,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.rewardShopTitle)),
        body: Padding(
          padding: const EdgeInsets.all(VisualThemeV3.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(l10n),
              const SizedBox(height: VisualThemeV3.spacingM),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        itemCount: rewards.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: VisualThemeV3.spacingM,
                              mainAxisSpacing: VisualThemeV3.spacingM,
                              childAspectRatio: 0.85,
                            ),
                        itemBuilder: (context, index) {
                          final reward = rewards[index];
                          final affordable = _balance >= reward.cost;
                          return _RewardCard(
                            reward: reward,
                            affordable: affordable,
                            onTap: () => _handlePurchase(reward),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VisualThemeV3.spacingM),
      decoration: BoxDecoration(
        color: VisualThemeV3.theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.rewardShopBalanceLabel,
                  style: VisualThemeV3.theme.textTheme.titleMedium,
                ),
                const SizedBox(height: VisualThemeV3.spacingXS),
                Text(
                  l10n.rewardShopChipCount(_balance),
                  style: VisualThemeV3.theme.textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadBalance,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.rewardShopRefresh,
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(RewardItem reward) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.rewardShopConfirmTitle),
            content: Text(l10n.rewardShopConfirmBody(reward.cost, reward.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.rewardShopCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.rewardShopPurchase),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirm) return;

    final success = await RewardEconomyService.instance.purchaseReward(reward);
    if (!mounted) return;
    if (success) {
      await _loadBalance();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.rewardShopUnlocked(reward.name))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.rewardShopInsufficient(reward.name))),
      );
    }
  }
}

class _RewardCard extends StatefulWidget {
  const _RewardCard({
    required this.reward,
    required this.affordable,
    required this.onTap,
  });

  final RewardItem reward;
  final bool affordable;
  final VoidCallback onTap;

  @override
  State<_RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<_RewardCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: widget.affordable ? widget.onTap : null,
      onTapDown: (_) {
        if (!widget.affordable) return;
        setState(() => _pressed = true);
      },
      onTapCancel: () {
        if (!widget.affordable) return;
        setState(() => _pressed = false);
      },
      onTapUp: (_) {
        if (!widget.affordable) return;
        setState(() => _pressed = false);
      },
      child: AnimatedContainer(
        duration: VisualThemeV3.speedFast,
        padding: const EdgeInsets.all(VisualThemeV3.spacingM),
        decoration: BoxDecoration(
          color: widget.affordable
              ? scheme.primaryContainer
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
          border: Border.all(
            color: widget.affordable ? scheme.primary : scheme.outlineVariant,
          ),
          boxShadow: _pressed
              ? const [VisualThemeV3.shadowLight]
              : const [VisualThemeV3.shadowMedium],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.reward.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: VisualThemeV3.spacingS),
            Text(
              widget.reward.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Text(
              l10n.rewardShopChipCount(widget.reward.cost),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
