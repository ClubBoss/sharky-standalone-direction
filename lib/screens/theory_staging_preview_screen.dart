import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/pack_library.dart';
import '../models/v2/training_pack_template_v2.dart';
import '../models/v2/training_pack_v2.dart';
import '../services/canonical_legacy_training_launch_v1.dart';
import '../theme/app_colors.dart';

class TheoryStagingPreviewScreen extends StatefulWidget {
  TheoryStagingPreviewScreen({super.key});

  @override
  State<TheoryStagingPreviewScreen> createState() =>
      _TheoryStagingPreviewScreenState();
}

class _TheoryStagingPreviewScreenState
    extends State<TheoryStagingPreviewScreen> {
  final List<TrainingPackTemplateV2> _packs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _packs
        ..clear()
        ..addAll(PackLibrary.staging.packs);
    });
  }

  void _preview(TrainingPackTemplateV2 tpl) {
    final pack = TrainingPackV2.fromTemplate(tpl, tpl.id);
    pushCanonicalLegacyTrainingV1<void>(
      context,
      input: CanonicalLegacyTrainingLaunchInputV1.pack(pack: pack),
    );
  }

  void _delete(TrainingPackTemplateV2 tpl) {
    PackLibrary.staging.remove(tpl.id);
    setState(() => _packs.removeWhere((p) => p.id == tpl.id));
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Staging Theory')),
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _packs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final tpl = _packs[i];
          return ListTile(
            title: Text(tpl.name),
            subtitle: Text(
              '${tpl.trainingType.name} • ${tpl.id}\n${tpl.tags.join(', ')}',
            ),
            isThreeLine: true,
            trailing: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _preview(tpl),
                  child: const Text('👁 Предпросмотр'),
                ),
                ElevatedButton(
                  onPressed: () => _delete(tpl),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('🗑 Удалить'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
