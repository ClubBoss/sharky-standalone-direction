import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart';
import 'package:poker_analyzer/models/v2/training_pack_v2.dart';
import 'package:poker_analyzer/models/v2/training_session.dart';
import 'package:poker_analyzer/screens/training_session_screen.dart';
import 'package:poker_analyzer/services/canonical_legacy_training_launch_v1.dart';

void main() {
  TrainingPackV2 buildPack(String id) {
    final template = TrainingPackTemplateV2(
      id: id,
      name: id,
      trainingType: TrainingType.pushFold,
      spots: <TrainingPackSpot>[TrainingPackSpot(id: 'spot_1')],
    );
    return TrainingPackV2.fromTemplate(template, id);
  }

  test(
    'pack launches preserve pack payload start index source and callback',
    () {
      void onSessionEnd() {}

      final pack = buildPack('pack_launch_v1');
      final screen = buildCanonicalLegacyTrainingScreenV1(
        CanonicalLegacyTrainingLaunchInputV1.pack(
          pack: pack,
          startIndex: 3,
          source: 'pack_preview',
          onSessionEnd: onSessionEnd,
        ),
      );

      expect(screen, isA<TrainingSessionScreen>());
      expect(screen.pack, same(pack));
      expect(screen.session, isNull);
      expect(screen.startIndex, 3);
      expect(screen.source, 'pack_preview');
      expect(screen.onSessionEnd, same(onSessionEnd));
    },
  );

  test(
    'session launches preserve session payload and route through the shared builder',
    () {
      final session = TrainingSession(
        id: 'session_launch_v1',
        templateId: 'template_launch_v1',
        index: 2,
      );
      final screen = buildCanonicalLegacyTrainingScreenV1(
        CanonicalLegacyTrainingLaunchInputV1.session(
          session: session,
          source: 'session_preview',
        ),
      );

      expect(screen, isA<TrainingSessionScreen>());
      expect(screen.session, same(session));
      expect(screen.pack, isNull);
      expect(screen.startIndex, 0);
      expect(screen.source, 'session_preview');
    },
  );
}
