import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/error_logger.dart';

class PreviewCacheService {
  PreviewCacheService._();
  static final instance = PreviewCacheService._();

  final _inFlight = <String, Future<String?>>{};

  Future<String?> getPreviewPath(String filename) {
    final safe = p.basename(filename);
    if (_inFlight.containsKey(safe)) return _inFlight[safe]!;
    final future = _load(safe);
    _inFlight[safe] = future.whenComplete(() => _inFlight.remove(safe));
    return future;
  }

  Future<String?> _load(String safe) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'asset_cache', 'preview', safe));
      return await file.exists() ? file.path : null;
    } catch (e, st) {
      ErrorLogger.instance.logError('Preview load failed: $safe', e, st);
      return null;
    }
  }
}
