import 'dart:async';

import 'package:flutter/material.dart';

import 'session_medal_popup.dart';

class SessionRecapPopup {
  static OverlayEntry? _entry;
  static Timer? _timer;
  static GlobalKey<NavigatorState>? navigatorKey;

  static Future<void> show({
    required int sessionXp,
    required int durationMinutes,
    List<String>? tags,
    int? currentStreak,
    List<SessionMedal>? medals,
    bool showReviewReminder = false,
    VoidCallback? onReviewRequested,
  }) async {
    final context = navigatorKey?.currentContext;
    if (context == null) return;

    _entry?.remove();
    _timer?.cancel();

    final overlay = Overlay.of(context, rootOverlay: true);

    final entry = OverlayEntry(
      builder: (_) => _SessionRecapContent(
        sessionXp: sessionXp,
        durationMinutes: durationMinutes,
        tags: tags ?? const [],
        currentStreak: currentStreak ?? 0,
        medals: medals ?? const [],
        onDismissed: _clear,
        showReviewReminder: showReviewReminder,
        onReviewRequested: onReviewRequested,
      ),
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

class _SessionRecapContent extends StatefulWidget {
  final int sessionXp;
  final int durationMinutes;
  final List<String> tags;
  final int currentStreak;
  final List<SessionMedal> medals;
  final VoidCallback onDismissed;
  final bool showReviewReminder;
  final VoidCallback? onReviewRequested;

  const _SessionRecapContent({
    required this.sessionXp,
    required this.durationMinutes,
    required this.tags,
    required this.currentStreak,
    required this.medals,
    required this.onDismissed,
    required this.showReviewReminder,
    this.onReviewRequested,
  });

  @override
  State<_SessionRecapContent> createState() => _SessionRecapContentState();
}

class _SessionRecapContentState extends State<_SessionRecapContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    SessionRecapPopup._timer = Timer(const Duration(seconds: 5), () {
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
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final hasMedals = widget.medals.isNotEmpty;
    final title = hasMedals
        ? (isRu ? 'Отличная сессия!' : 'Great session!')
        : (isRu ? 'Сессия завершена' : 'Session complete');
    final xpLabel = isRu ? 'XP' : 'XP';
    final durLabel = isRu ? 'Длительность' : 'Duration';
    final minLabel = isRu ? 'мин' : 'min';
    final streakLabel = isRu ? 'Текущая серия' : 'Current streak';
    final daysLabel = isRu ? 'дней' : 'days';
    final tagsLabel = isRu ? 'Теги' : 'Tags';
    final okLabel = isRu ? 'ОК' : 'OK';
    final reviewLabel = isRu ? 'Повторить ошибки' : 'Review mistakes';

    return Positioned.fill(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: FadeTransition(
            opacity: _controller,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
              ),
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.85 * 255).round()),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withAlpha(60),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _statChip(
                          '$durLabel: ',
                          '${widget.durationMinutes} $minLabel',
                        ),
                        const SizedBox(width: 8),
                        _statChip('$xpLabel: ', '${widget.sessionXp}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (widget.currentStreak > 0)
                      _textRow(
                        '$streakLabel: ',
                        '${widget.currentStreak} $daysLabel',
                      ),
                    if (widget.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _textRow('$tagsLabel: ', widget.tags.join(', ')),
                    ],
                    if (widget.medals.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 6,
                        children: widget.medals
                            .map((m) => _MedalChip(medal: m))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.showReviewReminder)
                          FilledButton(
                            onPressed: () {
                              widget.onReviewRequested?.call();
                              SessionRecapPopup._timer?.cancel();
                              SessionRecapPopup._timer = null;
                              _controller.reverse().whenComplete(() {
                                if (mounted) widget.onDismissed();
                              });
                            },
                            child: Text(reviewLabel),
                          ),
                        if (widget.showReviewReminder) const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            SessionRecapPopup._timer?.cancel();
                            SessionRecapPopup._timer = null;
                            _controller.reverse().whenComplete(() {
                              if (mounted) widget.onDismissed();
                            });
                          },
                          child: Text(
                            okLabel,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(20),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withAlpha(60)),
    ),
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _textRow(String label, String value) => RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextSpan(
          text: value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _MedalChip extends StatelessWidget {
  final SessionMedal medal;
  const _MedalChip({required this.medal});

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: medal.color.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: medal.color.withAlpha(120)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(medal.icon, color: medal.color, size: 18),
          const SizedBox(width: 8),
          Text(
            medal.title(isRu: isRu),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
