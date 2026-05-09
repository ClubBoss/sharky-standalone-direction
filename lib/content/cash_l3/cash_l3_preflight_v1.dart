class CashL3PreflightV1 {
  Map<String, Object?> scanPack() => const <String, Object?>{
    'status': 'ok',
    'modules_detected': 0,
    'next_module_candidate': 'l3_cash_stub',
  };

  List<String> listGaps() => const <String>[];
}
