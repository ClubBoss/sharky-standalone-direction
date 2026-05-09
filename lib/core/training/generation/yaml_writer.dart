import 'dart:io';
import 'package:json2yaml/json2yaml.dart';

class YamlWriter {
  const YamlWriter();

  Future<void> write(Object data, String path) async {
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsString(json2yaml(data as Map<String, dynamic>));
  }
}
