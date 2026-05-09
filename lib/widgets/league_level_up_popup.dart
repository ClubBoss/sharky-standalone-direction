import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart' show navigatorKey;
import '../models/xp_league.dart';

class LeagueLevelUpPopup {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(XpLeague league) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    _entry?.remove();
    _timer?.cancel();

    final overlay = Overlay.of(context, rootOverlay: true);

    final entry = OverlayEntry(
      builder: (_) => _LeaguePopupContent(league: league, onDismissed: _clear),
    );

    overlay.insert(entry);
    _entry = entry;
  }

  static void _clear() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _LeaguePopupContent extends StatefulWidget {
  final XpLeague league;
  final VoidCallback onDismissed;

  const _LeaguePopupContent({required this.league, required this.onDismissed});

  @override
  State<_LeaguePopupContent> createState() => _LeaguePopupContentState();
}

class _LeaguePopupContentState extends State<_LeaguePopupContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    LeagueLevelUpPopup._timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.reverse().whenComplete(() {
          if (mounted) widget.onDismissed();
        });
      } else {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('ru');
    final title = isRu ? 'Новая лига!' : 'New League!';
    final label = widget.league.label(isRu: isRu);
    final emoji = widget.league.emoji();

    return IgnorePointer(
      ignoring: true,
      child: Positioned.fill(
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: FadeTransition(
              opacity: _controller,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.75 * 255).round()),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.league.color().withAlpha(
                        (0.8 * 255).round(),
                      ),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha((0.85 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
