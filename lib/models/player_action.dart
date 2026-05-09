/// Canonical list of player actions supported across the analyzer.
///
/// The order matches legacy UI cycling logic, so avoid reordering existing
/// entries. New actions should be appended to keep compatibility with stored
/// indices.
enum PlayerAction { none, fold, push, call, raise, post, check }

extension PlayerActionParsing on PlayerAction {
  /// Maps a lowercase string to a [PlayerAction]. Unknown values fallback to
  /// [PlayerAction.none].
  static PlayerAction fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'fold':
        return PlayerAction.fold;
      case 'push':
      case 'allin':
      case 'all-in':
        return PlayerAction.push;
      case 'call':
        return PlayerAction.call;
      case 'raise':
      case 'bet':
        return PlayerAction.raise;
      case 'post':
      case 'postblind':
        return PlayerAction.post;
      case 'check':
        return PlayerAction.check;
      default:
        return PlayerAction.none;
    }
  }

  /// Short, user-facing label used in UI badges.
  String get label {
    switch (this) {
      case PlayerAction.fold:
        return 'Fold';
      case PlayerAction.push:
        return 'Push';
      case PlayerAction.call:
        return 'Call';
      case PlayerAction.raise:
        return 'Raise';
      case PlayerAction.post:
        return 'Post';
      case PlayerAction.check:
        return 'Check';
      case PlayerAction.none:
        return '-';
    }
  }
}
