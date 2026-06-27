import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:test/test.dart';

import '../../tools/act0_motion_media_export_v1.dart';

void main() {
  test('exports a looping gif from existing motion frames', () {
    final temp = Directory.systemTemp.createTempSync(
      'act0_motion_media_export_test_',
    );
    addTearDown(() => temp.deleteSync(recursive: true));

    final input = Directory('${temp.path}/frames')..createSync();
    final output = Directory('${temp.path}/media');
    for (final frameMs in <int>[0, 80, 180, 320]) {
      final frame = img.Image(width: 12, height: 12);
      img.fill(frame, color: img.ColorRgb8(frameMs % 255, 80, 160));
      File(
        '${input.path}/decision_feedback_reveal_frame_${frameMs.toString().padLeft(3, '0')}ms.png',
      ).writeAsBytesSync(img.encodePng(frame));
    }

    final result = exportAct0MotionMediaMomentGifV1(
      inputRoot: input,
      outputRoot: output,
      moment: const Act0MotionMediaMomentV1(
        id: 'decision_feedback_reveal',
        frameTimesMs: <int>[0, 80, 180, 320],
      ),
    );

    expect(result.path, endsWith('decision_feedback_reveal.gif'));
    expect(result.frameCount, 4);
    expect(result.bytes, greaterThan(0));
    expect(File(result.path).readAsBytesSync().take(6), 'GIF89a'.codeUnits);
  });

  test('fails before writing gif when a required frame is missing', () {
    final temp = Directory.systemTemp.createTempSync(
      'act0_motion_media_export_missing_test_',
    );
    addTearDown(() => temp.deleteSync(recursive: true));

    final input = Directory('${temp.path}/frames')..createSync();
    final output = Directory('${temp.path}/media');
    final frame = img.Image(width: 12, height: 12);
    img.fill(frame, color: img.ColorRgb8(20, 80, 160));
    File(
      '${input.path}/repair_result_fix_landed_frame_000ms.png',
    ).writeAsBytesSync(img.encodePng(frame));

    expect(
      () => exportAct0MotionMediaMomentGifV1(
        inputRoot: input,
        outputRoot: output,
        moment: const Act0MotionMediaMomentV1(
          id: 'repair_result_fix_landed',
          frameTimesMs: <int>[0, 80],
        ),
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(
      File('${output.path}/repair_result_fix_landed.gif').existsSync(),
      isFalse,
    );
  });
}
