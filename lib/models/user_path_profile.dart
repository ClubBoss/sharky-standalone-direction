class UserPathProfile {
  const UserPathProfile({
    required this.discipline,
    required this.isRecommended,
    required this.timestamp,
  });

  final String discipline;
  final bool isRecommended;
  final DateTime timestamp;
}
