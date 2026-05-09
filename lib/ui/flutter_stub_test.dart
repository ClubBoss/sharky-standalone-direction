class Color {
  const Color(this.value);
  final int value;
}

class Alignment {
  const Alignment(this.x, this.y);
  final double x;
  final double y;

  static const center = Alignment(0, 0);
}

class Widget {
  const Widget();
}

class BuildContext {
  const BuildContext();
}

class SizedBox extends Widget {
  const SizedBox({this.height, this.width});
  final double? height;
  final double? width;
}

typedef VoidCallback = void Function();

void debugPrint(Object? object) {}

enum AppLifecycleState { resumed, inactive, paused, detached }

class ChangeNotifier {
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }

  void dispose() {
    _listeners.clear();
  }
}

class ValueNotifier<T> extends ChangeNotifier {
  ValueNotifier(this._value);

  T _value;

  T get value => _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }
}
