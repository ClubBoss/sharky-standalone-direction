import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/entitlement_sync_v1.dart';
import 'package:poker_analyzer/services/release_commerce_availability_v1.dart';
import 'package:poker_analyzer/services/subscription_surface_copy_v1.dart';
import 'package:poker_analyzer/services/subscription_status_v1.dart';
import 'package:poker_analyzer/services/premium_value_package_v1.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
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
  SubscriptionStatusV1? _status;
  ReleaseCommerceAvailabilityStateV1? _commerceAvailability;

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
    final commerceAvailability =
        await ReleaseCommerceAvailabilityServiceV1.readV1();
    if (!mounted) return;
    setState(() {
      _status = status;
      _commerceAvailability = commerceAvailability;
    });
  }

  void _handleEntitlementSyncV1() {
    _load();
  }

  String _hubStatusLineV1(SubscriptionAccessStateV1 accessState) {
    return SubscriptionSurfaceCopyV1.hubStatusLine(
      _status ??
          SubscriptionStatusV1(
            isPremium: false,
            isEntitled: false,
            isTrialActive: false,
            trialRemainingDays: 0,
            source: SubscriptionSourceV1.none,
            accessState: accessState,
          ),
    );
  }

  String _hubPackageSummaryLineV1(SubscriptionAccessStateV1 accessState) {
    return SubscriptionSurfaceCopyV1.hubPackageSummaryLine(
      _status ??
          SubscriptionStatusV1(
            isPremium: false,
            isEntitled: false,
            isTrialActive: false,
            trialRemainingDays: 0,
            source: SubscriptionSourceV1.none,
            accessState: accessState,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandTheme>();
    final status = _status;
    final commerceAvailability = _commerceAvailability;
    final accessState = status?.accessState ?? SubscriptionAccessStateV1.free;
    final defaultUpgradeLabel = switch (accessState) {
      SubscriptionAccessStateV1.premium => 'Premium Activated',
      SubscriptionAccessStateV1.trial => 'Upgrade to Premium',
      SubscriptionAccessStateV1.free => 'Upgrade',
    };
    final upgradeLabel = switch (accessState) {
      SubscriptionAccessStateV1.premium => defaultUpgradeLabel,
      SubscriptionAccessStateV1.trial => defaultUpgradeLabel,
      SubscriptionAccessStateV1.free =>
        commerceAvailability?.offerScope.upgradeLabel ?? defaultUpgradeLabel,
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
              if (commerceAvailability?.message case final message?) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  key: const Key('premium_hub_store_note_v1'),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('premium_hub_restore_cta_v1'),
                  onPressed: null,
                  child: const Text('Restore purchases'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('premium_hub_upgrade_cta_v1'),
                  onPressed: null,
                  icon: const Icon(Icons.workspace_premium),
                  label: Text(upgradeLabel),
                ),
              ),
              const SizedBox(height: 8),
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
