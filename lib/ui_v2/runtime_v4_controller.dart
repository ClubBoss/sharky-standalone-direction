class RuntimeV4Controller {
  RuntimeV4Controller() : _isEnabled = false;

  bool _isEnabled;

  bool get isEnabled => _isEnabled;
  bool get isV4RuntimeReady => _isEnabled;

  void toggle(bool next) {
    _isEnabled = next;
  }
}

final runtimeV4Controller = RuntimeV4Controller();
