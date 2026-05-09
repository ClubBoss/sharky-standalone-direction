typedef VoidCallback = void Function();

void debugPrint(String? message) {}

class Widget {
  const Widget();
}

class BuildContext {
  const BuildContext();
}

class Color {
  const Color(int value);
}

class Alignment {
  final double x;
  final double y;
  const Alignment(this.x, this.y);

  static const Alignment center = Alignment(0, 0);
}

class SizedBox extends Widget {
  final double? width;
  final double? height;
  const SizedBox({this.width, this.height});
  const SizedBox.shrink() : width = null, height = null;
}

class ChangeNotifier {
  const ChangeNotifier();
  void addListener(VoidCallback listener) {}
  void removeListener(VoidCallback listener) {}
  void notifyListeners() {}
  void dispose() {}
}

class ValueNotifier<T> extends ChangeNotifier {
  ValueNotifier(this.value);
  T value;
}

enum AppLifecycleState { inactive, paused, resumed }

abstract class StatelessWidget extends Widget {
  const StatelessWidget();
  Widget build(BuildContext context);
}

abstract class StatefulWidget extends Widget {
  const StatefulWidget();
  State<StatefulWidget> createState();
}

abstract class State<T extends StatefulWidget> {
  void initState() {}
  void dispose() {}
  void setState(VoidCallback fn) => fn();
  Widget build(BuildContext context);
}

class MaterialApp extends Widget {
  final Widget? home;
  final String? title;
  const MaterialApp({this.home, this.title});
}

class Scaffold extends Widget {
  final Widget? body;
  final Widget? appBar;
  final Widget? floatingActionButton;
  const Scaffold({this.body, this.appBar, this.floatingActionButton});
}

typedef WidgetBuilder = Widget Function(BuildContext context);

class Navigator {
  const Navigator();

  static NavigatorState of(BuildContext context) => const NavigatorState();
}

class NavigatorState {
  const NavigatorState();

  Future<T?> push<T>(dynamic route) async => null;
  void pop<T>([T? result]) {}
}

class MaterialPageRoute<T> {
  final WidgetBuilder builder;
  const MaterialPageRoute({required this.builder});
}

class Text extends Widget {
  final String data;
  final TextAlign? textAlign;
  const Text(this.data, {this.textAlign});
}

enum TextAlign { left, center, right }

class Icon extends Widget {
  final Object? icon;
  final double? size;
  const Icon(this.icon, {this.size});
}

class Image extends Widget {
  const Image._();

  factory Image.asset(String name, {double? width, double? height}) =>
      const Image._();

  factory Image.network(String url, {double? width, double? height}) =>
      const Image._();
}

class Colors {
  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color red = Color(0xFFFF0000);
  static const Color green = Color(0xFF00FF00);
  static const Color blue = Color(0xFF0000FF);
  static const Color grey = Color(0xFF888888);
}

class EdgeInsets {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const EdgeInsets._(this.left, this.top, this.right, this.bottom);

  const EdgeInsets.all(double value) : this._(value, value, value, value);

  const EdgeInsets.symmetric({double horizontal = 0, double vertical = 0})
    : this._(horizontal, vertical, horizontal, vertical);

  const EdgeInsets.only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) : this._(left, top, right, bottom);

  const EdgeInsets.fromLTRB(
    double left,
    double top,
    double right,
    double bottom,
  ) : this._(left, top, right, bottom);

  static const EdgeInsets zero = EdgeInsets.all(0);
}

class Padding extends Widget {
  final EdgeInsets padding;
  final Widget child;
  const Padding({required this.padding, required this.child});
}

enum MainAxisAlignment { start, center, end }

enum CrossAxisAlignment { start, center, end }

class Column extends Widget {
  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  const Column({
    this.children = const <Widget>[],
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  });
}

class Row extends Widget {
  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  const Row({
    this.children = const <Widget>[],
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  });
}

class Expanded extends Widget {
  final Widget child;
  const Expanded({required this.child});
}

class Center extends Widget {
  final Widget? child;
  const Center({this.child});
}
