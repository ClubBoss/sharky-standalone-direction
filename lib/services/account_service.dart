import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Service for managing anonymous account IDs.
///
/// Generates and persists a unique anonymous user ID for:
/// - Future cloud sync capabilities
/// - Analytics and metrics tracking
/// - Account upgrade paths (anonymous → authenticated)
///
/// The ID is stored in SharedPreferences and persists across app sessions.
/// No user interaction required - completely transparent.
class AccountService {
  static const String _storageKey = 'anon_user_id';
  static final AccountService _instance = AccountService._internal();
  static const _uuid = Uuid();

  String? _cachedUserId;

  AccountService._internal();

  /// Singleton instance
  factory AccountService() => _instance;

  /// Get the current user ID, generating one if needed.
  ///
  /// Returns a persistent UUID that identifies this anonymous account.
  /// The ID is cached in memory for performance after first retrieval.
  Future<String?> getUserId() async {
    // Return cached ID if available
    final cachedId = _cachedUserId;
    if (cachedId != null) {
      return cachedId;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString(_storageKey);
    if (storedUserId != null && storedUserId.isNotEmpty) {
      // ignore: avoid_print
      print('[AccountService] Loaded existing anonymous ID: $storedUserId');
      _cachedUserId = storedUserId;
      return storedUserId;
    }

    final newId = _uuid.v4();
    await prefs.setString(_storageKey, newId);
    // ignore: avoid_print
    print('[AccountService] Generated new anonymous ID: $newId');
    _cachedUserId = newId;
    return newId;
  }

  /// Reset the user ID (useful for testing or account logout).
  ///
  /// Generates a fresh anonymous ID and persists it.
  /// Use with caution - this will disconnect from any cloud data
  /// associated with the previous ID.
  Future<String> resetUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final newId = _uuid.v4();
    await prefs.setString(_storageKey, newId);
    _cachedUserId = newId;
    // ignore: avoid_print
    print('[AccountService] Reset anonymous ID to: $newId');
    return newId;
  }

  /// Clear the cached ID (useful for testing).
  void clearCache() {
    _cachedUserId = null;
  }

  /// Check if a user ID exists in storage (without generating one).
  Future<bool> hasUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_storageKey);
    return userId != null && userId.isNotEmpty;
  }
}
