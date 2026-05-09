import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_action_logger.dart';
import '../services/premium_service.dart';

/// Service for handling in-app purchases on Android and iOS.
///
/// Supports:
/// - Non-consumable products (one-time purchases)
/// - Subscriptions (recurring)
/// - Purchase restoration
/// - Transaction verification
class PaymentService extends ChangeNotifier {
  PaymentService._();
  static final PaymentService _instance = PaymentService._();
  static PaymentService get instance => _instance;
  factory PaymentService() => _instance;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  bool _isLoading = false;
  List<ProductDetails> _products = [];
  Set<String> _purchasedProductIds = {};
  String? _lastError;

  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  List<ProductDetails> get products => _products;
  Set<String> get purchasedProductIds => _purchasedProductIds;
  String? get lastError => _lastError;

  /// Product IDs for the shop.
  /// These must match the IDs configured in Google Play Console and App Store Connect.
  static const String productPremiumPack = 'premium_pack';
  static const String productProSubscription = 'pro_subscription_monthly';
  static const String productXpBooster = 'xp_booster';
  static const String productCoinsPackSmall = 'coins_pack_small';
  static const String productCoinsPackMedium = 'coins_pack_medium';
  static const String productCoinsPackLarge = 'coins_pack_large';

  static const Set<String> _productIds = {
    productPremiumPack,
    productProSubscription,
    productXpBooster,
    productCoinsPackSmall,
    productCoinsPackMedium,
    productCoinsPackLarge,
  };

  static const String _purchasedProductsKey = 'purchased_products';

  /// Initialize the payment service and load purchased products.
  Future<void> initialize() async {
    try {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) {
        _lastError = 'Store not available on this device';
        notifyListeners();
        return;
      }

      // Load persisted purchases
      await _loadPurchasedProducts();

      // Listen to purchase updates
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (error) {
          _lastError = 'Purchase stream error: $error';
          notifyListeners();
        },
        onDone: () {
          debugPrint('PaymentService: Purchase stream done');
        },
      );

      // Query available products
      await queryProducts();

      await UserActionLogger.instance.log('payment_service_initialized');
    } catch (e) {
      _lastError = 'Initialization error: $e';
      notifyListeners();
    }
  }

  /// Query available products from the store.
  Future<void> queryProducts() async {
    if (!_isAvailable) {
      _lastError = 'Store not available';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        _productIds,
      );

      if (response.error != null) {
        _lastError = 'Query error: ${response.error!.message}';
        _products = [];
      } else if (response.productDetails.isEmpty) {
        _lastError = 'No products found. Check store configuration.';
        _products = [];
      } else {
        _products = response.productDetails;
        _lastError = null;

        await UserActionLogger.instance.logEvent({
          'event': 'products_queried',
          'count': _products.length,
          'products': _products.map((p) => p.id).toList(),
        });
      }

      // Log missing products
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
        await UserActionLogger.instance.logEvent({
          'event': 'products_not_found',
          'ids': response.notFoundIDs,
        });
      }
    } catch (e) {
      _lastError = 'Query exception: $e';
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Purchase a product.
  Future<void> buyProduct(ProductDetails product) async {
    if (!_isAvailable) {
      _lastError = 'Store not available';
      notifyListeners();
      return;
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      bool success;
      if (product.id == productProSubscription) {
        // Subscription
        success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // Non-consumable (one-time purchase)
        success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }

      if (!success) {
        _lastError = 'Failed to initiate purchase for ${product.id}';
        notifyListeners();
      }

      await UserActionLogger.instance.logEvent({
        'event': 'purchase_initiated',
        'product_id': product.id,
        'success': success,
      });
    } catch (e) {
      _lastError = 'Purchase error: $e';
      notifyListeners();
      await UserActionLogger.instance.logEvent({
        'event': 'purchase_error',
        'product_id': product.id,
        'error': e.toString(),
      });
    }
  }

  /// Restore previously purchased products.
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      _lastError = 'Store not available';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      await _iap.restorePurchases();
      await UserActionLogger.instance.log('purchases_restored');
    } catch (e) {
      _lastError = 'Restore error: $e';
      await UserActionLogger.instance.logEvent({
        'event': 'restore_error',
        'error': e.toString(),
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle purchase updates from the store.
  Future<void> _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      await _handlePurchase(purchaseDetails);
    }
  }

  /// Process individual purchase.
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      // Payment is pending (waiting for user confirmation, etc.)
      await UserActionLogger.instance.logEvent({
        'event': 'purchase_pending',
        'product_id': purchaseDetails.productID,
      });
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      // Purchase failed
      _lastError = 'Purchase failed: ${purchaseDetails.error?.message}';
      notifyListeners();

      await UserActionLogger.instance.logEvent({
        'event': 'purchase_failed',
        'product_id': purchaseDetails.productID,
        'error_code': purchaseDetails.error?.code,
        'error_message': purchaseDetails.error?.message,
      });
    } else if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      // Purchase successful
      final bool valid = await _verifyPurchase(purchaseDetails);

      if (valid) {
        await _deliverProduct(purchaseDetails);
        _purchasedProductIds.add(purchaseDetails.productID);
        await _savePurchasedProducts();

        await UserActionLogger.instance.logEvent({
          'event': 'purchase_completed',
          'product_id': purchaseDetails.productID,
          'status': purchaseDetails.status.toString(),
        });
      } else {
        _lastError = 'Purchase verification failed';
        await UserActionLogger.instance.logEvent({
          'event': 'purchase_verification_failed',
          'product_id': purchaseDetails.productID,
        });
      }
    } else if (purchaseDetails.status == PurchaseStatus.canceled) {
      // User canceled
      await UserActionLogger.instance.logEvent({
        'event': 'purchase_canceled',
        'product_id': purchaseDetails.productID,
      });
    }

    // Complete the purchase (acknowledge)
    if (purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
    }

    notifyListeners();
  }

  /// Verify purchase (stub for now - implement server verification in production).
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // v1 policy: no server receipt verification yet.
    // Deterministically trust purchase stream status only:
    // - purchased/restored => verified
    // - pending/error/canceled => not verified
    // Future hardening will move verification to backend receipt checks.
    return isVerifiedEntitlementV1(purchaseDetails);
  }

  /// Deliver the purchased product to the user.
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    // Handle product delivery based on product ID
    final productId = purchaseDetails.productID;

    // Mark product as purchased
    _purchasedProductIds.add(productId);
    await _savePurchasedProducts();

    // Log delivery
    await UserActionLogger.instance.logEvent({
      'event': 'product_delivered',
      'product_id': productId,
    });

    await syncCanonicalEntitlementForProductV1(productId);

    // Note: Actual product delivery (coins, XP, unlocks) should be handled
    // by the UI layer or a separate fulfillment service.
  }

  /// Check if a product has been purchased.
  bool hasPurchased(String productId) =>
      _purchasedProductIds.contains(productId);

  static bool isVerifiedEntitlementV1(PurchaseDetails purchaseDetails) {
    return purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored;
  }

  static bool _isPremiumEntitlementProductV1(String productId) {
    return productId == productPremiumPack ||
        productId == productProSubscription;
  }

  @visibleForTesting
  static Future<void> syncCanonicalEntitlementForProductV1(
    String productId,
  ) async {
    if (_isPremiumEntitlementProductV1(productId)) {
      await PremiumService().enablePremium();
    }
  }

  /// Load purchased products from local storage.
  Future<void> _loadPurchasedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? purchased = prefs.getStringList(
        _purchasedProductsKey,
      );
      if (purchased != null) {
        _purchasedProductIds = purchased.toSet();
      }
    } catch (e) {
      debugPrint('Error loading purchased products: $e');
    }
  }

  /// Save purchased products to local storage.
  Future<void> _savePurchasedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _purchasedProductsKey,
        _purchasedProductIds.toList(),
      );
    } catch (e) {
      debugPrint('Error saving purchased products: $e');
    }
  }

  /// Get product by ID.
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Dispose the service.
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
