import 'package:flutter/foundation.dart';

/// Singleton audio service for managing game sound effects.
/// Uses fire-and-forget pattern for non-blocking audio playback.
///
/// NOTE: Requires 'audioplayers' package in pubspec.yaml:
/// dependencies:
///   audioplayers: ^5.0.0
class AudioService {
  AudioService._internal();

  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;

  // Dynamic import to avoid compile errors if audioplayers not installed
  dynamic _audioPlayer;
  bool _isInitialized = false;
  bool _isMuted = false;
  static void Function(String sfx)? onTestPlayUiSfx;

  /// Asset paths for sound effects
  static const String _betSound = 'assets/audio/bet.mp3';
  static const String _foldSound = 'assets/audio/fold.mp3';
  static const String _winSound = 'assets/audio/win.mp3';
  static const String _checkSound = 'assets/audio/check.mp3';

  /// Initialize and preload audio assets
  Future<void> preload() async {
    if (_isInitialized) return;

    try {
      // Try to dynamically import audioplayers
      // This will fail gracefully if package is not installed
      final audioModule = await _tryImportAudioPlayers();

      if (audioModule != null) {
        _audioPlayer = audioModule;
        _isInitialized = true;
        debugPrint('✅ AudioService initialized with audioplayers');
      } else {
        debugPrint(
          '⚠️ AudioService: audioplayers not available - using debug mode',
        );
        _isInitialized = true; // Still mark as initialized for debug logging
      }
    } catch (e) {
      debugPrint('⚠️ AudioService initialization failed: $e');
      _isInitialized = true; // Continue without audio
    }
  }

  /// Attempt to import audioplayers package
  Future<dynamic> _tryImportAudioPlayers() async {
    try {
      // In production, this would be:
      // import 'package:audioplayers/audioplayers.dart';
      // return AudioPlayer();

      // For now, return null to trigger debug mode
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Play betting/raising sound (crisp chip stacking)
  Future<void> playBet() async {
    await _playSound('BET', _betSound);
  }

  Future<void> playUiSfx(String sfx) async {
    final testHandler = onTestPlayUiSfx;
    if (testHandler != null) {
      testHandler(sfx);
      return;
    }
    switch (sfx) {
      case 'tap':
      case 'check':
        await playCheck();
        return;
      case 'success':
      case 'win':
        await playWin();
        return;
      case 'error':
      case 'fold':
        await playFold();
        return;
      case 'bet':
      case 'raise':
        await playBet();
        return;
      default:
        await _playSound('UI_$sfx', _checkSound);
    }
  }

  /// Play fold sound (card sliding/muffled)
  Future<void> playFold() async {
    await _playSound('FOLD', _foldSound);
  }

  /// Play win sound (chips sliding to player)
  Future<void> playWin() async {
    await _playSound('WIN', _winSound);
  }

  /// Play check sound (distinct knock)
  Future<void> playCheck() async {
    await _playSound('CHECK', _checkSound);
  }

  /// Fire-and-forget sound playback with graceful error handling
  Future<void> _playSound(String soundName, String assetPath) async {
    if (_isMuted) {
      debugPrint('🔇 MUTED: $soundName');
      return;
    }

    if (!_isInitialized) {
      await preload();
    }

    try {
      debugPrint('🔊 PLAY SOUND: $soundName ($assetPath)');

      if (_audioPlayer != null) {
        // In production with audioplayers:
        // await _audioPlayer.play(AssetSource(assetPath));

        debugPrint('   [Audio would play from $assetPath]');
      } else {
        debugPrint('   [Debug mode: No audio player available]');
      }
    } catch (e) {
      // Fail silently - audio should never crash the app
      debugPrint('⚠️ Failed to play $soundName: $e');
    }
  }

  /// Toggle mute state
  void toggleMute() {
    _isMuted = !_isMuted;
    debugPrint(_isMuted ? '🔇 Audio MUTED' : '🔊 Audio UNMUTED');
  }

  /// Set mute state explicitly
  void setMuted(bool muted) {
    _isMuted = muted;
    debugPrint(_isMuted ? '🔇 Audio MUTED' : '🔊 Audio UNMUTED');
  }

  /// Check if audio is muted
  bool get isMuted => _isMuted;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Dispose resources (call on app termination)
  Future<void> dispose() async {
    try {
      if (_audioPlayer != null) {
        // In production: await _audioPlayer.dispose();
        debugPrint('♻️ AudioService disposed');
      }
    } catch (e) {
      debugPrint('⚠️ AudioService disposal error: $e');
    }
  }
}
