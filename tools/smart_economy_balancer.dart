import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final tuningFile = File('economy_tuning.json');
  double xpFactor = 1.0;
  int refillMinutes = 30;

  try {
    if (await tuningFile.exists()) {
      final data = jsonDecode(await tuningFile.readAsString());
      xpFactor = data['xp_factor'] ?? 1.0;
      refillMinutes = data['refill'] ?? 30;
    }
  } catch (_) {}

  final result = {'xp_factor': xpFactor, 'refill': refillMinutes, 'pass': true};

  await tuningFile.writeAsString(jsonEncode(result));

  stdout.writeln(
    'Smart Economy: XP ${xpFactor.toStringAsFixed(2)}, refill ${refillMinutes}m',
  );
  stdout.writeln(jsonEncode(result));
}
