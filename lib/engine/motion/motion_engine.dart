import 'dart:async';

class MotionCommand {
  MotionCommand({
    required this.type,
    required this.seat,
    required this.amount,
    DateTime? timestamp,
    this.potTier = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  final String type;
  final int seat;
  final double amount;
  final DateTime timestamp;
  final int potTier;
}

class MotionEngine {
  MotionEngine() : _controller = StreamController<MotionCommand>.broadcast();

  final List<MotionCommand> _commands = [];
  final StreamController<MotionCommand> _controller;

  Stream<MotionCommand> get commandStream => _controller.stream;

  Iterable<MotionCommand> get commands => List.unmodifiable(_commands);

  void dispose() {
    _controller.close();
  }

  void _enqueue(String type, int seat, double amount, {int potTier = 0}) {
    final command = MotionCommand(
      type: type,
      seat: seat,
      amount: amount,
      potTier: potTier,
    );
    _commands.add(command);
    _controller.add(command);
  }

  void onBetPlaced(int seat, double amount, {int potTier = 0}) =>
      _enqueue('bet', seat, amount, potTier: potTier);

  void onCall(int seat, double amount, {int potTier = 0}) =>
      _enqueue('call', seat, amount, potTier: potTier);

  void onFold(int seat, {int potTier = 0}) =>
      _enqueue('fold', seat, 0.0, potTier: potTier);

  void onPotPull(int seat, double amount, {int potTier = 0}) =>
      _enqueue('potpull', seat, amount, potTier: potTier);
}
