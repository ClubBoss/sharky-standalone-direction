import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

const _defaultInputRootPathV1 = 'output/motion_evidence/current';
const _defaultOutputRootPathV1 = 'output/motion_media/current';

const act0MotionMediaMomentsV1 = <Act0MotionMediaMomentV1>[
  Act0MotionMediaMomentV1(
    id: 'decision_feedback_reveal',
    frameTimesMs: <int>[0, 80, 180, 320],
  ),
  Act0MotionMediaMomentV1(
    id: 'repair_result_fix_landed',
    frameTimesMs: <int>[0, 80, 180, 320],
  ),
  Act0MotionMediaMomentV1(
    id: 'session_summary_proof_hero',
    frameTimesMs: <int>[0, 80, 180, 320],
  ),
];

class Act0MotionMediaMomentV1 {
  const Act0MotionMediaMomentV1({required this.id, required this.frameTimesMs});

  final String id;
  final List<int> frameTimesMs;
}

class Act0MotionMediaExportResultV1 {
  const Act0MotionMediaExportResultV1({
    required this.momentId,
    required this.path,
    required this.frameCount,
    required this.bytes,
  });

  final String momentId;
  final String path;
  final int frameCount;
  final int bytes;

  Map<String, Object?> toJson() => <String, Object?>{
    'moment': momentId,
    'format': 'gif',
    'path': path,
    'frame_count': frameCount,
    'bytes': bytes,
    'looping': true,
    'source': 'existing_motion_evidence_frames',
  };
}

void main(List<String> args) {
  if (args.contains('--help') || args.contains('-h')) {
    _printUsageV1();
    exit(0);
  }
  if (args.isNotEmpty) {
    _printUsageV1();
    exit(64);
  }

  final inputRoot = Directory(_defaultInputRootPathV1);
  final outputRoot = Directory(_defaultOutputRootPathV1);
  if (!inputRoot.existsSync()) {
    stderr.writeln('Missing motion evidence input root `${inputRoot.path}`.');
    exit(1);
  }
  if (outputRoot.existsSync()) {
    outputRoot.deleteSync(recursive: true);
  }
  outputRoot.createSync(recursive: true);

  final results = <Act0MotionMediaExportResultV1>[];
  for (final moment in act0MotionMediaMomentsV1) {
    results.add(
      exportAct0MotionMediaMomentGifV1(
        inputRoot: inputRoot,
        outputRoot: outputRoot,
        moment: moment,
      ),
    );
  }
  File('${outputRoot.path}/manifest.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'schema': 'act0_motion_media_export_v1', 'render_kind': 'looping_gif_from_existing_motion_frames', 'generated_at': DateTime.now().toUtc().toIso8601String(), 'input_root': inputRoot.path, 'output_root': outputRoot.path, 'entries': results.map((result) => result.toJson()).toList(), 'note': 'Generated motion media is local-only and uncommitted.'})}\n',
  );
  stdout.writeln(outputRoot.path);
}

Act0MotionMediaExportResultV1 exportAct0MotionMediaMomentGifV1({
  required Directory inputRoot,
  required Directory outputRoot,
  required Act0MotionMediaMomentV1 moment,
}) {
  final frames = <img.Image>[];
  for (final frameMs in moment.frameTimesMs) {
    final framePath =
        '${inputRoot.path}/${moment.id}_frame_${frameMs.toString().padLeft(3, '0')}ms.png';
    final frameFile = File(framePath);
    if (!frameFile.existsSync()) {
      throw FileSystemException('Missing motion media source frame', framePath);
    }
    final decoded = img.decodePng(frameFile.readAsBytesSync());
    if (decoded == null) {
      throw FileSystemException(
        'Unreadable motion media source frame',
        framePath,
      );
    }
    frames.add(decoded);
  }
  if (frames.isEmpty) {
    throw FileSystemException(
      'No source frames for motion media export',
      moment.id,
    );
  }

  outputRoot.createSync(recursive: true);
  final encoder = img.GifEncoder(repeat: 0);
  for (var index = 0; index < frames.length; index++) {
    final currentMs = moment.frameTimesMs[index];
    final nextMs = index + 1 < moment.frameTimesMs.length
        ? moment.frameTimesMs[index + 1]
        : currentMs + 500;
    final durationCs = ((nextMs - currentMs).clamp(80, 500) / 10).round();
    encoder.addFrame(frames[index], duration: durationCs);
  }
  final bytes = encoder.finish();
  if (bytes == null || bytes.isEmpty) {
    throw FileSystemException('Failed to encode motion GIF', moment.id);
  }
  final outputPath = '${outputRoot.path}/${moment.id}.gif';
  final outputFile = File(outputPath)..writeAsBytesSync(bytes, flush: true);
  return Act0MotionMediaExportResultV1(
    momentId: moment.id,
    path: outputPath,
    frameCount: frames.length,
    bytes: outputFile.lengthSync(),
  );
}

void _printUsageV1() {
  stdout.writeln(
    'Usage: dart run tools/act0_motion_media_export_v1.dart\n'
    'Reads $_defaultInputRootPathV1 and writes looping GIFs to '
    '$_defaultOutputRootPathV1.',
  );
}
