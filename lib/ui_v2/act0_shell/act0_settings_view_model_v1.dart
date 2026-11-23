/// Loading state of the local preferences owned by the Settings route.
enum Act0AcademySettingsLoadStateV1 { loading, failed, ready }

enum Act0SettingsDeletionStateV1 {
  idle,
  deleteConfirm,
  deleting,
  deleted,
  error;

  bool get showDeletionScreen => this == deleting || this == error;
}

/// The settings route's local values and existing control availability.
class Act0SettingsViewModelV1 {
  const Act0SettingsViewModelV1({
    required this.loadState,
    required this.version,
    required this.hapticsEnabled,
    required bool reminderSupported,
    required bool reminderEnabled,
    required bool savingReminder,
  }) : practiceReminderEnabled = reminderSupported ? reminderEnabled : null,
       canChangeReminder = !savingReminder;

  final Act0AcademySettingsLoadStateV1 loadState;
  final Future<String> version;
  final bool hapticsEnabled;
  final bool? practiceReminderEnabled;
  final bool canChangeReminder;

  static bool showReminderPermissionNotice({
    required bool enabled,
    required bool scheduled,
  }) => enabled && !scheduled;
}

/// Existing release gate for the legacy preview actions exposed to Settings.
T? act0SettingsPreviewActionV1<T>(
  T action, {
  required bool isDebugMode,
  required bool legacyPreviewRequested,
}) => isDebugMode && legacyPreviewRequested ? action : null;
