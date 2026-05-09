import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_service.dart';

/// Lightweight user profile model linked to anonymous account ID.
///
/// Enables profile features without requiring full backend authentication:
/// - Optional username
/// - Email opt-in preference
/// - Experiment flags for A/B testing
class UserProfile {
  /// Unique identifier (matches anon_user_id, immutable)
  final String id;

  /// Optional display name
  final String? name;

  /// Email marketing opt-in preference
  final bool emailOptIn;

  /// Set of enabled experiment flags (e.g., 'new_ui', 'advanced_stats')
  final Set<String> experiments;

  UserProfile({
    required this.id,
    this.name,
    this.emailOptIn = false,
    Set<String>? experiments,
  }) : experiments = experiments ?? {};

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? name,
    bool? emailOptIn,
    Set<String>? experiments,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    emailOptIn: emailOptIn ?? this.emailOptIn,
    experiments: experiments ?? this.experiments,
  );

  /// Serialize to JSON for SharedPreferences storage
  Map<String, dynamic> toJson() => {
    'id': id,
    if (name != null && name!.isNotEmpty) 'name': name,
    'emailOptIn': emailOptIn,
    'experiments': experiments.toList(),
  };

  /// Deserialize from JSON stored in SharedPreferences
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String?,
    emailOptIn: json['emailOptIn'] as bool? ?? false,
    experiments:
        (json['experiments'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toSet() ??
        {},
  );

  @override
  String toString() =>
      'UserProfile(id: $id, name: $name, emailOptIn: $emailOptIn, experiments: $experiments)';
}

/// Service for managing local user profiles linked to anonymous accounts.
///
/// Provides lightweight profile features without requiring backend:
/// - Name/username storage
/// - Email opt-in preferences
/// - Experiment flag management
///
/// Profiles are stored in SharedPreferences under 'user_profile_<id>'.
class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  static const String _keyPrefix = 'user_profile_';

  UserProfile? _cachedProfile;

  UserProfileService._internal();

  /// Singleton instance
  factory UserProfileService() => _instance;

  /// Get storage key for a specific user ID
  String _getKey(String userId) => '$_keyPrefix$userId';

  /// Load profile from SharedPreferences for a specific user ID.
  ///
  /// Returns null if no profile exists or JSON is corrupted.
  Future<UserProfile?> load(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_getKey(userId));

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final profile = UserProfile.fromJson(json);

      // Verify ID matches (data integrity check)
      if (profile.id != userId) {
        // ignore: avoid_print
        print('[UserProfileService] ID mismatch, ignoring corrupted profile');
        return null;
      }

      return profile;
    } catch (e) {
      // Graceful fallback if JSON corrupted
      // ignore: avoid_print
      print('[UserProfileService] Failed to load profile: $e');
      return null;
    }
  }

  /// Save profile to SharedPreferences.
  Future<void> save(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(profile.toJson());
      await prefs.setString(_getKey(profile.id), jsonString);
      _cachedProfile = profile;
    } catch (e) {
      // ignore: avoid_print
      print('[UserProfileService] Failed to save profile: $e');
      rethrow;
    }
  }

  /// Load existing profile or create new one using current anonymous user ID.
  ///
  /// Always returns a valid profile (creates if none exists).
  Future<UserProfile> getOrCreate() async {
    // Return cached profile if available
    if (_cachedProfile != null) {
      return _cachedProfile!;
    }

    // Get current anonymous user ID
    final accountService = AccountService();
    final userId =
        await accountService.getUserId() ?? await accountService.resetUserId();

    // Try to load existing profile
    final existing = await load(userId);
    if (existing != null) {
      _cachedProfile = existing;
      return existing;
    }

    // Create new profile
    final newProfile = UserProfile(id: userId);
    await save(newProfile);
    // ignore: avoid_print
    print('[UserProfileService] Created new profile for user: $userId');
    return newProfile;
  }

  /// Update username only.
  Future<void> updateName(String name) async {
    final profile = await getOrCreate();
    final updated = profile.copyWith(name: name);
    await save(updated);
  }

  /// Update email opt-in preference.
  Future<void> updateEmailOptIn(bool optIn) async {
    final profile = await getOrCreate();
    final updated = profile.copyWith(emailOptIn: optIn);
    await save(updated);
  }

  /// Toggle experiment flag (add if not present, remove if present).
  Future<void> toggleExperiment(String experimentId) async {
    final profile = await getOrCreate();
    final experiments = Set<String>.from(profile.experiments);

    if (experiments.contains(experimentId)) {
      experiments.remove(experimentId);
    } else {
      experiments.add(experimentId);
    }

    final updated = profile.copyWith(experiments: experiments);
    await save(updated);
  }

  /// Add experiment flag if not already present.
  Future<void> enableExperiment(String experimentId) async {
    final profile = await getOrCreate();
    if (profile.experiments.contains(experimentId)) {
      return; // Already enabled
    }

    final experiments = Set<String>.from(profile.experiments)
      ..add(experimentId);
    final updated = profile.copyWith(experiments: experiments);
    await save(updated);
  }

  /// Remove experiment flag if present.
  Future<void> disableExperiment(String experimentId) async {
    final profile = await getOrCreate();
    if (!profile.experiments.contains(experimentId)) {
      return; // Already disabled
    }

    final experiments = Set<String>.from(profile.experiments)
      ..remove(experimentId);
    final updated = profile.copyWith(experiments: experiments);
    await save(updated);
  }

  /// Get all enabled experiment flags.
  Future<Set<String>> getEnabledExperiments() async {
    final profile = await getOrCreate();
    return profile.experiments;
  }

  /// Check if a specific experiment is enabled.
  Future<bool> hasExperiment(String experimentId) async {
    final profile = await getOrCreate();
    return profile.experiments.contains(experimentId);
  }

  /// Clear cached profile (useful for testing or account switching).
  void clearCache() {
    _cachedProfile = null;
  }

  /// Delete profile for a specific user ID.
  Future<void> delete(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getKey(userId));
    if (_cachedProfile?.id == userId) {
      _cachedProfile = null;
    }
  }

  // ==================== Stage 22: Multi-Profile Support ====================

  static const String _keyAllProfiles = 'user_profiles_list';
  static const String _keyActiveProfileId = 'active_profile_id';

  /// Get all user profiles (Stage 22)
  Future<List<UserProfile>> getAllProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileIds = prefs.getStringList(_keyAllProfiles) ?? [];

      final profiles = <UserProfile>[];
      for (final id in profileIds) {
        final profile = await load(id);
        if (profile != null) {
          profiles.add(profile);
        }
      }

      return profiles;
    } catch (_) {
      return [];
    }
  }

  /// Get currently active profile (Stage 22)
  Future<UserProfile?> getActiveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeId = prefs.getString(_keyActiveProfileId);

      if (activeId != null) {
        return await load(activeId);
      }

      // Fallback to current profile if no active set
      return await getOrCreate();
    } catch (_) {
      return null;
    }
  }

  /// Create a new profile with nickname (Stage 22)
  Future<UserProfile> createProfile({required String nickname}) async {
    // Ensure nickname is ASCII-safe
    final safeName = nickname.replaceAll(RegExp(r'[^\x00-\x7F]'), '');
    if (safeName.isEmpty) {
      throw ArgumentError('Nickname must contain ASCII characters');
    }

    // Generate unique ID
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final profile = UserProfile(id: newId, name: safeName);

    await save(profile);

    // Add to profiles list
    final prefs = await SharedPreferences.getInstance();
    final profileIds = prefs.getStringList(_keyAllProfiles) ?? [];
    if (!profileIds.contains(newId)) {
      profileIds.add(newId);
      await prefs.setStringList(_keyAllProfiles, profileIds);
    }

    // Set as active if it's the first profile
    if (profileIds.length == 1) {
      await setActiveProfile(newId);
    }

    return profile;
  }

  /// Switch to a different profile (Stage 22)
  Future<bool> setActiveProfile(String profileId) async {
    try {
      final profile = await load(profileId);
      if (profile == null) return false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyActiveProfileId, profileId);
      _cachedProfile = profile;

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Delete a profile (Stage 22)
  Future<bool> deleteProfile(String profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove from list
      final profileIds = prefs.getStringList(_keyAllProfiles) ?? [];
      profileIds.remove(profileId);
      await prefs.setStringList(_keyAllProfiles, profileIds);

      // Delete profile data
      await delete(profileId);

      // If this was the active profile, switch to another
      final activeId = prefs.getString(_keyActiveProfileId);
      if (activeId == profileId) {
        if (profileIds.isNotEmpty) {
          await setActiveProfile(profileIds.first);
        } else {
          await prefs.remove(_keyActiveProfileId);
          _cachedProfile = null;
        }
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get profile count (Stage 22)
  Future<int> getProfileCount() async {
    final profiles = await getAllProfiles();
    return profiles.length;
  }

  /// Get profiles status for health dashboard (Stage 22)
  Future<Map<String, dynamic>> getProfilesStatus() async {
    try {
      final profiles = await getAllProfiles();
      final active = await getActiveProfile();

      return {
        'count': profiles.length,
        'active': active?.name ?? 'Default',
        'pass': true,
      };
    } catch (_) {
      return {'count': 0, 'active': 'None', 'pass': false};
    }
  }
}
