import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Key kCanonicalDirectSessionSurfaceKeyV1 = Key(
  'canonical_direct_session_surface_v1',
);
const Key kCanonicalDirectSessionSessionIdValueKeyV1 = Key(
  'canonical_direct_session_session_id_value',
);
const Key kCanonicalDirectSessionStatusLineValueKeyV1 = Key(
  'canonical_direct_session_status_line_value',
);

Finder findCanonicalDirectSessionSurfaceV1() =>
    find.byKey(kCanonicalDirectSessionSurfaceKeyV1, skipOffstage: false);

Finder findCanonicalDirectSessionSessionIdValueV1() =>
    find.byKey(kCanonicalDirectSessionSessionIdValueKeyV1, skipOffstage: false);

Finder findCanonicalDirectSessionStatusLineValueV1() => find.byKey(
  kCanonicalDirectSessionStatusLineValueKeyV1,
  skipOffstage: false,
);

String readCanonicalDirectSessionSessionIdV1(WidgetTester tester) {
  final sessionIdText = tester.widget<Text>(
    findCanonicalDirectSessionSessionIdValueV1(),
  );
  return (sessionIdText.data ?? '').trim();
}

String readCanonicalDirectSessionStatusLineV1(WidgetTester tester) {
  final statusText = tester.widget<Text>(
    findCanonicalDirectSessionStatusLineValueV1(),
  );
  return (statusText.data ?? '').trim();
}

void expectCanonicalDirectSessionLaunchV1(
  WidgetTester tester,
  String expectedSessionId,
) {
  expect(findCanonicalDirectSessionSurfaceV1(), findsOneWidget);
  expect(readCanonicalDirectSessionSessionIdV1(tester), expectedSessionId);
}
