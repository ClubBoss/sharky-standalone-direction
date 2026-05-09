import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_marker_contract_v1.dart';

void main() {
  test('world1 canonical seat quiz cue contracts resolve marker family', () {
    final markers = resolveWorld1CanonicalSeatQuizCueContractsV1(
      seatQuizVisualMode: true,
      cueRadius: 8.5,
    );
    final targetRing = resolveWorld1CanonicalTargetRingContractV1(
      targetSeatCenter: const Offset(10, 20),
      targetSeatId: 'btn',
      nonOverlappingSeatSize: 48,
    );

    expect(markers.length, 3);
    expect(markers.first.kind, World1CanonicalTableMarkerKindV1.dealer);
    expect(markers[1].kind, World1CanonicalTableMarkerKindV1.sb);
    expect(markers[2].kind, World1CanonicalTableMarkerKindV1.bb);
    expect(targetRing, isNotNull);
    expect(targetRing!.diameter, 56);
  });

  testWidgets('world1 canonical table marker body renders blind marker', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: <Widget>[
              buildWorld1CanonicalTableMarkerBodyV1(
                center: const Offset(40, 40),
                contract: const World1CanonicalTableMarkerContractV1(
                  kind: World1CanonicalTableMarkerKindV1.sb,
                  label: 'SB',
                  amount: 1,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('SB'), findsOneWidget);
    expect(find.text('0.5'), findsOneWidget);
  });
}
