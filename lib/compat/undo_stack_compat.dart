import "dart:core";

class UndoStackCompat {
  const UndoStackCompat();
  void push(Object snapshot) {}
  Object? pop() => null;
  bool get canUndo => false;
  bool get canRedo => false;
  void clear() {}
}
