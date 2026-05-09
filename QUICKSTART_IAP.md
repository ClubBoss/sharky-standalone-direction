# Quick Start Guide - In-App Purchases

## For Developers

### Running the Shop
1. The shop screen is at `lib/screens/shop_screen.dart`
2. Navigate to it via your app's navigation (already integrated if shop was in menu)
3. In development, store shows "Store not available" until products are configured

### Testing Locally
```bash
# Run on Android device
flutter run --release

# Run on iOS device  
flutter run --release
```

**Important:** IAP doesn't work on iOS simulators. Use real devices.

### Quick Product Setup (Android)

1. Go to Google Play Console → Your App → Monetization
2. Create in-app products with these IDs:
   - `premium_pack`
   - `pro_subscription_monthly` (subscription)
   - `xp_booster`
   - `coins_pack_small`
   - `coins_pack_medium`
   - `coins_pack_large`
3. Set prices and activate products
4. Add test account in "License Testing"
5. Build and test

### Quick Product Setup (iOS)

1. Go to App Store Connect → Your App → In-App Purchases
2. Create products with same IDs as Android
3. For subscription: Create subscription group first
4. Set prices and submit for review
5. Add sandbox tester in Users and Access
6. Build and test on device

### Adding New Products

1. **Add product ID to `payment_service.dart`:**
```dart
static const String productNewItem = 'new_item_id';

static const Set<String> _productIds = {
  // ... existing products
  productNewItem,
};
```

2. **Add to `shop_product.dart`:**
```dart
static ShopProduct newItem({ProductDetails? details}) => ShopProduct(
  id: 'new_item_id',
  name: 'New Item',
  description: 'Description here',
  storeProduct: details,
  iconName: 'icon_name',
  type: ProductType.nonConsumable,
);
```

3. **Add to shop screen's `_getShopProducts()`:**
```dart
ShopProducts.newItem(
  details: paymentService.getProduct('new_item_id'),
),
```

4. **Add fulfillment in `_fulfillPurchase()`:**
```dart
case 'new_item_id':
  // Your fulfillment logic
  await unlockFeature();
  break;
```

### Checking Purchase Status

```dart
// In any widget with Provider
final paymentService = context.read<PaymentService>();

if (paymentService.hasPurchased('premium_pack')) {
  // User has premium
}

if (paymentService.hasPurchased('pro_subscription_monthly')) {
  // User has active subscription
}
```

### Enabling Premium Features

```dart
// Example: Premium-only feature
Widget build(BuildContext context) {
  final paymentService = context.watch<PaymentService>();
  final isPremium = paymentService.hasPurchased('premium_pack') ||
                    paymentService.hasPurchased('pro_subscription_monthly');
  
  if (!isPremium) {
    return LockedFeatureWidget(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ShopScreen()),
      ),
    );
  }
  
  return PremiumFeatureWidget();
}
```

### Debugging

**Check logs for:**
```
PaymentService: Product queried
PaymentService: Purchase completed
```

**Common issues:**
- "Store not available" → Check device internet, proper signing
- "No products found" → Check product IDs match store configuration
- Purchase not completing → Check logs for errors

**Enable verbose logging:**
```dart
// In payment_service.dart, add more debugPrint statements
debugPrint('PaymentService: Detailed status');
```

### Firebase Purchase Sync

Purchases automatically sync to Firebase when user is signed in:
```dart
// Manual sync (if needed)
await PurchaseSyncService.instance.sync();
```

### Testing Without Real Money

**Android:**
- Use license testers (no charges)
- Test in internal testing track

**iOS:**
- Use sandbox testers (no charges)
- Sign out of real App Store before testing

### Restoring Purchases

Users can restore via:
1. Shop screen → Restore button (top right)
2. Programmatically:
```dart
await PaymentService.instance.restorePurchases();
```

### Server Verification (Production)

⚠️ **Before production release:**

Update `_verifyPurchase()` in `payment_service.dart`:
```dart
Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
  try {
    final response = await http.post(
      Uri.parse('YOUR_BACKEND_URL/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'source': purchaseDetails.verificationData.source,
        'serverVerificationData': 
            purchaseDetails.verificationData.serverVerificationData,
      }),
    );
    return response.statusCode == 200;
  } catch (e) {
    return false; // Reject on error
  }
}
```

## Quick Commands

```bash
# Install dependencies
flutter pub get

# Run analyze
dart analyze lib/payments/ lib/services/purchase_sync_service.dart

# Format code
dart format lib/payments/

# Build for testing (Android)
flutter build apk --release

# Build for testing (iOS)
flutter build ios --release
```

## Need Help?

1. Check `docs/IAP_CONFIGURATION.md` for detailed setup
2. Check `IAP_IMPLEMENTATION.md` for implementation details
3. Review [in_app_purchase docs](https://pub.dev/packages/in_app_purchase)
4. Check store console for product configuration issues
