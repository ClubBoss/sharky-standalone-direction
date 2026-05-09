enum PuzzleAction { fold, call, raise }

class PokerPuzzle {
  final String id;
  final List<String> heroCards;
  final List<String> boardCards;
  final String villainAction;
  final int potSize;
  final PuzzleAction correctAction;
  final String explanation;

  const PokerPuzzle({
    required this.id,
    required this.heroCards,
    required this.boardCards,
    required this.villainAction,
    required this.potSize,
    required this.correctAction,
    required this.explanation,
  });

  factory PokerPuzzle.fromJson(Map<String, dynamic> json) {
    return PokerPuzzle(
      id: json['id'] as String,
      heroCards: List<String>.from(json['heroCards'] as List),
      boardCards: List<String>.from(json['boardCards'] as List),
      villainAction: json['villainAction'] as String,
      potSize: json['potSize'] as int,
      correctAction: PuzzleAction.values.firstWhere(
        (e) => e.name == json['correctAction'],
      ),
      explanation: json['explanation'] as String,
    );
  }
}
