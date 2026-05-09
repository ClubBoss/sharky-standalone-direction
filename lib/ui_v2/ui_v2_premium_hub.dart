import 'package:flutter/material.dart';
import 'package:poker_analyzer/payments/payment_service.dart';
import 'package:poker_analyzer/services/entitlement_sync_v1.dart';
import 'package:poker_analyzer/services/premium_restore_flow_v1.dart';
import 'package:poker_analyzer/services/subscription_status_v1.dart';
import 'package:poker_analyzer/services/premium_value_package_v1.dart';
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

class _UiV2PremiumHubState extends State<UiV2PremiumHub>
    with WidgetsBindingObserver {
  bool _loading = false;
  SubscriptionStatusV1? _status;
  bool _restoreInProgress = false;
  String? _restoreMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    EntitlementSyncV1.revision.addListener(_handleEntitlementSyncV1);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    EntitlementSyncV1.revision.removeListener(_handleEntitlementSyncV1);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _load() async {
    final status = await SubscriptionServiceV1.getStatusV1();
    if (!mounted) return;
    setState(() => _status = status);
  }

  void _handleEntitlementSyncV1() {
    _load();
  }

  Future<void> _upgrade() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final res = await PremiumService().buyPremium();
      final ok = res['validated'] == true;
      if (!mounted) return;
      if (ok) {
        await _load();
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

  Future<void> _restore() async {
    if (_restoreInProgress) return;
    setState(() {
      _restoreInProgress = true;
      _restoreMessage = null;
    });
    final paymentService = PaymentService();
    final status = _status ?? await SubscriptionServiceV1.getStatusV1();
    try {
      final outcome = await PremiumRestoreFlowV1.run(
        entitlementBefore: status.isEntitled,
        performRestore: paymentService.restorePurchases,
        readEntitlementAfter: () async {
          final latestStatus = await SubscriptionServiceV1.getStatusV1();
          return latestStatus.isEntitled;
        },
        readLastError: () => paymentService.lastError,
      );
      final refreshedStatus = await SubscriptionServiceV1.getStatusV1();
      if (!mounted) return;
      setState(() {
        _status = refreshedStatus;
        _restoreMessage = outcome.message;
      });
    } finally {
      if (mounted) {
        setState(() => _restoreInProgress = false);
      }
    }
  }

  String _hubStatusLineV1(SubscriptionAccessStateV1 accessState) {
    return switch (accessState) {
      SubscriptionAccessStateV1.premium =>
        'Premium active: premium-target Today routes and World 5+ are unlocked.',
      SubscriptionAccessStateV1.trial =>
        'Trial active: premium-target Today routes and World 5+ stay open during the active trial.',
      SubscriptionAccessStateV1.free =>
        'Free access stays on the opening path plus one Today route per UTC day.',
    };
  }

  String _hubPackageSummaryLineV1(SubscriptionAccessStateV1 accessState) {
    return switch (accessState) {
      SubscriptionAccessStateV1.premium =>
        'Your account already has premium access on current main.',
      SubscriptionAccessStateV1.trial =>
        'Your account is on trial now. Premium keeps the same premium-target access after the trial ends.',
      SubscriptionAccessStateV1.free =>
        'Premium adds premium-target Today routes and World 5+ progression on current main.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandTheme>();
    final status = _status;
    final accessState = status?.accessState ?? SubscriptionAccessStateV1.free;
    final isPremium = accessState == SubscriptionAccessStateV1.premium;
    final upgradeLabel = switch (accessState) {
      SubscriptionAccessStateV1.premium => 'Premium Activated',
      SubscriptionAccessStateV1.trial => 'Upgrade to Premium',
      SubscriptionAccessStateV1.free => 'Upgrade',
    };
    return Scaffold(
      appBar: AppBar(title: Text(kPremiumValuePackageV1.title)),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(brand?.spacingLarge ?? 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.star, color: theme.colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    _hubStatusLineV1(accessState),
                    key: const Key('premium_hub_status_label_v1'),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _hubPackageSummaryLineV1(accessState),
                key: const Key('premium_hub_package_summary_v1'),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text('What changes', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _Benefit(text: kPremiumValuePackageV1.freeRuleLine),
              _Benefit(text: kPremiumValuePackageV1.unlockLine),
              _Benefit(text: kPremiumValuePackageV1.restoreLine),
              if (_restoreMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _restoreMessage!,
                  key: const Key('premium_hub_restore_status_v1'),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('premium_hub_restore_cta_v1'),
                  onPressed: _restoreInProgress ? null : _restore,
                  child: Text(
                    _restoreInProgress ? 'RESTORING...' : 'Restore purchases',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('premium_hub_upgrade_cta_v1'),
                  onPressed: isPremium || _loading ? null : _upgrade,
                  icon: const Icon(Icons.workspace_premium),
                  label: Text(upgradeLabel),
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
