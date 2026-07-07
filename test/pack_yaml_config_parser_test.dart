// AUTO-PATCH: deprecated unit test disabled to keep CI green after parser removal.
// See integration coverage in training pack generation tests.
@Skip('deprecated parser removed')
import 'package:test/test.dart';

void main() {
  test('noop', () {
    expect(1, 1);
  });
}
