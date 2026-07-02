import 'dart:convert';

const String act0SessionIdentityStatusActiveV1 = 'active';
const String act0SessionIdentityStatusCompletedV1 = 'completed';

class Act0SessionIdentityStateV1 {
  const Act0SessionIdentityStateV1({
    this.schemaVersion = 1,
    this.nextSessionOrdinal = 1,
    this.currentSession,
    this.latestSession,
  });

  final int schemaVersion;
  final int nextSessionOrdinal;
  final Act0SessionIdentityRecordV1? currentSession;
  final Act0SessionIdentityRecordV1? latestSession;

  String get status =>
      currentSession?.status ??
      latestSession?.status ??
      act0SessionIdentityStatusCompletedV1;

  String get currentActiveSessionId =>
      currentSession?.isActive == true ? currentSession!.sessionId : '';

  Act0SessionIdentityRecordV1? get currentOrLatestSession =>
      currentSession ?? latestSession;

  Act0SessionIdentityStartResultV1 startOrResume({
    required int startedAtOrder,
    required String startedWorldId,
    String startedLessonId = '',
  }) {
    final active = currentSession;
    if (active != null && active.isActive) {
      return Act0SessionIdentityStartResultV1(
        state: this,
        session: active,
        startedNewSession: false,
      );
    }
    final ordinal = nextSessionOrdinal < 1 ? 1 : nextSessionOrdinal;
    final session = Act0SessionIdentityRecordV1(
      sessionId: 'session_v1|$ordinal',
      startedAtOrder: startedAtOrder < 0 ? 0 : startedAtOrder,
      startedWorldId: startedWorldId.trim(),
      startedLessonId: startedLessonId.trim(),
      status: act0SessionIdentityStatusActiveV1,
    );
    return Act0SessionIdentityStartResultV1(
      state: Act0SessionIdentityStateV1(
        nextSessionOrdinal: ordinal + 1,
        currentSession: session,
        latestSession: session,
      ),
      session: session,
      startedNewSession: true,
    );
  }

  Act0SessionIdentityCompleteResultV1 complete({
    required int completedAtOrder,
    String completionReason = '',
  }) {
    final active = currentSession;
    if (active == null || !active.isActive) {
      return Act0SessionIdentityCompleteResultV1(
        state: this,
        session: currentOrLatestSession,
        completedNow: false,
      );
    }
    final completed = active.copyWith(
      status: act0SessionIdentityStatusCompletedV1,
      completedAtOrder: completedAtOrder < 0 ? 0 : completedAtOrder,
      completionReason: completionReason.trim(),
    );
    return Act0SessionIdentityCompleteResultV1(
      state: Act0SessionIdentityStateV1(
        nextSessionOrdinal: nextSessionOrdinal < 1 ? 1 : nextSessionOrdinal,
        latestSession: completed,
      ),
      session: completed,
      completedNow: true,
    );
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'nextSessionOrdinal': nextSessionOrdinal < 1 ? 1 : nextSessionOrdinal,
    if (currentSession != null) 'currentSession': currentSession!.toPayload(),
    if (latestSession != null) 'latestSession': latestSession!.toPayload(),
  };

  String toStorageString() => jsonEncode(toPayload());

  static Act0SessionIdentityStateV1 tryParse(Object? raw) {
    if (raw is! Map) {
      return const Act0SessionIdentityStateV1();
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']);
    final nextSessionOrdinal = _nonNegativeInt(map['nextSessionOrdinal']);
    final currentSession = Act0SessionIdentityRecordV1.tryParse(
      map['currentSession'],
    );
    final latestSession = Act0SessionIdentityRecordV1.tryParse(
      map['latestSession'],
    );
    if (schemaVersion != 1 || nextSessionOrdinal == null) {
      return const Act0SessionIdentityStateV1();
    }
    final normalizedCurrent = currentSession?.isActive == true
        ? currentSession
        : null;
    final highestSeenOrdinal = <int>[
      _sessionOrdinal(currentSession?.sessionId),
      _sessionOrdinal(latestSession?.sessionId),
    ].fold<int>(1, (max, value) => value > max ? value : max);
    return Act0SessionIdentityStateV1(
      nextSessionOrdinal: nextSessionOrdinal > highestSeenOrdinal
          ? nextSessionOrdinal
          : highestSeenOrdinal + 1,
      currentSession: normalizedCurrent,
      latestSession: latestSession ?? normalizedCurrent,
    );
  }

  static Act0SessionIdentityStateV1 tryParseStorageString(String raw) {
    try {
      return tryParse(jsonDecode(raw));
    } on FormatException {
      return const Act0SessionIdentityStateV1();
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Act0SessionIdentityStateV1 &&
      other.schemaVersion == schemaVersion &&
      other.nextSessionOrdinal == nextSessionOrdinal &&
      other.currentSession == currentSession &&
      other.latestSession == latestSession;

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    nextSessionOrdinal,
    currentSession,
    latestSession,
  );
}

class Act0SessionIdentityRecordV1 {
  const Act0SessionIdentityRecordV1({
    this.schemaVersion = 1,
    required this.sessionId,
    required this.startedAtOrder,
    required this.startedWorldId,
    this.startedLessonId = '',
    required this.status,
    this.completedAtOrder,
    this.completionReason = '',
  });

  final int schemaVersion;
  final String sessionId;
  final int startedAtOrder;
  final String startedWorldId;
  final String startedLessonId;
  final String status;
  final int? completedAtOrder;
  final String completionReason;

  bool get isActive => status == act0SessionIdentityStatusActiveV1;

  Act0SessionIdentityRecordV1 copyWith({
    String? status,
    int? completedAtOrder,
    String? completionReason,
  }) {
    return Act0SessionIdentityRecordV1(
      sessionId: sessionId,
      startedAtOrder: startedAtOrder,
      startedWorldId: startedWorldId,
      startedLessonId: startedLessonId,
      status: status ?? this.status,
      completedAtOrder: completedAtOrder ?? this.completedAtOrder,
      completionReason: completionReason ?? this.completionReason,
    );
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'sessionId': sessionId,
    'startedAtOrder': startedAtOrder,
    'startedWorldId': startedWorldId,
    if (startedLessonId.isNotEmpty) 'startedLessonId': startedLessonId,
    'status': status,
    if (completedAtOrder != null) 'completedAtOrder': completedAtOrder,
    if (completionReason.isNotEmpty) 'completionReason': completionReason,
  };

  static Act0SessionIdentityRecordV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']);
    final sessionId = _requiredString(map['sessionId']);
    final startedAtOrder = _nonNegativeInt(map['startedAtOrder']);
    final startedWorldId = _requiredString(map['startedWorldId']);
    final startedLessonId = _optionalString(map['startedLessonId']);
    final status = _requiredString(map['status']);
    final completedAtOrder = map.containsKey('completedAtOrder')
        ? _nonNegativeInt(map['completedAtOrder'])
        : null;
    final completionReason = _optionalString(map['completionReason']);
    if (schemaVersion != 1 ||
        sessionId == null ||
        startedAtOrder == null ||
        startedWorldId == null ||
        status == null ||
        !_statuses.contains(status) ||
        (status == act0SessionIdentityStatusCompletedV1 &&
            completedAtOrder == null)) {
      return null;
    }
    return Act0SessionIdentityRecordV1(
      sessionId: sessionId,
      startedAtOrder: startedAtOrder,
      startedWorldId: startedWorldId,
      startedLessonId: startedLessonId,
      status: status,
      completedAtOrder: completedAtOrder,
      completionReason: completionReason,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Act0SessionIdentityRecordV1 &&
      other.schemaVersion == schemaVersion &&
      other.sessionId == sessionId &&
      other.startedAtOrder == startedAtOrder &&
      other.startedWorldId == startedWorldId &&
      other.startedLessonId == startedLessonId &&
      other.status == status &&
      other.completedAtOrder == completedAtOrder &&
      other.completionReason == completionReason;

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    sessionId,
    startedAtOrder,
    startedWorldId,
    startedLessonId,
    status,
    completedAtOrder,
    completionReason,
  );
}

class Act0SessionIdentityStartResultV1 {
  const Act0SessionIdentityStartResultV1({
    required this.state,
    required this.session,
    required this.startedNewSession,
  });

  final Act0SessionIdentityStateV1 state;
  final Act0SessionIdentityRecordV1 session;
  final bool startedNewSession;
}

class Act0SessionIdentityCompleteResultV1 {
  const Act0SessionIdentityCompleteResultV1({
    required this.state,
    required this.session,
    required this.completedNow,
  });

  final Act0SessionIdentityStateV1 state;
  final Act0SessionIdentityRecordV1? session;
  final bool completedNow;
}

const Set<String> _statuses = <String>{
  act0SessionIdentityStatusActiveV1,
  act0SessionIdentityStatusCompletedV1,
};

String? _requiredString(Object? raw) {
  final value = raw?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

String _optionalString(Object? raw) => raw?.toString().trim() ?? '';

int? _nonNegativeInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 0 ? null : value;
}

int _sessionOrdinal(String? sessionId) {
  final parts = (sessionId ?? '').split('|');
  if (parts.length != 2 || parts.first != 'session_v1') {
    return 0;
  }
  return int.tryParse(parts.last) ?? 0;
}
