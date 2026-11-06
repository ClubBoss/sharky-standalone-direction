import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/models/injected_path_module.dart';
import 'package:poker_analyzer/services/autogen_status_dashboard_service.dart';
import 'package:poker_analyzer/services/learning_path_store.dart';
import 'package:poker_analyzer/services/inline_pack_theory_clusterer.dart';
import 'package:poker_analyzer/services/mistake_telemetry_store.dart';
import 'package:poker_analyzer/services/theory_injection_scheduler_service.dart';
import 'package:poker_analyzer/services/theory_library_index.dart';
import 'package:poker_analyzer/services/theory_link_auto_injector.dart';
import 'package:poker_analyzer/services/theory_link_config_service.dart';
import 'package:poker_analyzer/services/theory_link_policy_engine.dart';
import 'package:poker_analyzer/services/theory_novelty_registry.dart';

class _ScopedTheoryIndex extends TheoryLibraryIndex {
  @override
  Future<List<TheoryResource>> all() async => [
    TheoryResource(
      id: 'scope_theory',
      title: 'Scoped theory fixture',
      uri: 'theory/scope.md',
      tags: const ['scope_tag'],
    ),
  ];
}

class _GatedUserStore extends LearningPathStore {
  _GatedUserStore({required super.rootDir});

  final entered = Completer<void>();
  final release = Completer<void>();

  @override
  Future<List<String>> listUsers() async {
    if (!entered.isCompleted) entered.complete();
    await release.future;
    return super.listUsers();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  late List<TheoryInjectionSchedulerService> schedulers;
  late List<TheoryLinkAutoInjector> injectors;
  late TheoryLinkConfig originalConfig;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    originalConfig = TheoryLinkConfigService.instance.value;
    TheoryLinkConfigService.instance.notifier.value = TheoryLinkConfig.defaults;
    schedulers = [];
    injectors = [];
    root = await Directory.systemTemp.createTemp('scheduler_store_scope');
  });

  tearDown(() async {
    for (final scheduler in schedulers) {
      await scheduler.dispose();
    }
    for (final injector in injectors) {
      injector.dispose();
    }
    TheoryLinkConfigService.instance.notifier.value = originalConfig;
    if (root.existsSync()) await root.delete(recursive: true);
  });

  TheoryInjectionSchedulerService ownScheduler(LearningPathStore store) {
    final scheduler = TheoryInjectionSchedulerService.forStore(
      store: store,
      libraryIndex: _ScopedTheoryIndex(),
      noveltyRegistry: TheoryNoveltyRegistry(
        path: '${store.rootDir}/theory_bundles/registry.json',
      ),
    );
    schedulers.add(scheduler);
    return scheduler;
  }

  InjectedPathModule pendingModule(String user) => InjectedPathModule(
    moduleId: 'module_$user',
    clusterId: 'cluster_$user',
    themeName: 'Store isolation',
    theoryIds: const [],
    boosterPackIds: const ['booster'],
    assessmentPackId: 'assessment',
    createdAt: DateTime.utc(2026, 1, 1),
    triggerReason: 'test',
    metrics: const {
      'clusterTags': ['scope_tag'],
    },
    itemsDurations: const {'boosterMins': 3, 'assessmentMins': 1},
  );

  Future<LearningPathStore> completedStore(String name, String user) async {
    final store = LearningPathStore(rootDir: '${root.path}/$name');
    await store.upsertModule(
      user,
      InjectedPathModule(
        moduleId: 'module_$user',
        clusterId: 'cluster_$user',
        themeName: 'Store isolation',
        theoryIds: const [],
        boosterPackIds: const ['booster'],
        assessmentPackId: 'assessment',
        createdAt: DateTime.utc(2026, 1, 1),
        triggerReason: 'test',
        status: 'completed',
      ),
    );
    return store;
  }

  test('one-shot processing uses only its bound store', () async {
    final selected = await completedStore('selected', 'selected_user');
    final other = await completedStore('other', 'other_user');
    final selectedBefore = (await selected.listModules(
      'selected_user',
    )).map((m) => m.toJson()).toList();
    final otherBefore = (await other.listModules(
      'other_user',
    )).map((m) => m.toJson()).toList();

    await ownScheduler(selected).runNow(force: true);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theoryScheduler.lastRun.selected_user'), isNotNull);
    expect(prefs.getString('theoryScheduler.lastRun.other_user'), isNull);
    expect(
      (await selected.listModules(
        'selected_user',
      )).map((m) => m.toJson()).toList(),
      selectedBefore,
    );
    expect(
      (await other.listModules('other_user')).map((m) => m.toJson()).toList(),
      otherBefore,
    );
  });

  test('empty store does not create a user or a synthetic receipt', () async {
    final store = LearningPathStore(rootDir: '${root.path}/empty');
    await ownScheduler(store).runNow(force: true);
    final prefs = await SharedPreferences.getInstance();
    expect(await store.listUsers(), isEmpty);
    expect(prefs.getString('theoryScheduler.lastRun.missing_user'), isNull);
    expect(
      prefs.getKeys().where((k) => k.startsWith('theoryScheduler.lastRun.')),
      isEmpty,
    );
    expect(Directory(store.rootDir).existsSync(), isFalse);
  });

  test(
    'repeat and forced runs preserve modules and interval semantics',
    () async {
      final store = await completedStore('repeat', 'repeat_user');
      final scheduler = ownScheduler(store);
      final before = (await store.listModules(
        'repeat_user',
      )).map((m) => m.toJson()).toList();
      await scheduler.runNow(force: true);
      final prefs = await SharedPreferences.getInstance();
      final firstReceipt = prefs.getString(
        'theoryScheduler.lastRun.repeat_user',
      );
      expect(firstReceipt, isNotNull);

      await scheduler.runNow();
      expect(
        prefs.getString('theoryScheduler.lastRun.repeat_user'),
        firstReceipt,
      );
      await scheduler.runNow(force: true);
      final status = AutogenStatusDashboardService.instance.getStatus(
        'TheoryInjectionScheduler',
      );
      expect(status, isNotNull);
      final counts = jsonDecode(status!.currentStage) as Map<String, dynamic>;
      expect(counts['skipped'], 3);
      expect(
        (await store.listModules(
          'repeat_user',
        )).map((m) => m.toJson()).toList(),
        before,
      );
    },
  );

  test('manual run before start never creates a periodic timer', () async {
    final store = await completedStore('manual', 'manual_user');
    final scheduler = ownScheduler(store);
    await runZoned(
      () async {
        await scheduler.runNow(force: true);
        await scheduler.runNow();
      },
      zoneSpecification: ZoneSpecification(
        createPeriodicTimer: (self, parent, zone, period, callback) {
          throw StateError('Manual scheduler run must not start a timer');
        },
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theoryScheduler.lastRun.manual_user'), isNotNull);
  });

  test(
    'explicit start retains its periodic lifecycle and stop cancels it',
    () async {
      final store = await completedStore('periodic', 'periodic_user');
      final scheduler = ownScheduler(store);
      Timer? periodic;
      var creations = 0;
      try {
        await runZoned(
          () => scheduler.start(),
          zoneSpecification: ZoneSpecification(
            createPeriodicTimer: (self, parent, zone, period, callback) {
              creations++;
              periodic = parent.createPeriodicTimer(zone, period, callback);
              return periodic!;
            },
          ),
        );
        expect(creations, 1);
        expect(periodic!.isActive, isTrue);
      } finally {
        await scheduler.stop();
      }
      expect(periodic!.isActive, isFalse);
    },
  );

  test(
    'pending injection updates only the selected store and remains idempotent',
    () async {
      final selected = LearningPathStore(rootDir: '${root.path}/pending');
      final other = LearningPathStore(rootDir: '${root.path}/other_pending');
      await selected.upsertModule(
        'pending_user',
        pendingModule('pending_user'),
      );
      await other.upsertModule('other_user', pendingModule('other_user'));
      final otherBefore = (await other.listModules(
        'other_user',
      )).map((m) => m.toJson()).toList();
      final scheduler = ownScheduler(selected);

      await scheduler.runNow(force: true);

      final modules = await selected.listModules('pending_user');
      expect(modules, hasLength(1));
      expect(modules.single.theoryIds, ['scope_theory']);
      expect(modules.single.itemsDurations, {
        'boosterMins': 3,
        'assessmentMins': 1,
        'theoryMins': 5,
      });
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('theoryScheduler.lastRun.pending_user'),
        isNotNull,
      );
      expect(prefs.getString('theoryScheduler.lastRun.other_user'), isNull);
      expect(
        (await other.listModules('other_user')).map((m) => m.toJson()).toList(),
        otherBefore,
      );

      final first = modules.map((m) => m.toJson()).toList();
      await scheduler.runNow(force: true);
      expect(
        (await selected.listModules(
          'pending_user',
        )).map((m) => m.toJson()).toList(),
        first,
      );
    },
  );

  test('dispose removes only owned listeners and rejects reuse', () async {
    final config = TheoryLinkConfigService.instance;
    final prefs = await SharedPreferences.getInstance();
    TheoryLinkAutoInjector ownInjector(String name) {
      final injector = TheoryLinkAutoInjector(
        store: LearningPathStore(rootDir: '${root.path}/$name'),
        libraryIndex: _ScopedTheoryIndex(),
        telemetry: MistakeTelemetryStore(),
        noveltyRegistry: TheoryNoveltyRegistry(
          path: '${root.path}/$name/theory_bundles/registry.json',
        ),
        policy: TheoryLinkPolicyEngine(prefs: prefs),
        config: config,
      );
      injectors.add(injector);
      return injector;
    }

    final disposed = ownInjector('disposed');
    final active = ownInjector('active');
    final previousMax = disposed.maxPerModule;
    disposed.dispose();
    disposed.dispose();
    await prefs.setInt('theory.maxPerModule', previousMax + 1);
    await config.reload();
    expect(active.maxPerModule, previousMax + 1);
    expect(disposed.maxPerModule, previousMax);
    await expectLater(disposed.injectForUser('unused'), throwsStateError);
    active.dispose();

    final store = await completedStore('dispose_scheduler', 'dispose_user');
    final scheduler = ownScheduler(store);
    await scheduler.runNow(force: true);
    await scheduler.dispose();
    await scheduler.dispose();
    await expectLater(scheduler.runNow(), throwsStateError);
    await expectLater(scheduler.start(), throwsStateError);
  });

  test('dispose waits for an active one-shot run before teardown', () async {
    final store = _GatedUserStore(rootDir: '${root.path}/gated');
    await store.upsertModule(
      'gated_user',
      pendingModule('gated_user').copyWith(status: 'completed'),
    );
    final scheduler = ownScheduler(store);
    final running = scheduler.runNow(force: true);
    await store.entered.future;
    var finished = false;
    final closing = scheduler.dispose().then((_) => finished = true);
    try {
      await Future<void>.delayed(Duration.zero);
      expect(finished, isFalse);
    } finally {
      if (!store.release.isCompleted) store.release.complete();
      await running;
      await closing;
    }
    expect(finished, isTrue);
    await expectLater(scheduler.runNow(), throwsStateError);
  });
}
