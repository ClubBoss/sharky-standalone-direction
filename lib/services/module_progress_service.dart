// ignore_for_file: avoid_print

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking user progress on training modules.
///
/// Stores completed module IDs in SharedPreferences as a local-only solution.
/// Each completed module is tracked by its unique ID (e.g., "core_bankroll_management").
///
/// Usage:
/// ```dart
/// final service = context.read<ModuleProgressService>();
/// await service.markModuleCompleted('core_bankroll_management');
/// bool isComplete = service.isModuleCompleted('core_bankroll_management');
/// ```
class ModuleProgressService {
  static const String _storageKey = 'completed_modules';

  SharedPreferences? _prefs;
  Set<String> _completedModules = {};
  bool _initialized = false;

  /// Initialize the service by loading completed modules from SharedPreferences.
  ///
  /// This should be called once when the app starts. The service is automatically
  /// initialized when registered as a provider with the cascade operator:
  /// `Provider(create: (_) => ModuleProgressService()..initialize())`
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      final List<String>? stored = _prefs?.getStringList(_storageKey);

      if (stored != null) {
        _completedModules = stored.toSet();
      }

      _initialized = true;
    } catch (e) {
      print('Error initializing ModuleProgressService: $e');
      _completedModules = {};
      _initialized = true; // Mark as initialized even on error
    }
  }

  /// Mark a module as completed.
  ///
  /// Adds the module ID to the completed set and persists to SharedPreferences.
  /// If the module is already marked as completed, this is a no-op.
  ///
  /// Returns true if the module was newly marked as completed, false if already completed.
  Future<bool> markModuleCompleted(String moduleId) async {
    if (!_initialized) {
      await initialize();
    }

    if (_completedModules.contains(moduleId)) {
      return false; // Already completed
    }

    _completedModules.add(moduleId);
    await _saveToStorage();
    return true;
  }

  /// Mark a module as incomplete (remove from completed set).
  ///
  /// This allows users to reset their progress on a module if needed.
  /// Returns true if the module was unmarked, false if it wasn't completed.
  Future<bool> markModuleIncomplete(String moduleId) async {
    if (!_initialized) {
      await initialize();
    }

    if (!_completedModules.contains(moduleId)) {
      return false; // Was not completed
    }

    _completedModules.remove(moduleId);
    await _saveToStorage();
    return true;
  }

  /// Check if a module is marked as completed.
  ///
  /// Returns true if the module ID is in the completed set, false otherwise.
  bool isModuleCompleted(String moduleId) {
    if (!_initialized) {
      // Service not initialized yet, return false
      return false;
    }
    return _completedModules.contains(moduleId);
  }

  /// Get the set of all completed module IDs.
  ///
  /// Returns a copy of the internal set to prevent external modification.
  Set<String> getCompletedModules() => Set.from(_completedModules);

  /// Get the count of completed modules.
  int getCompletedCount() => _completedModules.length;

  /// Get the completion percentage for a given set of module IDs.
  ///
  /// Useful for calculating progress within a category or track.
  /// Returns a value between 0.0 and 1.0.
  double getCompletionPercentage(List<String> moduleIds) {
    if (moduleIds.isEmpty) return 0.0;

    final completed = moduleIds.where(isModuleCompleted).length;
    return completed / moduleIds.length;
  }

  /// Clear all completion progress.
  ///
  /// This removes all completed module records from both memory and storage.
  /// Use with caution - this action cannot be undone.
  Future<void> clearAllProgress() async {
    if (!_initialized) {
      await initialize();
    }

    _completedModules.clear();
    await _saveToStorage();
  }

  /// Save the current completed modules set to SharedPreferences.
  Future<void> _saveToStorage() async {
    try {
      if (_prefs != null) {
        await _prefs!.setStringList(_storageKey, _completedModules.toList());
      }
    } catch (e) {
      print('Error saving module progress: $e');
    }
  }

  /// Check if the service has been initialized.
  bool get isInitialized => _initialized;
}
