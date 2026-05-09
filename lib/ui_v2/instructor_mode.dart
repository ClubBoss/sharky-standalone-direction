import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/ui_v2/session_playback_engine.dart';

/// Instructor Mode for collaborative session review
///
/// Split-view layout with playback on left and chat/annotations on right.
/// Enables mentors and students to review, annotate, and discuss hands.
class InstructorReviewScreen extends StatefulWidget {
  const InstructorReviewScreen({
    super.key,
    required this.sessionId,
    required this.actions,
    required this.board,
    required this.positions,
    this.playerCount = 6,
  });

  final String sessionId;
  final List<PlaybackAction> actions;
  final List<String> board;
  final List<String> positions;
  final int playerCount;

  @override
  State<InstructorReviewScreen> createState() => _InstructorReviewScreenState();
}

class _InstructorReviewScreenState extends State<InstructorReviewScreen> {
  late final SessionPlaybackEngine _playbackEngine;
  late final AnnotationEngine _annotationEngine;
  final TextEditingController _noteController = TextEditingController();
  bool _showInstructorNotes = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _playbackEngine = SessionPlaybackEngine(
      actions: widget.actions,
      playerCount: widget.playerCount,
    );
    _annotationEngine = AnnotationEngine(sessionId: widget.sessionId);
    _loadAnnotations();
  }

  @override
  void dispose() {
    _playbackEngine.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadAnnotations() async {
    await _annotationEngine.load();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveReview() async {
    setState(() => _isSaving = true);
    try {
      await _annotationEngine.save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Success: review saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: failed to save: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _addNote() {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    final state = _playbackEngine.currentState;
    final actionId = state.currentIndex >= 0 ? state.currentIndex : null;

    _annotationEngine.addComment(
      author: 'Instructor',
      text: text,
      linkedActionId: actionId,
    );

    _noteController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final spacing = brand?.spacingMedium ?? 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Instructor Review - ${widget.sessionId}'),
        actions: [
          IconButton(
            icon: Icon(
              _showInstructorNotes ? Icons.visibility : Icons.visibility_off,
            ),
            tooltip: 'Toggle Instructor Notes',
            onPressed: () {
              setState(() => _showInstructorNotes = !_showInstructorNotes);
            },
          ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save Review',
              onPressed: _saveReview,
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          if (isWide) {
            // Desktop/tablet: side-by-side layout
            return Row(
              children: [
                Expanded(flex: 3, child: _buildPlaybackPanel(context)),
                SizedBox(width: spacing),
                Expanded(flex: 2, child: _buildAnnotationPanel(context)),
              ],
            );
          } else {
            // Mobile: stacked layout
            return Column(
              children: [
                Expanded(flex: 2, child: _buildPlaybackPanel(context)),
                SizedBox(height: spacing),
                Expanded(child: _buildAnnotationPanel(context)),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildPlaybackPanel(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return Container(
      padding: EdgeInsets.all(brand?.spacingMedium ?? 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Playback visualization
          Expanded(
            child: StreamBuilder<PlaybackState>(
              stream: _playbackEngine.states,
              initialData: _playbackEngine.currentState,
              builder: (context, snapshot) {
                final state = snapshot.data ?? _playbackEngine.currentState;
                return _buildPlaybackVisualization(context, state);
              },
            ),
          ),
          SizedBox(height: brand?.spacingMedium ?? 16),
          // Controls
          _buildPlaybackControls(context),
        ],
      ),
    );
  }

  Widget _buildPlaybackVisualization(
    BuildContext context,
    PlaybackState state,
  ) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(brand?.radius ?? 12),
        border: Border.all(
          color: (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Action ${state.currentIndex + 1} / ${widget.actions.length}',
              style: AppTypography.h3.copyWith(
                color: brand?.textPrimary ?? AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 16),
            if (state.currentAction != null)
              Text(
                _describeAction(state.currentAction!),
                style: AppTypography.body.copyWith(
                  color: brand?.primaryBrand ?? Colors.teal,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Pot: ${state.pot}',
              style: AppTypography.label.copyWith(
                color: brand?.textSecondary ?? AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackControls(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: _playbackEngine.states,
      initialData: _playbackEngine.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _playbackEngine.currentState;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AnimatedIconButton(
              icon: Icons.replay,
              tooltip: 'Reset',
              onPressed: () {
                _playbackEngine.reset();
                setState(() {});
              },
            ),
            const SizedBox(width: 8),
            _AnimatedIconButton(
              icon: state.isPlaying ? Icons.pause : Icons.play_arrow,
              tooltip: state.isPlaying ? 'Pause' : 'Play',
              iconSize: 32,
              onPressed: () {
                _playbackEngine.toggle();
                setState(() {});
              },
            ),
            const SizedBox(width: 8),
            _AnimatedIconButton(
              icon: Icons.skip_next,
              tooltip: 'Step Forward',
              onPressed: () {
                _playbackEngine.stepForward();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnnotationPanel(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final spacing = brand?.spacingMedium ?? 16.0;

    return Container(
      padding: EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(brand?.radius ?? 12),
        border: Border.all(
          color: (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Annotations', style: AppTypography.h3),
              Chip(
                label: Text(
                  '${_annotationEngine.comments.length}',
                  style: AppTypography.caption.copyWith(
                    color: brand?.primaryBrand ?? Colors.teal,
                  ),
                ),
                backgroundColor: (brand?.primaryBrand ?? Colors.teal)
                    .withValues(alpha: 0.1),
              ),
            ],
          ),
          SizedBox(height: spacing),
          // Comment list
          Expanded(child: _buildCommentList(context)),
          SizedBox(height: spacing),
          // Add note input
          _buildNoteInput(context),
        ],
      ),
    );
  }

  Widget _buildCommentList(BuildContext context) {
    final filteredComments = _showInstructorNotes
        ? _annotationEngine.comments
        : _annotationEngine.comments
              .where((c) => c.author.toLowerCase() != 'instructor')
              .toList();
    if (filteredComments.isEmpty) {
      return Center(
        child: Text(
          '📝 No annotations yet',
          style: AppTypography.body.copyWith(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredComments.length,
      itemBuilder: (context, index) {
        final comment = filteredComments[index];
        return _CommentCard(
          comment: comment,
          onDelete: () {
            setState(() {
              _annotationEngine.removeComment(comment.id);
            });
          },
        );
      },
    );
  }

  Widget _buildNoteInput(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Add a note...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(brand?.radius ?? 12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            maxLines: 2,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _addNote(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send),
          tooltip: 'Add Note',
          onPressed: _addNote,
          color: brand?.primaryBrand ?? Colors.teal,
        ),
      ],
    );
  }

  String _describeAction(PlaybackAction action) {
    final seat = 'Seat ${action.seat + 1}';
    switch (action.type) {
      case PlaybackActionType.bet:
        return '$seat bets ${action.amount}';
      case PlaybackActionType.raise:
        return '$seat raises to ${action.amount}';
      case PlaybackActionType.call:
        return '$seat calls ${action.amount}';
      case PlaybackActionType.fold:
        return '$seat folds';
      case PlaybackActionType.check:
        return '$seat checks';
      case PlaybackActionType.win:
        return '$seat wins ${action.amount}';
      case PlaybackActionType.none:
        return 'Waiting...';
    }
  }
}

/// Annotation Engine
///
/// Manages instructor comments with persistent storage.
class AnnotationEngine {
  AnnotationEngine({required this.sessionId});

  final String sessionId;
  final List<ReviewComment> comments = [];

  Future<void> load() async {
    try {
      final file = await _getReviewFile();
      if (!await file.exists()) return;

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final commentsJson = json['comments'] as List?;

      if (commentsJson != null) {
        comments.clear();
        for (final item in commentsJson) {
          if (item is Map<String, dynamic>) {
            comments.add(ReviewComment.fromJson(item));
          }
        }
        // Sort by timestamp for deterministic ordering
        comments.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }
    } catch (_) {
      // Ignore load errors
    }
  }

  Future<void> save() async {
    final file = await _getReviewFile();
    await file.parent.create(recursive: true);

    final json = {
      'sessionId': sessionId,
      'savedAt': DateTime.now().toIso8601String(),
      'comments': comments.map((c) => c.toJson()).toList(),
    };

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  }

  void addComment({
    required String author,
    required String text,
    int? linkedActionId,
  }) {
    final comment = ReviewComment(
      id: _generateId(),
      author: author,
      text: text,
      timestamp: DateTime.now(),
      linkedActionId: linkedActionId,
    );
    comments.add(comment);
    // Keep sorted by timestamp
    comments.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void removeComment(String id) {
    comments.removeWhere((c) => c.id == id);
  }

  Future<File> _getReviewFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/export/sessions/${sessionId}_review.json');
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${comments.length}';
  }
}

/// Review Comment model
class ReviewComment {
  const ReviewComment({
    required this.id,
    required this.author,
    required this.text,
    required this.timestamp,
    this.linkedActionId,
  });

  final String id;
  final String author;
  final String text;
  final DateTime timestamp;
  final int? linkedActionId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'linkedActionId': linkedActionId,
  };

  factory ReviewComment.fromJson(Map<String, dynamic> json) {
    return ReviewComment(
      id: json['id'] as String,
      author: json['author'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      linkedActionId: json['linkedActionId'] as int?,
    );
  }
}

/// Comment Card widget
class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment, required this.onDelete});

  final ReviewComment comment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final isInstructor = comment.author.toLowerCase() == 'instructor';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isInstructor
              ? (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(brand?.radius ?? 12),
          border: Border.all(
            color: isInstructor
                ? (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isInstructor ? Icons.school : Icons.person,
                      size: 16,
                      color: isInstructor
                          ? (brand?.primaryBrand ?? Colors.teal)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comment.author,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isInstructor
                            ? (brand?.primaryBrand ?? Colors.teal)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (comment.linkedActionId != null)
                      Chip(
                        label: Text(
                          '#${comment.linkedActionId! + 1}',
                          style: AppTypography.caption,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.text, style: AppTypography.body),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(comment.timestamp),
              style: AppTypography.caption.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Animated Icon Button with tap feedback
class _AnimatedIconButton extends StatefulWidget {
  const _AnimatedIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconSize = 24,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double iconSize;

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 - (_controller.value * 0.15);
        final opacity = 1.0 - (_controller.value * 0.3);
        return Transform.scale(
          scale: scale,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: IconButton(
        icon: Icon(widget.icon),
        tooltip: widget.tooltip,
        iconSize: widget.iconSize,
        onPressed: _handleTap,
      ),
    );
  }
}
