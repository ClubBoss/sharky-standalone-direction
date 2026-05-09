import 'dart:io';

class AtomicWriteV1 {
  static Future<void> writeString(File target, String contents) async {
    target.parent.createSync(recursive: true);
    final tmp = File('${target.path}.tmp');
    final backup = File('${target.path}.bak');
    if (tmp.existsSync()) {
      try {
        tmp.deleteSync();
      } catch (_) {}
    }
    final raf = tmp.openSync(mode: FileMode.write);
    raf.writeStringSync(contents);
    raf.flushSync();
    raf.closeSync();
    if (target.existsSync()) {
      try {
        if (backup.existsSync()) backup.deleteSync();
      } catch (_) {}
      try {
        await target.rename(backup.path);
      } catch (_) {
        try {
          await target.copy(backup.path);
        } catch (_) {}
      }
    }
    try {
      await tmp.rename(target.path);
    } catch (_) {
      await tmp.copy(target.path);
      await tmp.delete().catchError((_) => tmp);
    }
  }

  static Future<String?> readString(File target) async {
    if (!target.existsSync()) return null;
    return target.readAsString();
  }
}
