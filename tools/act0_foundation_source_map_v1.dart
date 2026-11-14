// Read-only source inventory for CUR-01.a. No Flutter initialization or runtime
// simulation; the existing copy parser supplies authored goals and task IDs.
import 'dart:convert';
import 'dart:io';

import '_lib/act0_content_copy_source_parser.dart';

const _base = 'ccd263c4ed9c03f0a09751b19048dc6030ffbbcf';
const _state = 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart';
const _preview = 'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
const _parser = 'tools/_lib/act0_content_copy_source_parser.dart';
const _jsonPath = 'docs/content/FOUNDATION_W1_W4_SOURCE_MAP_v1.json';
const _mdPath = 'docs/content/FOUNDATION_W1_W4_SOURCE_MAP_v1.md';

String _blob(String path) {
  final result = Process.runSync('git', ['hash-object', path]);
  if (result.exitCode != 0) throw StateError('Cannot identify source: $path');
  return (result.stdout as String).trim();
}

int? _line(String source, String needle) {
  final index = source.indexOf(needle);
  return index == -1
      ? null
      : '\n'.allMatches(source.substring(0, index)).length + 1;
}

Map<String, Object?> buildFoundationSourceMapV1() {
  final stateBlob = _blob(_state);
  final previewBlob = _blob(_preview);
  if (stateBlob != '3fcc919efb9cb0aa48940514c60d800c3362d038' ||
      previewBlob != 'e2f837841997402cbd4c08a6a308587c080ae480') {
    throw StateError(
      'Source revision changed; review and version the source map.',
    );
  }
  final source = File(_state).readAsStringSync();
  final preview = File(_preview).readAsStringSync();
  final helperLessonIds = RegExp(
    r"_lessonFromTasksV1\(\s*lessonId:\s*'([^']+)'",
  ).allMatches(source).map((m) => m.group(1)).toSet();
  final worlds = Act0SourceParser(source)
      .parse()
      .worlds
      .where((w) => w.worldNumber >= 1 && w.worldNumber <= 4)
      .toList();
  if (worlds.length != 4)
    throw StateError('Foundation world coverage changed.');
  final taskIds = <String>{};
  final lessonIds = <String>{};
  final gaps = <Map<String, String>>[];
  final rows = <Map<String, Object?>>[];
  for (var wi = 0; wi < worlds.length; wi += 1) {
    final world = worlds[wi];
    if (world.worldNumber != wi + 1 || world.lessons.isEmpty) {
      throw StateError('Foundation world order/lessons changed.');
    }
    final earlierLessons = <String>[];
    final lessons = <Map<String, Object?>>[];
    for (final lesson in world.lessons) {
      if (!lessonIds.add(lesson.lessonId) ||
          lesson.subtitle.trim().isEmpty ||
          lesson.tasks.isEmpty) {
        throw StateError('Duplicate lesson or missing authored goal/tasks.');
      }
      final tasks = <Map<String, Object?>>[];
      for (var ti = 0; ti < lesson.tasks.length; ti += 1) {
        final task = lesson.tasks[ti];
        if (!taskIds.add(task.taskId))
          throw StateError('Task ID collision: ${task.taskId}');
        final helper = helperLessonIds.contains(lesson.lessonId);
        final prefix = '${lesson.lessonId}_';
        if (helper && !task.taskId.startsWith(prefix))
          throw StateError('Missing helper prefix.');
        final sourceTaskId = helper
            ? task.taskId.substring(prefix.length)
            : task.taskId;
        final line = _line(source, "taskId: '$sourceTaskId'");
        if (line == null)
          throw StateError('Missing source task declaration: $sourceTaskId');
        final unknown = <String>[
          if (task.runnerName == null)
            'runner expression not resolved by source parser',
          if (task.question == null)
            'runner question not resolved by source parser',
          if (task.feedbackReason == null)
            'runner feedback not resolved by source parser',
          if (task.phase == 'unknown') 'phase not resolved by source parser',
        ];
        if (unknown.isNotEmpty)
          gaps.add({'task_id': task.taskId, 'gap': unknown.join('; ')});
        tasks.add({
          'task_id': task.taskId,
          'title': task.title,
          'authored_phase': task.phase,
          'authored_step_kind': task.stepKind,
          'runner_reference': task.runnerName,
          'runner_question_source': task.question,
          'runner_feedback_source': task.feedbackReason,
          'source_task_id': sourceTaskId,
          'source_line': line,
          'source_helper_retitled': helper,
          'earlier_task_ids_in_lesson': lesson.tasks
              .take(ti)
              .map((t) => t.taskId)
              .toList(),
          'runtime_independence_unseen_and_human': 'NOT_VERIFIED_BY_SOURCE_MAP',
          'source_copy_gaps': unknown,
        });
      }
      lessons.add({
        'lesson_id': lesson.lessonId,
        'title': lesson.title,
        'authored_goal': lesson.subtitle,
        'source_line': _line(source, "lessonId: '${lesson.lessonId}'"),
        'prior_lesson_ids_in_world': List<String>.of(earlierLessons),
        'prerequisite_kind':
            'source-order path closure, not demonstrated mastery',
        'profile_dependent_availability': 'NOT_VERIFIED_BY_SOURCE_MAP',
        'tasks': tasks,
      });
      earlierLessons.add(lesson.lessonId);
    }
    rows.add({
      'world_id': world.worldId,
      'world_number': world.worldNumber,
      'title': world.title,
      'authored_goal': world.subtitle,
      'prior_world_id': wi == 0 ? null : worlds[wi - 1].worldId,
      'lessons': lessons,
    });
  }
  return {
    'schema': 'act0_foundation_source_map_v1',
    'map_revision': 2,
    'source_status': 'PREPARED_UTC_CANDIDATE_NOT_PUBLISHED_OR_ACCEPTED',
    'source_delta': {
      'composition_base_commit': '6e848de8c11caa312af37347550ebde714d4b47c',
      'scope':
          'strict whole-cache retention admission only; route gates unchanged',
      'preview_prior_git_blob': 'e4e977674457061c8345da2ffe94ad72a75209e9',
      'preview_candidate_git_blob': previewBlob,
      'utc_patch_sha256':
          'ef9686afe5b9ef5d1e6e0501192098050ef2bf9f73de11173a62f1a81de82e07',
      'runtime_composition_and_human': 'NOT_VERIFIED',
    },
    'scope':
        'W1-W4 source traceability preparation; not course/runtime/Human acceptance',
    'source_base_commit': _base,
    'source_git_blobs': {
      _state: stateBlob,
      _preview: previewBlob,
      _parser: _blob(_parser),
    },
    'gate_semantics': {
      'path_closed': 'completed task IDs union Placement-skipped task IDs',
      'world_gate':
          'previous world path closed; each lesson task path closed for propagation',
      'lesson_gate':
          'world available and lesson completed or first incomplete lesson',
      'task_gate':
          'completed or skipped replay, otherwise first path-incomplete task',
      'earned_display':
          'completed task IDs only; skipped does not prove earned work',
      'assessment':
          'route closure is not independent correctness, unseen transfer, elapsed retention or mastery',
      'preview_source_lines': {
        '_pathClosedTaskIds': _line(
          preview,
          '  Set<String> get _pathClosedTaskIds',
        ),
        '_progressWorldsWithTaskIds': _line(
          preview,
          '  List<Act0WorldCardV1> _progressWorldsWithTaskIds(',
        ),
        '_progressWorld': _line(preview, '  Act0WorldCardV1 _progressWorld('),
        '_progressLesson': _line(
          preview,
          '  Act0LessonCardV1 _progressLesson(',
        ),
        '_taskAvailable': _line(preview, '  bool _taskAvailable('),
      },
    },
    'counts': {
      'worlds': worlds.length,
      'lessons': lessonIds.length,
      'tasks': taskIds.length,
      'source_copy_gaps': gaps.length,
    },
    'worlds': rows,
    'source_copy_gaps': gaps,
    'remaining': [
      'Resolve any listed source-copy gaps before claiming complete copy coverage.',
      'Verify genuine graded independent tasks, explanation and repair at the admitted runtime boundary.',
      'Prove all claimed transitions/unlock negative cases with applicable checks; this is no source-only PASS for CUR-08.',
      'Human understanding and efficacy remain separately gated; no points or full CUR/0.3 acceptance.',
    ],
  };
}

String renderFoundationSourceMapV1(Map<String, Object?> map) {
  final out = StringBuffer('# Foundation W1-W4 source map v1 - revision 2\n\n');
  out.writeln(
    'Status: PREPARED UTC CANDIDATE SOURCE TRACE ONLY; NOT PUBLISHED OR ACCEPTED. Parent CUR-01, 0.3, runtime and Human acceptance are not granted.',
  );
  out.writeln(
    '\nBase: `$_base`. The JSON companion lists exact source Git blobs, canonical task IDs, source declarations and unresolved fields. Content-source links retain the unchanged historical base. Composition base: 6e848de8c11caa312af37347550ebde714d4b47c. Preview is an unpublished UTC delta, not a blob in either base commit. Exact UTC patch SHA256: ef9686afe5b9ef5d1e6e0501192098050ef2bf9f73de11173a62f1a81de82e07. Revision 1 remains historical; its acceptance does not transfer. Route gates and content are unchanged by this delta.',
  );
  out.writeln(
    '\nThis inventory follows current Act0 world names and actual helper-retitled task IDs. Lesson goals quote authored subtitles. Earlier lessons/tasks describe source order; they are not new pedagogical prerequisites or evidence of learning.',
  );
  out.writeln(
    '\nRouting uses completed plus Placement-skipped task IDs. A skipped task can close the route without earning XP or proving a correct independent choice. Availability depends on persisted learner state; authored sample lock flags are not runtime proof.',
  );
  for (final world in (map['worlds'] as List).cast<Map<String, Object?>>()) {
    out.writeln('\n## ${world['world_id']}: ${world['title']}\n');
    out.writeln('Authored goal: ${world['authored_goal']}\n');
    out.writeln(
      'Previous world path gate: ${world['prior_world_id'] ?? 'none'}.\n',
    );
    out.writeln(
      '| Lesson | Authored goal | Earlier lessons in this world | Canonical task IDs in actual order |',
    );
    out.writeln('| --- | --- | --- | --- |');
    for (final lesson
        in (world['lessons'] as List).cast<Map<String, Object?>>()) {
      final tasks = (lesson['tasks'] as List).cast<Map<String, Object?>>();
      final ids = tasks.map((t) => '`${t['task_id']}`').join(', ');
      final before = (lesson['prior_lesson_ids_in_world'] as List)
          .map((id) => '`$id`')
          .join(', ');
      out.writeln(
        '| [${lesson['lesson_id']}](https://github.com/ClubBoss/sharky-standalone-direction/blob/$_base/$_state#L${lesson['source_line']}) | ${lesson['authored_goal']} | ${before.isEmpty ? 'none' : before} | $ids |',
      );
    }
  }
  out.writeln('\n## Limits and reproduction\n');
  out.writeln(
    'The repaired existing source parser supplies this inventory; it does not execute Flutter, resolve arbitrary Dart expressions, grade choices, measure usability or prove native persistence. Unknown runner expressions/copy remain explicit JSON gaps. Source question/feedback is not a claim about final rendered UI.',
  );
  out.writeln(
    '\nRun `dart tools/check_act0_content_copy_source_parser_v1.dart`, then `dart tools/act0_foundation_source_map_v1.dart --check` from the repository root with the compatible standalone Dart VM. No Flutter initialization or dependency download is needed. `--write` regenerates both companion files only after the exact State/Preview source pins match. Changed pins require an intentional map revision and review.',
  );
  out.writeln(
    '\nThe map has ${map['counts']}. Full Foundation source, graded runtime, negative route controls and admitted Human proof remain distinct. Original DoDs, weights, protected gates and existing holds remain unchanged.',
  );
  return out.toString();
}

void main(List<String> args) {
  if (args.length != 1 || !{'--write', '--check'}.contains(args.single)) {
    stderr.writeln(
      'Usage: dart tools/act0_foundation_source_map_v1.dart --write|--check',
    );
    exitCode = 64;
    return;
  }
  final map = buildFoundationSourceMapV1();
  final json = '${const JsonEncoder.withIndent('  ').convert(map)}\n';
  final markdown = renderFoundationSourceMapV1(map);
  if (args.single == '--write') {
    File(_jsonPath).writeAsStringSync(json);
    File(_mdPath).writeAsStringSync(markdown);
  } else if (!File(_jsonPath).existsSync() ||
      !File(_mdPath).existsSync() ||
      File(_jsonPath).readAsStringSync() != json ||
      File(_mdPath).readAsStringSync() != markdown) {
    stderr.writeln(
      'FAIL Foundation source map is missing/stale/tampered; no source acceptance.',
    );
    exitCode = 1;
    return;
  }
  stdout.writeln(
    jsonEncode({
      'operation': args.single,
      'source_trace_only': true,
      'counts': map['counts'],
    }),
  );
}
