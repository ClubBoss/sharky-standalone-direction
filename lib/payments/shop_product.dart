import 'package:in_app_purchase/in_app_purchase.dart';

/// Shop product with metadata for display in the shop UI.
class ShopProduct {
  final String id;
  final String name;
  final String description;
  final ProductDetails? storeProduct;
  final String iconName;
  final ProductType type;

  ShopProduct({
    required this.id,
    required this.name,
    required this.description,
    this.storeProduct,
    required this.iconName,
    required this.type,
  });

  /// Get the formatted price from the store.
  String get price {
    if (storeProduct != null) {
      return storeProduct!.price;
    }
    return 'N/A';
  }

  /// Check if this product is available for purchase.
  bool get isAvailable => storeProduct != null;
}

enum ProductType { nonConsumable, subscription, consumable }

/// Predefined shop products matching the store configuration.
class ShopProducts {
  static ShopProduct premiumPack({ProductDetails? details}) => ShopProduct(
    id: 'premium_pack',
    name: 'Premium Pack',
    description: 'Unlock all premium training packs',
    storeProduct: details,
    iconName: 'star',
    type: ProductType.nonConsumable,
  );

  static ShopProduct proSubscription({ProductDetails? details}) => ShopProduct(
    id: 'pro_subscription_monthly',
    name: 'Pro Subscription',
    description: 'Monthly subscription with all features',
    storeProduct: details,
    iconName: 'vip',
    type: ProductType.subscription,
  );

  static ShopProduct proSubscriptionAnnual({ProductDetails? details}) =>
      ShopProduct(
        id: 'pro_subscription_annual',
        name: 'Pro Subscription Annual',
        description: 'Annual subscription with all features',
        storeProduct: details,
        iconName: 'vip',
        type: ProductType.subscription,
      );

  static ShopProduct xpBooster({ProductDetails? details}) => ShopProduct(
    id: 'xp_booster',
    name: 'XP Booster',
    description: '+500 XP instantly',
    storeProduct: details,
    iconName: 'flash',
    type: ProductType.consumable,
  );

  static ShopProduct coinsSmall({ProductDetails? details}) => ShopProduct(
    id: 'coins_pack_small',
    name: 'Coin Pack - Small',
    description: '100 coins',
    storeProduct: details,
    iconName: 'coins',
    type: ProductType.consumable,
  );

  static ShopProduct coinsMedium({ProductDetails? details}) => ShopProduct(
    id: 'coins_pack_medium',
    name: 'Coin Pack - Medium',
    description: '500 coins',
    storeProduct: details,
    iconName: 'coins',
    type: ProductType.consumable,
  );

  static ShopProduct coinsLarge({ProductDetails? details}) => ShopProduct(
    id: 'coins_pack_large',
    name: 'Coin Pack - Large',
    description: '1200 coins (+20% bonus)',
    storeProduct: details,
    iconName: 'coins',
    type: ProductType.consumable,
  );
}
