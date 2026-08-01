import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  const registryPath = 'tools/visual_state_atlas_registry_v1.json';
  const discoveryPath =
      'output/visual_control_center/current/runtime_discovery.json';
  const siteRoot = 'output/visual_control_center/current/site';

  test(
    'runtime exporter, registry, and generated portable dashboard agree',
    () async {
      final export = await Process.run('dart', <String>[
        'run',
        'tools/act0_visual_state_discovery_v1.dart',
        '--output=$discoveryPath',
      ]);
      expect(export.exitCode, 0, reason: '${export.stdout}\n${export.stderr}');
      final registry = jsonDecode(File(registryPath).readAsStringSync()) as Map;
      final discovery =
          jsonDecode(File(discoveryPath).readAsStringSync()) as Map;
      expect(registry['schema'], 'visual_state_atlas_registry_v1');
      expect(discovery['schema'], 'act0_visual_state_discovery_v1');
      expect((discovery['tasks'] as List).isNotEmpty, isTrue);
      final build = await Process.run('python3', <String>[
        'tools/build_visual_control_center_v1.py',
        '--discovery=$discoveryPath',
      ]);
      expect(build.exitCode, 0, reason: '${build.stdout}\n${build.stderr}');
      final atlas =
          jsonDecode(File('$siteRoot/data/atlas.json').readAsStringSync())
              as Map;
      final coverage =
          jsonDecode(File('$siteRoot/data/coverage.json').readAsStringSync())
              as Map;
      final transitions =
          jsonDecode(File('$siteRoot/data/transitions.json').readAsStringSync())
              as Map;
      final states = (atlas['states'] as List).cast<Map>();
      final ids = states.map((state) => state['state_id']).toSet()
        ..add('runner.runtime');
      expect(
        states.where(
          (state) =>
              state['release_reachable'] == true &&
              (state['production_owner'] == null ||
                  state['production_owner'] == 'none'),
        ),
        isEmpty,
      );
      expect(
        (coverage['records'] as List).where(
          (record) => record['status'] == 'UNKNOWN_UNMAPPED',
        ),
        isEmpty,
      );
      expect(
        (coverage['records'] as List).where(
          (record) =>
              record['status'] == 'ORPHAN_CAPTURE' &&
              record['production_claimed'] == true,
        ),
        isEmpty,
      );
      expect(
        (transitions['transitions'] as List).where(
          (edge) =>
              !ids.contains(edge['source_state_id']) ||
              !ids.contains(edge['destination_state_id']),
        ),
        isEmpty,
      );
      final index = File('$siteRoot/index.html').readAsStringSync();
      for (final mode in <String>[
        'Overview',
        'Flow Map',
        'Surface Atlas',
        'Coverage',
        'Screen Inspector',
        'Compare',
        'Missing / Failed',
        'Route Playback',
      ]) {
        expect(
          File('$siteRoot/assets/app.js').readAsStringSync(),
          contains(mode),
        );
      }
      expect(index, contains('HOSTED SNAPSHOT'));
      final version =
          jsonDecode(
                File('$siteRoot/data/site_version.json').readAsStringSync(),
              )
              as Map;
      expect(
        version['evidence_baseline_sha'],
        'b7db47a3145ba8653b90403a9aa48538c378cdb7',
      );
      final manifest =
          jsonDecode(
                File(
                  '$siteRoot/data/evidence_manifest.json',
                ).readAsStringSync(),
              )
              as Map;
      for (final image in manifest['images'] as List) {
        expect(
          File('$siteRoot/${image['full_image']}').existsSync(),
          isTrue,
          reason: image['inventory_id'],
        );
        expect(
          File('$siteRoot/${image['thumbnail']}').existsSync(),
          isTrue,
          reason: image['inventory_id'],
        );
      }
    },
  );
}
