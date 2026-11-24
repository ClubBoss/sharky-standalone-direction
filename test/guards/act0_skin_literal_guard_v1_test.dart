import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:test/test.dart';

const _shell = 'lib/ui_v2/act0_shell';
const _baselinePath = 'test/guards/act0_skin_literal_baseline_v1.json';

// Existing token owners and frozen Modern Table presentation owners.
const _excluded = {
  'act0_academy_design_tokens_v1.dart',
  'act0_club_night_components_v1.dart',
  'act0_club_night_tokens_v1.dart',
  'act0_shell_tokens_v1.dart',
  'act0_table_skin_v1.dart',
  'act0_table_geometry_v1.dart',
  'act0_table_presentation_config_v1.dart',
  'act0_lesson_runner_table_v1.dart',
  'act0_lesson_runner_seats_v1.dart',
  'act0_scene_character_asset_v1.dart',
  'act0_scene_depth_v1.dart',
  'act0_scene_hud_v1.dart',
  'act0_scene_hybrid_shell_v1.dart',
  'act0_scene_material_v1.dart',
  'act0_scene_player_v1.dart',
  'act0_scene_profile_v1.dart',
  'act0_scene_room_plate_v1.dart',
  'act0_scene_salience_v1.dart',
};

final _generatedSuffix = RegExp(r'\.(g|freezed|gr|mocks)\.dart$');
final _generatedHeader = RegExp(
  r'^\s*//[^\n]*(?:GENERATED CODE|AUTO[- ]GENERATED|DO NOT EDIT)',
  caseSensitive: false,
);

bool _isNumber(Expression expression) => switch (expression) {
  IntegerLiteral() || DoubleLiteral() => true,
  ParenthesizedExpression(:final expression) => _isNumber(expression),
  PrefixExpression(:final operator, :final operand) =>
    operator.lexeme == '-' && _isNumber(operand),
  _ => false,
};

String _callName(AstNode? node) => switch (node) {
  InstanceCreationExpression(:final constructorName) =>
    constructorName.toSource(),
  MethodInvocation(:final target, :final methodName) =>
    target == null
        ? methodName.name
        : '${target.toSource()}.${methodName.name}',
  _ => '',
};

bool _isTextStyleColor(ArgumentList arguments) {
  AstNode? expression = arguments.parent;
  while (expression?.parent is ParenthesizedExpression) {
    expression = expression!.parent;
  }
  final parent = expression?.parent;
  return parent is NamedExpression &&
      parent.name.label.name == 'color' &&
      _callName(parent.parent?.parent).split('.').last == 'TextStyle';
}

bool _hasNumericArgument(ArgumentList node) => node.arguments.any(
  (argument) =>
      _isNumber(argument is NamedExpression ? argument.expression : argument),
);

class _StyleLiterals extends RecursiveAstVisitor<void> {
  int count = 0;

  @override
  void visitArgumentList(ArgumentList node) {
    // Without const/new, the parser can represent a constructor as a call.
    final name = _callName(node.parent);
    final parts = name.split('.');
    final arguments = node.arguments;
    final single = arguments.length == 1
        ? arguments.single.unParenthesized
        : null;
    final hexColor =
        parts.last == 'Color' &&
        single is IntegerLiteral &&
        single.literal.lexeme.toLowerCase().startsWith('0x');
    final colorConstructor =
        parts.last == 'Color' ||
        (parts.length >= 2 && parts[parts.length - 2] == 'Color');
    if (hexColor ||
        (colorConstructor &&
            _isTextStyleColor(node) &&
            _hasNumericArgument(node))) {
      count++;
    } else if (parts.last == 'TextStyle') {
      for (final argument in arguments.whereType<NamedExpression>()) {
        if (argument.name.label.name == 'fontSize' &&
            _isNumber(argument.expression)) {
          count++;
        }
      }
    } else if (name == 'BorderRadius.circular' ||
        name.endsWith('.BorderRadius.circular') ||
        parts.last == 'EdgeInsets' ||
        (parts.length >= 2 && parts[parts.length - 2] == 'EdgeInsets')) {
      if (_hasNumericArgument(node)) count++;
    }
    super.visitArgumentList(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.prefix.name == 'Colors' && node.identifier.name != 'transparent') {
      count++;
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final target = node.target;
    if (target is PrefixedIdentifier &&
        target.identifier.name == 'Colors' &&
        node.propertyName.name != 'transparent') {
      count++;
    }
    super.visitPropertyAccess(node);
  }
}

int _countLiterals(String source) {
  final visitor = _StyleLiterals();
  parseString(content: source).unit.accept(visitor);
  return visitor.count;
}

Map<String, int> _scanShell() {
  final counts = <String, int>{};
  final files = Directory(_shell).listSync(recursive: true, followLinks: false)
    ..sort((left, right) => left.path.compareTo(right.path));
  for (final file in files.whereType<File>()) {
    final path = file.path.replaceAll(r'\', '/').substring(_shell.length + 1);
    if (!path.endsWith('.dart') ||
        path.startsWith('skin/') ||
        _excluded.contains(path) ||
        _generatedSuffix.hasMatch(path)) {
      continue;
    }
    final source = file.readAsStringSync();
    if (_generatedHeader.hasMatch(source)) continue;
    final count = _countLiterals(source);
    if (count > 0) counts[path] = count;
  }
  return counts;
}

List<String> _increases(Map<String, int> counts, Map<String, int> baseline) => [
  for (final entry in counts.entries)
    if (entry.value > (baseline[entry.key] ?? 0))
      '${entry.key}: ${entry.value} (allowed ${baseline[entry.key] ?? 0})',
];

void main() {
  test('style scan handles Dart syntax and token references', () {
    expect(
      _countLiterals("""
        void sample() {
          // Color(0xff112233)
          final copy = 'Colors.red and EdgeInsets.all(8)';
          final style = const TextStyle(
            color: Color(/* accent */ 0xff112233),
            fontSize: 12.5,
          );
          final another = TextStyle(color: material.Colors.red);
          final rgb = TextStyle(color: Color.fromARGB(255, 1, 2, 3));
          final tokenStyle = TextStyle(
            fontSize: skin.bodySize, color: Colors.transparent,
          );
          final gap = const EdgeInsets.only(left: skin.gutter, top: 8);
          final radius = BorderRadius.circular(4);
          final inset = EdgeInsets.all(skin.gutter);
        }
      """),
      6,
    );
  });

  test('allowances apply per file and default to zero', () {
    expect(
      _increases(
        {'reduced.dart': 1, 'increased.dart': 3, 'new.dart': 1},
        {'reduced.dart': 5, 'increased.dart': 2, 'removed.dart': 2},
      ),
      ['increased.dart: 3 (allowed 2)', 'new.dart: 1 (allowed 0)'],
    );
  });

  test('Act0 shell style literals stay within the per-file baseline', () {
    final baseline =
        (jsonDecode(File(_baselinePath).readAsStringSync())
                as Map<String, dynamic>)
            .cast<String, int>();
    final counts = _scanShell();
    final ranked = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount == 0 ? a.key.compareTo(b.key) : byCount;
      });

    print(
      'Act0 shell style literals: ${counts.values.fold(0, (a, b) => a + b)}',
    );
    for (final entry in ranked.take(10)) {
      print('  ${entry.value}  ${entry.key}');
    }

    expect(
      _increases(counts, baseline),
      isEmpty,
      reason:
          'Use the skin layer for new styling. Lower baseline counts as files migrate.',
    );
  });
}
