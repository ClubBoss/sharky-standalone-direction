/// Service that tracks the most recent training session's mistake spots
/// and enables instant retry of those mistakes via ReviewLauncherService.
///
/// This service provides a lightweight, short-loop error correction flow:
/// after completing a session with mistakes, the user can immediately retry
/// those specific spots without navigating away from the recap popup.
///
/// **Design principles:**
/// - In-memory only (no persistence): mistakes are cleared after review or app restart
/// - Single session scope: only tracks the most recent session's mistakes
/// - Minimal friction: ≥1 mistake → show CTA → tap → launch review
///
/// **Integration points:**
/// - TrainingSessionService.complete(): records mistake spot IDs
/// - XpService.awardSessionXp(): checks shouldShowCTA() and provides callback
/// - SessionRecapPopup: displays "Review mistakes" button when enabled
/// - ReviewLauncherService: launches the actual review session
class PostSessionReviewService {
  PostSessionReviewService._();
  static final instance = PostSessionReviewService._();

  /// In-memory storage for most recent session's mistake spot IDs
  List<String> _mistakeSpotIds = [];

  /// Records the mistake spot IDs from the most recent training session.
  ///
  /// This should be called immediately after a session completes, passing
  /// the list of spot IDs where the user made mistakes.
  ///
  /// Example:
  /// ```dart
  /// final mistakeIds = [
  ///   for (final e in session.results.entries)
  ///     if (!e.value) e.key,
  /// ];
  /// PostSessionReviewService.instance.recordSessionMistakes(mistakeIds);
  /// ```
  void recordSessionMistakes(List<String> spotIds) {
    _mistakeSpotIds = List.from(spotIds);
  }

  /// Returns the list of mistake spot IDs from the most recent session.
  ///
  /// Returns an empty list if:
  /// - No session has been completed yet
  /// - The most recent session had no mistakes
  /// - clearMistakes() was called
  /// - App was restarted (in-memory only)
  List<String> getMistakeSpots() => List.unmodifiable(_mistakeSpotIds);

  /// Returns true if there are ≥1 mistake spots from the most recent session.
  ///
  /// Use this to determine whether to show the "Review mistakes" CTA in
  /// the session recap popup.
  bool shouldShowCTA() => _mistakeSpotIds.isNotEmpty;

  /// Clears all stored mistake spot IDs.
  ///
  /// Should be called:
  /// - After the user launches a review session for these mistakes
  /// - When the user dismisses the recap popup without reviewing
  void clearMistakes() {
    _mistakeSpotIds = [];
  }

  /// Returns the count of mistake spots in the most recent session.
  int getMistakeCount() => _mistakeSpotIds.length;
}
