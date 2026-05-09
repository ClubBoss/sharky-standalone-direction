import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/services/premium_service.dart';

/// UI v2 Premium Hub: shows benefits and lets the user upgrade via mock gateway.
class UiV2PremiumHub extends StatefulWidget {
  static const String route = '/ui_v2/premium_hub';

  const UiV2PremiumHub({super.key});

  @override
  State<UiV2PremiumHub> createState() => _UiV2PremiumHubState();
}

class _UiV2PremiumHubState extends State<UiV2PremiumHub> {
  bool _loading = false;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final active = await PremiumService().isPremiumActive();
    if (!mounted) return;
    setState(() => _active = active);
  }

  Future<void> _upgrade() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final res = await PremiumService().buyPremium();
      final ok = res['validated'] == true;
      if (!mounted) return;
      if (ok) {
        setState(() => _active = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Premium Activated')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Purchase failed')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandTheme>();
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Hub')),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(brand?.spacingLarge ?? 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  _active ? 'Premium is ACTIVE' : 'Premium is OFF',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Benefits', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _Benefit(text: '• Access to advanced training packs'),
            _Benefit(text: '• Premium leaderboards and badges'),
            _Benefit(text: '• Early access to new content'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _active || _loading ? null : _upgrade,
                icon: const Icon(Icons.workspace_premium),
                label: Text(_active ? 'Premium Activated' : 'Upgrade'),
              ),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const LinearProgressIndicator(
                color: AppColors.accentSuccess,
                backgroundColor: AppColors.progressBackground,
              ),
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final String text;
  const _Benefit({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: theme.textTheme.bodyLarge),
    );
  }
}
