import 'training_progress_service.dart';

class CoreCompletionBadgeService {
  static final CoreCompletionBadgeService _instance =
      CoreCompletionBadgeService._internal();

  factory CoreCompletionBadgeService() => _instance;

  CoreCompletionBadgeService._internal();

  Future<bool> isCoreComplete() async {
    final progressService = TrainingProgressService();
    final coreModules = _getCoreModules();

    for (final moduleId in coreModules) {
      final progress = await progressService.getProgressForModule(moduleId);
      if (progress['theory']! < 1.0 ||
          progress['drills']! < 1.0 ||
          progress['demos']! < 1.0) {
        return false;
      }
    }
    return true;
  }

  Future<List<String>> getCompletedModules() async {
    final progressService = TrainingProgressService();
    final coreModules = _getCoreModules();
    final completedModules = <String>[];

    for (final moduleId in coreModules) {
      final progress = await progressService.getProgressForModule(moduleId);
      if (progress['theory']! == 1.0 &&
          progress['drills']! == 1.0 &&
          progress['demos']! == 1.0) {
        completedModules.add(moduleId);
      }
    }
    return completedModules;
  }

  List<String> _getCoreModules() {
    // Replace with actual logic to fetch Core module IDs
    return ['core_module_1', 'core_module_2', 'core_module_3'];
  }
}
