class PersonaAdviceModel {
  final String moduleId;
  final int readiness;
  final String difficulty;
  final String next;
  final int transferScore;
  final String transferStatus;
  final String? theme;
  final String? moduleDifficulty;
  final bool hasScenario;
  final bool hasLinks;
  final String message;
  final String coach;
  final String nav;
  final String reflection;

  const PersonaAdviceModel({
    required this.moduleId,
    required this.readiness,
    required this.difficulty,
    required this.next,
    required this.transferScore,
    required this.transferStatus,
    required this.theme,
    required this.moduleDifficulty,
    required this.hasScenario,
    required this.hasLinks,
    required this.message,
    required this.coach,
    required this.nav,
    required this.reflection,
  });

  factory PersonaAdviceModel.fromJson(Map<String, dynamic> json) {
    return PersonaAdviceModel(
      moduleId: json['moduleId'] as String,
      readiness: json['readiness'] as int,
      difficulty: json['difficulty'] as String,
      next: json['next'] as String,
      transferScore: json['transferScore'] as int,
      transferStatus: json['transferStatus'] as String,
      theme: json['theme'] as String?,
      moduleDifficulty: json['moduleDifficulty'] as String?,
      hasScenario: json['hasScenario'] as bool,
      hasLinks: json['hasLinks'] as bool,
      message: json['message'] as String,
      coach: json['coach'] as String,
      nav: json['nav'] as String,
      reflection: json['reflection'] as String,
    );
  }
}
