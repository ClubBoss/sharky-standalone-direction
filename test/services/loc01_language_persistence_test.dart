import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/app_language_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Controller/storage contracts only. Codes exercise the existing API; they do
// not admit translated UI, new shipping languages, or native persistence proof.
const _key = 'flutter.app_language_code';
const _channel = MethodChannel('plugins.flutter.io/shared_preferences');

class _Store {
  final disk = <String, Object>{};
  final writes = <String>[];
  final readStarted = Completer<void>();
  Completer<void>? readGate;
  Object? readError;
  Future<bool> Function(String)? onWrite;

  Future<Object?> handle(MethodCall call) async {
    switch (call.method) {
      case 'getAll':
      case 'getAllWithParameters':
        final snapshot = Map<String, Object>.of(disk);
        if (!readStarted.isCompleted) readStarted.complete();
        await readGate?.future;
        if (readError != null) throw readError!;
        return snapshot;
      case 'setString':
        final args = call.arguments as Map;
        expect(args['key'], _key);
        final code = args['value'] as String;
        writes.add(code);
        final saved = await (onWrite?.call(code) ?? Future.value(true));
        if (saved) disk[_key] = code;
        return saved;
      default:
        throw StateError('Unexpected preference operation: ${call.method}');
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Store store;
  late AppLanguageController controller;
  late List<FlutterErrorDetails> errors;
  FlutterExceptionHandler? previousErrorHandler;

  setUp(() {
    SharedPreferences.resetStatic();
    store = _Store();
    controller = AppLanguageController();
    errors = [];
    previousErrorHandler = FlutterError.onError;
    FlutterError.onError = errors.add;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, store.handle);
  });

  tearDown(() {
    controller.dispose();
    FlutterError.onError = previousErrorHandler;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    SharedPreferences.resetStatic();
  });

  Future<String> restartController() async {
    // Drop the plugin's optimistic in-memory cache, keeping only fake disk.
    SharedPreferences.resetStatic();
    final restored = AppLanguageController();
    await restored.initialize();
    final code = restored.languageCode;
    restored.dispose();
    return code;
  }

  test(
    'persists selection and restores from storage without cached state',
    () async {
      await controller.initialize();
      expect(await controller.setLanguage('es'), isTrue);
      expect(store.disk[_key], 'es');
      expect(await restartController(), 'es');
      expect(errors, isEmpty);
    },
  );

  for (final value in <Object?>[
    null,
    'xx',
    '',
    'EN',
    'en-US',
    17,
    true,
    ['en'],
  ]) {
    test(
      'invalid stored value $value falls back to English without rewriting',
      () async {
        if (value != null) store.disk[_key] = value;
        var notifications = 0;
        controller.addListener(() => notifications++);
        await controller.initialize();
        expect(controller.languageCode, 'en');
        expect(controller.isInitialized, isTrue);
        expect(notifications, 1);
        expect(store.writes, isEmpty);
        expect(store.disk[_key], value);
      },
    );
  }

  test(
    'unsupported request does not notify, write, or cancel initialization',
    () async {
      store.disk[_key] = 'es';
      store.readGate = Completer<void>();
      final initializing = controller.initialize();
      await store.readStarted.future;
      expect(await controller.setLanguage('xx'), isFalse);
      store.readGate!.complete();
      await initializing;
      expect(controller.languageCode, 'es');
      expect(store.writes, isEmpty);
    },
  );

  test(
    'delayed initialization cannot replace a newer explicit selection',
    () async {
      store.disk[_key] = 'es';
      store.readGate = Completer<void>();
      final initializing = controller.initialize();
      await store.readStarted.future;
      final selecting = controller.setLanguage('fr');
      expect(controller.languageCode, 'fr');
      store.readGate!.complete();
      await initializing;
      expect(await selecting, isTrue);
      expect(controller.languageCode, 'fr');
      expect(await restartController(), 'fr');
    },
  );

  test(
    'explicit English during initialization overrides stale saved language',
    () async {
      store.disk[_key] = 'es';
      store.readGate = Completer<void>();
      final initializing = controller.initialize();
      await store.readStarted.future;
      final selecting = controller.setLanguage('en');
      store.readGate!.complete();
      await initializing;
      expect(await selecting, isFalse); // bool still means visible change.
      expect(controller.languageCode, 'en');
      expect(await restartController(), 'en');
    },
  );

  test('read failure preserves later choice and reports the failure', () async {
    store.readGate = Completer<void>();
    store.readError = PlatformException(code: 'read_failed');
    final initializing = controller.initialize();
    await store.readStarted.future;
    final selecting = controller.setLanguage('fr');
    store.readGate!.complete();
    await initializing;
    await selecting;
    expect(controller.languageCode, 'fr');
    expect(controller.isInitialized, isTrue);
    expect(errors, isNotEmpty);
  });

  test(
    'read failure without selection uses English and notifies readiness',
    () async {
      store.readError = PlatformException(code: 'read_failed');
      var notifications = 0;
      controller.addListener(() => notifications++);
      await controller.initialize();
      expect(controller.languageCode, 'en');
      expect(controller.isInitialized, isTrue);
      expect(notifications, 1);
      expect(errors, hasLength(1));
    },
  );

  for (final throwsError in [false, true]) {
    test(
      'write ${throwsError ? 'exception' : 'false'} is reported and retryable',
      () async {
        await controller.initialize();
        store.onWrite = (_) async {
          if (throwsError) throw PlatformException(code: 'write_failed');
          return false;
        };
        expect(await controller.setLanguage('es'), isTrue);
        expect(controller.languageCode, 'es');
        expect(store.disk[_key], isNull);
        expect(errors, hasLength(1));
        expect(errors.single.library, 'app_language_controller');
        store.onWrite = null;
        expect(await controller.setLanguage('es'), isFalse);
        expect(store.writes, ['es', 'es']);
        expect(await restartController(), 'es');
      },
    );
  }

  test(
    'concurrent writes serialize and restore the most recent choice',
    () async {
      await controller.initialize();
      final firstStarted = Completer<void>();
      final releaseFirst = Completer<bool>();
      store.onWrite = (code) {
        if (code == 'es') {
          firstStarted.complete();
          return releaseFirst.future;
        }
        return Future.value(true);
      };
      final first = controller.setLanguage('es');
      await firstStarted.future;
      final second = controller.setLanguage('fr');
      // Drain queued continuations without wall-clock sleeps.
      await Future<void>.delayed(Duration.zero);
      final writesWhilePending = List<String>.of(store.writes);
      expect(controller.languageCode, 'fr');
      releaseFirst.complete(true);
      expect(await first, isTrue);
      expect(await second, isTrue);
      expect(await restartController(), 'fr');
      expect(writesWhilePending, ['es']);
      expect(store.writes, ['es', 'fr']);
    },
  );

  test(
    'failed queued write does not prevent a later selection being saved',
    () async {
      await controller.initialize();
      store.onWrite = (code) async {
        if (code == 'es') throw PlatformException(code: 'write_failed');
        return true;
      };
      final first = controller.setLanguage('es');
      final second = controller.setLanguage('fr');
      expect(await first, isTrue);
      expect(await second, isTrue);
      expect(errors, hasLength(1));
      expect(await restartController(), 'fr');
    },
  );

  test(
    'returning to a saved language repairs cache after a failed write',
    () async {
      await controller.initialize();
      await controller.setLanguage('es');
      store.onWrite = (_) async => false;
      await controller.setLanguage('fr');
      store.onWrite = null;
      await controller.setLanguage('es');
      expect(
        (await SharedPreferences.getInstance()).getString('app_language_code'),
        'es',
      );
      expect(await restartController(), 'es');
      expect(errors, hasLength(1));
    },
  );

  test(
    'listener reentrancy keeps storage ordered with the final visible choice',
    () async {
      await controller.initialize();
      Future<bool>? nested;
      controller.addListener(() {
        if (controller.languageCode == 'es') {
          nested = controller.setLanguage('fr');
        }
      });
      expect(await controller.setLanguage('es'), isTrue);
      expect(await nested!, isTrue);
      expect(controller.languageCode, 'fr');
      expect(await restartController(), 'fr');
    },
  );

  test(
    'successful repeated selection returns false without extra write/notify',
    () async {
      await controller.initialize();
      var notifications = 0;
      controller.addListener(() => notifications++);
      expect(await controller.setLanguage('es'), isTrue);
      expect(await controller.setLanguage('es'), isFalse);
      expect(await controller.setLanguage('en'), isTrue);
      expect(store.writes, ['es', 'en']);
      expect(notifications, 2);
      expect(await restartController(), 'en');
    },
  );

  test('overlapping initialize calls publish readiness only once', () async {
    store.disk[_key] = 'es';
    store.readGate = Completer<void>();
    var notifications = 0;
    controller.addListener(() => notifications++);
    final first = controller.initialize();
    final second = controller.initialize();
    await store.readStarted.future;
    store.readGate!.complete();
    await Future.wait([first, second]);
    await controller.initialize();
    expect(notifications, 1);
    expect(controller.languageCode, 'es');
    expect(store.writes, isEmpty);
  });
}
