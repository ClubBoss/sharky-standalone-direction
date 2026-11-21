import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'act0_catalog_truth_audit_v1.dart';

ArgumentList? _constructor(AstNode node, String name) => switch (node) {
  InstanceCreationExpression()
      when node.constructorName.type.name2.lexeme == name =>
    node.argumentList,
  MethodInvocation() when node.target == null && node.methodName.name == name =>
    node.argumentList,
  _ => null,
};

Expression? _argument(ArgumentList list, String name) => list.arguments
    .whereType<NamedExpression>()
    .where((item) => item.name.label.name == name)
    .firstOrNull
    ?.expression;

void auditCatalogReachability(String source, CatalogAudit audit) =>
    auditCatalogReachabilitySources([source], audit);

void auditCatalogReachabilitySources(
  Iterable<String> sources,
  CatalogAudit audit,
) {
  final bindings = <String, AstNode>{};
  for (final source in sources) {
    final unit = parseString(content: source).unit;
    for (final top
        in unit.declarations.whereType<TopLevelVariableDeclaration>()) {
      for (final variable in top.variables.variables) {
        if (variable.initializer != null) {
          bindings[variable.name.lexeme] = variable.initializer!;
        }
      }
    }
    for (final top in unit.declarations.whereType<FunctionDeclaration>()) {
      bindings[top.name.lexeme] = top.functionExpression.body;
    }
  }
  final reachable = _CatalogDeclarations(bindings)
    ..visitBinding('_act0PreviewWorlds');
  final declared = _CatalogDeclarations(const {});
  for (final entry in bindings.entries) {
    declared.owner = entry.key;
    entry.value.accept(declared);
  }
  for (final entry in declared.tasks.entries) {
    final (id, owner) = entry.value;
    audit.dormant(id, reachable.tasks.containsKey(entry.key) ? '' : owner);
  }
  for (final entry in bindings.entries) {
    final name = entry.key;
    final init = entry.value;
    final arguments =
        _constructor(init, 'Act0RunnerStateV1') ??
        (init is MethodInvocation && init.methodName.name == 'copyWith'
            ? init.argumentList
            : null);
    if (arguments == null || _argument(arguments, 'lessonId') is! StringLiteral)
      continue;
    final id =
        (_argument(arguments, 'lessonId') as StringLiteral).stringValue ?? name;
    audit.dormant(id, reachable.visited.contains(name) ? '' : name);
  }
}

// The catalog borrows some exact lessons through an indexed donor list.
// Visiting the whole donor would mark dormant siblings as reachable.
class _CatalogDeclarations extends RecursiveAstVisitor<void> {
  _CatalogDeclarations(this.bindings);

  final Map<String, AstNode> bindings;
  final visited = <String>{};
  final tasks = <AstNode, (String, String)>{};
  var owner = '';

  void visitBinding(String name) {
    final node = bindings[name];
    if (node == null || !visited.add(name)) return;
    final previous = owner;
    owner = name;
    node.accept(this);
    owner = previous;
  }

  void _task(AstNode node) {
    final args = _constructor(node, 'Act0LessonTaskV1');
    if (args == null) return;
    final id = _argument(args, 'taskId');
    if (id is StringLiteral && id.stringValue != null) {
      tasks[node] = (id.stringValue!, owner);
    }
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _task(node);
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _task(node);
    super.visitMethodInvocation(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) => visitBinding(node.name);

  @override
  void visitIndexExpression(IndexExpression node) {
    final target = node.realTarget;
    final index = node.index;
    if (target is SimpleIdentifier && index is IntegerLiteral) {
      final list = bindings[target.name];
      final offset = index.value;
      if (list is ListLiteral &&
          offset != null &&
          offset >= 0 &&
          offset < list.elements.length &&
          list.elements.every((element) => element is Expression)) {
        final previous = owner;
        owner = target.name;
        list.elements[offset].accept(this);
        owner = previous;
        return;
      }
    }
    super.visitIndexExpression(node);
  }
}
