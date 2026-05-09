import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/coins_service.dart';
import '../shop/shop_items.dart';
import '../shop/shop_item.dart';

class ShopScreen extends StatelessWidget {
  ShopScreen({super.key});

  Future<void> _buy(BuildContext context, ShopItem item) async {
    final coins = context.read<CoinsService>();
    final l10n = AppLocalizations.of(context)!;
    if (coins.coins < item.price) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.shopInsufficientFunds)));
      return;
    }
    final ok = await coins.spendCoins(item.price);
    if (!ok) return;
    await item.onPurchase(context);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.shopPurchased(item.name))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<CoinsService>().coins;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Shop'), centerTitle: true),
      body: Semantics(
        label: l10n.shopScreenLabel, // A11y: Screen-level semantic label
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // A11y: Balance display with semantic label
            Semantics(
              label: l10n.shopYourBalance(balance),
              readOnly: true,
              child: Card(
                key: const Key('shop_balance_card'),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // A11y: Decorative coin icon
                      const ExcludeSemantics(
                        child: Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ExcludeSemantics(
                          child: Text(
                            l10n.shopCoinsBalance(balance),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // A11y: Section header
            Semantics(
              header: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  l10n.shopAvailableItems,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            for (final item in shopItems)
              // A11y: Product card with semantic label and button role
              Semantics(
                button: true,
                enabled: balance >= item.price,
                label:
                    '${item.name}, ${item.description}, Price: ${item.price} coins${balance < item.price ? ", Insufficient funds" : ", Tap to purchase"}',
                child: Card(
                  key: Key(
                    'shop_item_${item.name.toLowerCase().replaceAll(' ', '_')}',
                  ),
                  color: Colors.grey[850],
                  child: InkWell(
                    onTap: () => _buy(context, item),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        12.0,
                      ), // A11y: Increased padding for better touch target
                      child: Row(
                        children: [
                          // A11y: Decorative icon
                          ExcludeSemantics(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                item.icon,
                                color: Colors.orange,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ExcludeSemantics(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.shopPrice(item.price),
                                    style: TextStyle(
                                      color: balance >= item.price
                                          ? Colors.amber
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // A11y: Visual indicator
                          if (balance < item.price)
                            const ExcludeSemantics(
                              child: Icon(
                                Icons.lock,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
