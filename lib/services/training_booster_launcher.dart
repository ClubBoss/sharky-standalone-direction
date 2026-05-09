import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import '../models/v2/training_pack_template.dart';
import '../models/v2/training_spot_v2.dart';
import '../screens/training_session_screen.dart';
import 'training_session_service.dart';

/// Launches an ad-hoc booster pack built from training spots.
class TrainingBoosterLauncher {
  TrainingBoosterLauncher();

  /// Starts a training session for [spots] if the list is not empty.
  Future<void> launch(List<TrainingSpotV2> spots) async {
    if (spots.isEmpty) return;
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    final tpl = TrainingPackTemplate(
      id: const Uuid().v4(),
      name: 'Decay Booster',
      tags: const ['booster', 'decay'],
      spots: [],
    );
    await ctx.read<TrainingSessionService>().startSession(tpl, persist: false);
    await Navigator.push(
      ctx,
      canonicalLegacyTrainingImplicitRouteV1(
        input:
            const CanonicalLegacyTrainingImplicitLaunchInputV1.activeSession(),
      ),
    );
  }
}
