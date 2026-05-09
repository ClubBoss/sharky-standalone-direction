import 'cash_l3_preflight_v1.dart';
import 'cash_l3_selector_v1.dart';
import 'cash_l3_generator_v1.dart';
import 'cash_l3_writer_v1.dart';
import 'cash_l3_injector_v1.dart';

class CashL3GenerationCoreV1 {
  const CashL3GenerationCoreV1(
    this.preflight,
    this.selector,
    this.generator,
    this.writer,
    this.injector,
  );

  final CashL3PreflightV1 preflight;
  final CashL3SelectorV1 selector;
  final CashL3GeneratorV1 generator;
  final CashL3WriterV1 writer;
  final CashL3InjectorV1 injector;

  Map<String, Object?> runOnce() {
    final scan = preflight.scanPack();
    final moduleId = selector.selectNextModule(scan);
    final generated = generator.generateModule(moduleId);
    final theory = writer.writeTheory(moduleId, generated['theory'] as String);
    final drills = writer.writeDrills(
      moduleId,
      generated['drills'] as List<Object?>,
    );
    final recap = writer.writeRecap(moduleId, generated['recap'] as String);
    final quiz = writer.writeQuiz(moduleId, generated['quiz'] as List<Object?>);
    final injected = injector.inject(generated);
    return <String, Object?>{
      'scan': scan,
      'selected': moduleId,
      'generated': generated,
      'written': <String, Object?>{
        'theory': theory,
        'drills': drills,
        'recap': recap,
        'quiz': quiz,
      },
      'injected': injected,
    };
  }
}
