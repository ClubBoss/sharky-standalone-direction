import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/beta_playtest_service.dart';
import 'package:poker_analyzer/services/emotion_adaptive_engine.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

/// Bottom-sheet panel for collecting quick beta feedback.
class UiV2FeedbackPanel extends StatefulWidget {
  const UiV2FeedbackPanel({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const UiV2FeedbackPanel(),
    );
  }

  @override
  State<UiV2FeedbackPanel> createState() => _UiV2FeedbackPanelState();
}

class _UiV2FeedbackPanelState extends State<UiV2FeedbackPanel> {
  final TextEditingController _controller = TextEditingController();
  String? _rating;
  bool _submitting = false;
  final EmotionAdaptiveEngine _engine = EmotionAdaptiveEngine.instance;

  static const _ratings = [
    _FeedbackRating(id: 'positive', label: ':) Great'),
    _FeedbackRating(id: 'neutral', label: ':| Neutral'),
    _FeedbackRating(id: 'negative', label: ':( Needs work'),
  ];

  @override
  void initState() {
    super.initState();
    BetaPlaytestService.logEvent('feedback', 'open_panel');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final padding = EdgeInsets.only(
      left: brand?.spacingMedium ?? 16,
      right: brand?.spacingMedium ?? 16,
      bottom:
          MediaQuery.of(context).viewInsets.bottom +
          (brand?.spacingMedium ?? 16),
      top: brand?.spacingMedium ?? 16,
    );
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Quick Feedback',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.merge(AppTypography.h1),
          ),
          const SizedBox(height: 12),
          Text(
            _engine.getAdaptiveReaction(
              'How was your latest session?',
              sentiment: _currentSentimentSeed(),
              consistency: _currentConsistencySeed(),
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.merge(AppTypography.body),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _ratings.map((rating) {
              final selected = _rating == rating.id;
              return ChoiceChip(
                label: Text(rating.label),
                selected: selected,
                onSelected: (value) {
                  setState(() => _rating = value ? rating.id : null);
                  BetaPlaytestService.logButtonTap(
                    'feedback_rating_${rating.id}',
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Anything we should know?',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) =>
                BetaPlaytestService.logEvent('feedback', 'note_typing'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_rating == null && _controller.text.trim().isEmpty) {
      BetaPlaytestService.logEvent('feedback', 'submit_blocked');
      return;
    }
    setState(() => _submitting = true);
    await BetaPlaytestService.submitFeedback(
      rating: _rating ?? 'unknown',
      comment: _controller.text.trim(),
    );
    await BetaPlaytestService.logEvent(
      'feedback',
      'submitted',
      details: {
        'rating': _rating ?? 'unknown',
        'has_comment': _controller.text.trim().isNotEmpty,
      },
    );
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _engine.getAdaptiveReaction(
              'Thanks for the feedback!',
              sentiment: _currentSentimentSeed(),
              consistency: _currentConsistencySeed(),
            ),
          ),
        ),
      );
    }
  }

  double _currentSentimentSeed() {
    switch (_rating) {
      case 'positive':
        return 0.7;
      case 'negative':
        return -0.6;
      case 'neutral':
        return 0.1;
      default:
        return _controller.text.trim().isEmpty ? 0.0 : 0.2;
    }
  }

  double _currentConsistencySeed() {
    if (_rating == null && _controller.text.trim().isEmpty) {
      return 0.8;
    }
    if (_rating == 'negative') {
      return 0.4;
    }
    if (_controller.text.trim().length > 80) {
      return 0.6;
    }
    return 0.7;
  }
}

class _FeedbackRating {
  const _FeedbackRating({required this.id, required this.label});

  final String id;
  final String label;
}
