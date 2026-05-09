import 'dart:io';

import 'regression_gate_v1.dart';

void main() {
  final result = runRegressionGateV1();
  print(result);
  if (result['ok'] != true) {
    exit(1);
  }
}
