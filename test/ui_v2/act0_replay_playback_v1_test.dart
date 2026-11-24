import 'package:flutter_test/flutter_test.dart';

import '../../lib/ui_v2/act0_shell/act0_replay_playback_v1.dart';

void main() {
  const oneSecond = Duration(seconds: 1);
  const halfSecond = Duration(milliseconds: 500);

  test('manual steps clamp at the first and last events', () {
    final playback = Act0ReplayPlaybackV1(stepCount: 2);
    playback.stepBack();
    expect(playback.currentIndex, 0);
    playback.stepForward();
    playback.stepForward();
    expect(playback.currentIndex, 1);
    playback.stepBack();
    expect(playback.currentIndex, 0);
  });

  test('seek clamps, pauses, and clears the pending interval', () {
    final playback = Act0ReplayPlaybackV1(stepCount: 4);
    playback.play();
    playback.tick(halfSecond);
    playback.seekTo(-5);
    expect(playback.currentIndex, 0);
    expect(playback.isPlaying, isFalse);
    playback.play();
    playback.tick(halfSecond);
    expect(playback.currentIndex, 0);
    playback.seekTo(99);
    expect(playback.currentIndex, 3);
    expect(playback.isPlaying, isFalse);
  });

  test('playback consumes whole steps and pauses at the end', () {
    final playback = Act0ReplayPlaybackV1(stepCount: 5);
    playback.toggle();
    playback.tick(const Duration(milliseconds: 2500));
    expect(playback.currentIndex, 2);
    expect(playback.isPlaying, isTrue);
    playback.tick(halfSecond);
    expect(playback.currentIndex, 3);
    playback.tick(const Duration(seconds: 10));
    expect(playback.currentIndex, 4);
    expect(playback.isPlaying, isFalse);
    playback.play();
    expect(playback.isPlaying, isFalse);
  });

  test('pause ignores elapsed time and resume retains the partial step', () {
    final playback = Act0ReplayPlaybackV1(stepCount: 3);
    playback.play();
    playback.tick(halfSecond);
    playback.toggle();
    playback.tick(oneSecond);
    expect(playback.currentIndex, 0);
    playback.toggle();
    playback.tick(halfSecond);
    expect(playback.currentIndex, 1);
  });

  test('2× halves and 0.5× doubles the configured step duration', () {
    final playback = Act0ReplayPlaybackV1(
      stepCount: 4,
      baseStepDuration: halfSecond,
    );
    playback.setSpeed(2);
    playback.play();
    playback.tick(const Duration(milliseconds: 249));
    expect(playback.currentIndex, 0);
    playback.tick(const Duration(milliseconds: 1));
    expect(playback.currentIndex, 1);
    playback.setSpeed(0.5);
    playback.tick(halfSecond);
    expect(playback.currentIndex, 1);
    playback.tick(halfSecond);
    expect(playback.currentIndex, 2);
    expect(() => playback.setSpeed(1.5), throwsArgumentError);
    expect(playback.speed, 0.5);
    playback.setSpeed(1);
    playback.tick(halfSecond);
    expect(playback.currentIndex, 3);
  });

  test('Reduce Motion disables animation hints during playback', () {
    final playback = Act0ReplayPlaybackV1(stepCount: 2, reduceMotion: true);
    expect(Act0ReplayPlaybackV1(stepCount: 2).shouldAnimate, isTrue);
    playback.play();
    expect(playback.shouldAnimate, isFalse);
    playback.tick(oneSecond);
    expect(playback.currentIndex, 1);
    expect(playback.shouldAnimate, isFalse);
  });

  test('reset pauses at the first step and keeps the selected speed', () {
    final playback = Act0ReplayPlaybackV1(stepCount: 4);
    playback.setSpeed(2);
    playback.play();
    playback.tick(oneSecond);
    playback.reset();
    expect(playback.currentIndex, 0);
    expect(playback.isPlaying, isFalse);
    expect(playback.speed, 2);
  });

  test('semantics reports the one-based step, speed, and playing state', () {
    final playback = Act0ReplayPlaybackV1(stepCount: 3);
    expect(playback.semanticsLabel, 'Step 1 of 3 · speed 1×, Paused');
    playback.setSpeed(0.5);
    playback.play();
    playback.tick(const Duration(seconds: 2));
    expect(playback.semanticsLabel, 'Step 2 of 3 · speed 0.5×, Playing');
  });

  test('empty replay stays paused and safely ignores every action', () {
    final playback = Act0ReplayPlaybackV1(stepCount: 0);
    playback.play();
    playback.tick(oneSecond);
    playback.pause();
    playback.toggle();
    playback.stepForward();
    playback.stepBack();
    playback.seekTo(5);
    playback.reset();
    playback.setSpeed(2);
    expect(playback.currentIndex, 0);
    expect(playback.isPlaying, isFalse);
    expect(playback.speed, 1);
    expect(playback.semanticsLabel, 'Step 0 of 0 · speed 1×, Paused');
  });
}
