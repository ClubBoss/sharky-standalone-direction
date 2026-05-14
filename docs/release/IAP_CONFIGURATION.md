# In-App Purchase Configuration Guide

This guide explains how to configure in-app purchases for Android and iOS.

## Product IDs

The following product IDs are configured in the app:

1. **premium_pack** - Non-consumable, unlocks all premium training packs
2. **pro_subscription_monthly** - Monthly subscription with all features
3. **pro_subscription_annual** - Annual subscription with all features
4. **xp_booster** - Consumable, adds 500 XP
5. **coins_pack_small** - Consumable, adds 100 coins
6. **coins_pack_medium** - Consumable, adds 500 coins
7. **coins_pack_large** - Consumable, adds 1200 coins

## Android Configuration (Google Play)

### Prerequisites
- Google Play Developer account
- App published to Google Play Console (at least in internal testing)

### Steps

1. **Go to Google Play Console**
   - Navigate to your app
   - Select "Monetization setup" > "In-app products"

2. **Create Products**
   For each product ID above, create an in-app product:
   
   - Product ID: `premium_pack`
   - Name: `Premium Pack`
   - Description: `Unlock all premium training packs`
   - Price: Set your price (e.g., $9.99)
   - Status: Active
   
   Repeat for all products with appropriate details.

3. **Configure Subscriptions** (for pro_subscription_monthly and pro_subscription_annual)
   - Go to "Subscriptions" instead of "In-app products"
   - Create subscription with ID: `pro_subscription_monthly`
   - Create subscription with ID: `pro_subscription_annual`
   - Put both inside one subscription group
   - Set billing period: 1 month for monthly
   - Set billing period: 1 year for annual
   - Set price and other details
   - Enable free trial if desired

4. **Update AndroidManifest.xml**
   Add billing permission (already added if using the template):
   ```xml
   <uses-permission android:name="com.android.vending.BILLING" />
   ```

5. **Test with License Testers**
   - Add test accounts in Google Play Console
   - Use these accounts to test purchases without charges

### Android Files Already Configured
- `android/app/src/main/AndroidManifest.xml` - Billing permission
- Build configuration is automatic with `in_app_purchase` plugin

## iOS Configuration (App Store)

### Prerequisites
- Apple Developer account ($99/year)
- App created in App Store Connect
- Paid Applications agreement signed

### Steps

1. **Go to App Store Connect**
   - Select your app
   - Go to "Features" > "In-App Purchases"

2. **Create In-App Purchases**
   For each product:
   
   **Non-Consumable Products** (premium_pack):
   - Click "+" to add
   - Type: Non-Consumable
   - Reference Name: `Premium Pack`
   - Product ID: `premium_pack` (must match exactly)
   - Price: Select price tier
   - Localizations: Add descriptions
   - Screenshot: Upload if required
   - Submit for review

   **Auto-Renewable Subscriptions** (pro_subscription_monthly, pro_subscription_annual):
   - Create Subscription Group first
   - Add subscription to group
   - Product ID: `pro_subscription_monthly`
   - Duration: 1 month
   - Product ID: `pro_subscription_annual`
   - Duration: 1 year
   - Price: Select tiers
   - Localizations: Add descriptions

   **Consumable Products** (xp_booster, coins packs):
   - Type: Consumable
   - Follow same steps as non-consumable

3. **Update Info.plist** (if needed)
   The plugin handles most configuration automatically.

4. **Sandbox Testing**
   - Go to "Users and Access" > "Sandbox Testers"
   - Create test accounts
   - Sign out of real App Store on device
   - Sign in with sandbox account in app to test

### iOS Files Configuration

**Info.plist** (if needed):
No special keys required for basic IAP. The `in_app_purchase` plugin handles configuration.

**Xcode Settings**:
- Ensure "In-App Purchase" capability is enabled
- This is usually automatic when using the plugin

## Testing

### Android Testing
1. Build a release APK or AAB
2. Upload to Google Play (internal testing track)
3. Add test account as license tester
4. Install from Play Store
5. Test purchases (no charges for testers)

### iOS Testing
1. Build for device (not simulator - IAP doesn't work on simulator)
2. Sign out of real App Store account
3. Run app on device
4. When prompted, use sandbox tester account
5. Test purchases (sandbox transactions, no real charges)

### Debug Mode
In debug mode, the store may not be available. Products will show as "Not available" if:
- Not properly configured in store console
- App not signed properly
- Network issues
- Store servers are down

## Verification (Important for Production)

The current implementation accepts all purchases as valid. For production:

1. **Implement Server-Side Verification**
   - Create backend endpoint to verify receipts
   - Send `purchaseDetails.verificationData` to your server
   - Server verifies with Google Play / App Store APIs
   - Only deliver product after verification

2. **Update `_verifyPurchase` in payment_service.dart**
   ```dart
   Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
     // Send to your backend
     final response = await http.post(
       Uri.parse('https://your-server.com/verify-purchase'),
       body: jsonEncode({
         'source': purchaseDetails.verificationData.source,
         'serverVerificationData': 
             purchaseDetails.verificationData.serverVerificationData,
         'localVerificationData': 
             purchaseDetails.verificationData.localVerificationData,
       }),
     );
     return response.statusCode == 200;
   }
   ```

## Firebase Integration

To sync purchases across devices:

1. **Save to Firestore after purchase**
   ```dart
   await FirebaseFirestore.instance
       .collection('users')
       .doc(userId)
       .collection('purchases')
       .doc(productId)
       .set({
     'product_id': productId,
     'purchase_date': FieldValue.serverTimestamp(),
     'platform': Platform.isAndroid ? 'android' : 'ios',
   });
   ```

2. **Load purchases on app start**
   ```dart
   final snapshot = await FirebaseFirestore.instance
       .collection('users')
       .doc(userId)
       .collection('purchases')
       .get();
   ```

## Troubleshooting

### "Store not available"
- Check internet connection
- Ensure app is properly signed
- Verify store console configuration
- Check device/simulator (iOS simulator doesn't support IAP)

### "No products found"
- Verify product IDs match exactly
- Ensure products are active in store console
- Wait up to 24 hours after creating products
- Check app bundle ID matches store configuration

### Purchase not completing
- Check logs for errors
- Verify purchase flow in store console
- Ensure proper error handling
- Check payment method is valid (for real purchases)

## Resources

- [in_app_purchase plugin docs](https://pub.dev/packages/in_app_purchase)
- [Google Play Billing](https://developer.android.com/google/play/billing)
- [Apple In-App Purchase](https://developer.apple.com/in-app-purchase/)
