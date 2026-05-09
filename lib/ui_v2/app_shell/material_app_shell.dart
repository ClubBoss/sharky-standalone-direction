import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../l10n/app_localizations.dart';

class MaterialAppShell extends StatelessWidget {
  const MaterialAppShell({
    super.key,
    required this.darkTheme,
    required this.themeMode,
    required this.locale,
    required this.navigatorKey,
    required this.navigatorObservers,
    required this.builder,
    required this.routes,
    required this.onGenerateRoute,
    required this.localeResolutionCallback,
    required this.home,
    required this.isV4RuntimeActive,
    required this.themeBuilder,
  });

  final ThemeMode themeMode;
  final ThemeData darkTheme;
  final Locale locale;
  final GlobalKey<NavigatorState> navigatorKey;
  final List<NavigatorObserver> navigatorObservers;
  final Widget Function(BuildContext, Widget?) builder;
  final Map<String, WidgetBuilder> routes;
  final RouteFactory onGenerateRoute;
  final Locale? Function(Locale?, Iterable<Locale>) localeResolutionCallback;
  final Widget home;
  final bool isV4RuntimeActive;
  final ThemeData Function(BuildContext, bool) themeBuilder;

  static const String _appTitle = 'Poker AI Analyzer';
  static const List<Locale> _supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru'),
    Locale('pt'),
    Locale('de'),
    Locale('zh'),
  ];
  static const List<LocalizationsDelegate<dynamic>> _localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigatorKey,
    navigatorObservers: navigatorObservers,
    title: _appTitle,
    debugShowCheckedModeBanner: false,
    themeMode: themeMode,
    theme: themeBuilder(context, isV4RuntimeActive),
    darkTheme: darkTheme,
    locale: locale,
    localizationsDelegates: _localizationsDelegates,
    supportedLocales: _supportedLocales,
    builder: builder,
    onGenerateRoute: onGenerateRoute,
    routes: routes,
    localeResolutionCallback: localeResolutionCallback,
    home: home,
  );
}
