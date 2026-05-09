import 'dart:async';
import 'package:poker_analyzer/services/evaluation_queue_service.dart';
import 'package:poker_analyzer/models/action_evaluation_request.dart';

class _EvalQueueLock {
  Future<T> synchronized<T>(FutureOr<T> Function() action) async => action();
}

final _pending = <EvaluationQueueService, List<ActionEvaluationRequest>>{};
final _completed = <EvaluationQueueService, List<ActionEvaluationRequest>>{};
final _failed = <EvaluationQueueService, List<ActionEvaluationRequest>>{};
final _locks = <EvaluationQueueService, _EvalQueueLock>{};
final _retention = <EvaluationQueueService, bool>{};

extension EvaluationQueueServiceCompat on EvaluationQueueService {
  _EvalQueueLock get queueLock => _locks.putIfAbsent(this, _EvalQueueLock.new);
  List<ActionEvaluationRequest> get pending =>
      _pending.putIfAbsent(this, () => <ActionEvaluationRequest>[]);
  List<ActionEvaluationRequest> get completed =>
      _completed.putIfAbsent(this, () => <ActionEvaluationRequest>[]);
  List<ActionEvaluationRequest> get failed =>
      _failed.putIfAbsent(this, () => <ActionEvaluationRequest>[]);
  bool get snapshotRetentionEnabled => _retention[this] ?? false;
  set snapshotRetentionEnabled(bool value) => _retention[this] = value;
  Future<void> addToQueue(ActionEvaluationRequest req) async =>
      pending.add(req);
  set debugPanelCallback(void Function()? _) {}
}
