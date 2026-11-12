// OUTPUT ONLY attribution adapter. No storage, grading, reward or migration.
class W4AuthoredBinding {
  const W4AuthoredBinding(
    this.world,
    this.lesson,
    this.task,
    this.fingerprint,
    this.record,
    this.version,
    this.recordHash,
    this.handId,
    this.decisionId,
    this.sourceManifest,
    this.bindingManifest,
  );
  final String world,
      lesson,
      task,
      fingerprint,
      record,
      version,
      recordHash,
      handId,
      decisionId,
      sourceManifest,
      bindingManifest;
  List<String> get source => [world, lesson, task, fingerprint];
  List<String> get authored => [record, version];
}

class W4BindingRegistryProposal {
  W4BindingRegistryProposal(Iterable<W4AuthoredBinding> input)
    : rows = List.unmodifiable(input) {
    for (var i = 0; i < rows.length; i++) {
      final a = rows[i];
      if ([
        ...a.source,
        ...a.authored,
        a.recordHash,
        a.handId,
        a.decisionId,
        a.sourceManifest,
        a.bindingManifest,
      ].any((x) => x.trim().isEmpty))
        throw ArgumentError('missing_binding');
      if (!a.decisionId.startsWith('${a.handId}:'))
        throw ArgumentError('decision_hand_mismatch');
      for (final b in rows.take(i)) {
        if (_same(a.source, b.source) ||
            _same(a.authored, b.authored) ||
            a.fingerprint == b.fingerprint)
          throw ArgumentError('ambiguous_or_duplicate_binding');
      }
    }
  }
  final List<W4AuthoredBinding> rows;
  W4AuthoredBinding? resolve(
    String world,
    String lesson,
    String task,
    String fingerprint,
  ) {
    for (final r in rows) {
      if (_same(r.source, [world, lesson, task, fingerprint])) return r;
    }
    return null;
  }
}

bool _same(List<String> a, List<String> b) =>
    a.length == b.length &&
    List.generate(a.length, (i) => a[i] == b[i]).every((v) => v);
