class CashL3InjectorV1 {
  Map<String, Object?> inject(Map<String, Object?> module) => <String, Object?>{
    'status': 'injected_stub',
    'module_id': module['id'],
    'pack_target': 'cash_l3_pack_stub',
  };

  Map<String, Object?> diagnostics() => const <String, Object?>{
    'status': 'ok',
    'reason': 'injector_stub',
  };
}
