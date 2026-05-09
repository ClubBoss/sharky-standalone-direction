import 'dart:async';

import 'package:flutter/material.dart';

class PersonaReactionsOverlayController extends ChangeNotifier {
  PersonaReactionsOverlayController._();

  static final PersonaReactionsOverlayController instance =
      PersonaReactionsOverlayController._();

  PersonaReactionState? _state;
  Timer? _timer;

  PersonaReactionState? get state => _state;

  void showCelebrate(String message) {
    _setState(
      PersonaReactionState(
        mood: PersonaReactionMood.celebrate,
        headline: 'Sharky celebrates!',
        message: message,
      ),
    );
  }

  void showEncourage(String message) {
    _setState(
      PersonaReactionState(
        mood: PersonaReactionMood.encourage,
        headline: 'Sharky encourages you',
        message: message,
      ),
    );
  }

  void showThinking(String message) {
    _setState(
      PersonaReactionState(
        mood: PersonaReactionMood.thinking,
        headline: 'Sharky is thinking',
        message: message,
      ),
    );
  }

  void _setState(PersonaReactionState state) {
    _state = state;
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      _state = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class PersonaReactionsOverlay extends StatelessWidget {
  const PersonaReactionsOverlay({
    super.key,
    this.controller = PersonaReactionsOverlayController.instance,
  });

  final PersonaReactionsOverlayController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        if (state == null) {
          return const SizedBox.shrink();
        }
        final colors = _moodColors(state.mood, Theme.of(context));
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.headline,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: colors.text),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _PersonaOverlayColors _moodColors(PersonaReactionMood mood, ThemeData theme) {
    switch (mood) {
      case PersonaReactionMood.celebrate:
        return _PersonaOverlayColors(
          background: const Color(0xFF0A2E36),
          border: const Color(0xFF15CDA8),
          text: const Color(0xFF15CDA8),
        );
      case PersonaReactionMood.encourage:
        return _PersonaOverlayColors(
          background: const Color(0xFF2E1F27),
          border: const Color(0xFFFF7F50),
          text: const Color(0xFFFFD9C0),
        );
      case PersonaReactionMood.thinking:
        return _PersonaOverlayColors(
          background: theme.cardColor,
          border: theme.focusColor,
          text: theme.colorScheme.onSurface,
        );
    }
  }
}

class PersonaReactionState {
  const PersonaReactionState({
    required this.mood,
    required this.headline,
    required this.message,
  });

  final PersonaReactionMood mood;
  final String headline;
  final String message;
}

enum PersonaReactionMood { celebrate, encourage, thinking }

class _PersonaOverlayColors {
  const _PersonaOverlayColors({
    required this.background,
    required this.border,
    required this.text,
  });

  final Color background;
  final Color border;
  final Color text;
}
