class ActionBarIntent {
  const ActionBarIntent(this.kind);

  final String kind;
}

class ActionBarEngine {
  ActionBarEngine({this.onFold, this.onCall, this.onRaise});

  final void Function()? onFold;
  final void Function()? onCall;
  final void Function()? onRaise;

  void handle(ActionBarIntent intent) {
    switch (intent.kind) {
      case 'fold':
        onFold?.call();
        break;
      case 'call':
        onCall?.call();
        break;
      case 'raise':
        onRaise?.call();
        break;
    }
  }
}
