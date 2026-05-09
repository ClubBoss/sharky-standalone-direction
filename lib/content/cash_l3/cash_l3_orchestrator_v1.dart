import 'cash_l3_preflight_v1.dart';
import 'cash_l3_selector_v1.dart';

class CashL3OrchestratorV1 {
  const CashL3OrchestratorV1(this.preflight, this.selector);

  final CashL3PreflightV1 preflight;
  final CashL3SelectorV1 selector;

  Map<String, Object?> run() {
    final scan = preflight.scanPack();
    final module = selector.selectNextModule(scan);
    return <String, Object?>{
      'scan': scan,
      'selected_module': module,
      'diagnostics': selector.diagnostics(),
    };
  }
}
