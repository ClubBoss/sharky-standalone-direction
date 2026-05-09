String encodeYaml(Object data) {
  final buffer = StringBuffer();

  void writeYaml(dynamic value, int indent) {
    final prefix = ' ' * indent;
    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key;
        final val = entry.value;
        if (val is Map || val is List) {
          buffer.writeln('$prefix$key:');
          writeYaml(val, indent + 2);
        } else {
          buffer.writeln('$prefix$key: ${_yamlScalar(val)}');
        }
      }
    } else if (value is List) {
      for (final item in value) {
        if (item is Map || item is List) {
          buffer.writeln('$prefix-');
          writeYaml(item, indent + 2);
        } else {
          buffer.writeln('$prefix- ${_yamlScalar(item)}');
        }
      }
    } else if (value != null) {
      buffer.writeln('$prefix${_yamlScalar(value)}');
    }
  }

  writeYaml(data, 0);
  return buffer.toString();
}

String _yamlScalar(dynamic value) {
  if (value == null) return 'null';
  if (value is num || value is bool) return value.toString();
  final str = value.toString();
  if (RegExp(r'[#:>\n]').hasMatch(str) || str.trim() != str) {
    final escaped = str.replaceAll('"', '\\"');
    return '"$escaped"';
  }
  return str;
}
