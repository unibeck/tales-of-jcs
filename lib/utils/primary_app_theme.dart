import 'package:flutter/material.dart';

///Used https://material.io/design/color/the-color-system.html#tools-for-picking-colors
/// to determine color swatch based on Yale and Harvard school colors
class PrimaryAppTheme {
  PrimaryAppTheme._();

  static const int yaleBlueValue = 0xFF0f4d92;
  static const int harvardCrimsonValue = 0xFFa51c30;

  static const MaterialColor _primaryColorSwatch = MaterialColor(
    yaleBlueValue,
    const <int, Color>{
      50: const Color(0xFFe4f2fb),
      100: const Color(0xFFbddff5),
      200: const Color(0xFF94cbf0),
      300: const Color(0xFF6db7e9),
      400: const Color(0xFF4fa7e6),
      500: const Color(0xFF3599e2),
      600: const Color(0xFF2d8cd5),
      700: const Color(0xFF247ac3),
      800: const Color(0xFF1c69b1),
      900: const Color(yaleBlueValue),
    },
  );

  static const MaterialColor _accentColorSwatch = MaterialColor(
    harvardCrimsonValue,
    const <int, Color>{
      50: const Color(0xFFfbeaef),
      100: const Color(0xFFf5cbd5),
      200: const Color(0xFFe297a1),
      300: const Color(0xFFd4707e),
      400: const Color(0xFFde4f61),
      500: const Color(0xFFe43b4c),
      600: const Color(0xFFd4334a),
      700: const Color(0xFFc22b42),
      800: const Color(0xFFb5253b),
      900: const Color(harvardCrimsonValue),
    },
  );

//  static const Color _yaleBlueLightColor = Color(0xFF5077c2);
//  static const Color _yaleBlueDarkColor = Color(0xFF002563);
//  static const Color _harvardCrimsonLightColor = Color(0xFFdc5259);
//  static const Color _harvardCrimsonDarkColor = Color(0xFF6f0009);

  static ThemeData buildTheme(Brightness brightness) {
    if (brightness == Brightness.light) {
      return _buildLightTheme();
    } else {
      return _buildDarkTheme();
    }
  }

  static ThemeData _buildLightTheme() {
    return ThemeData.light().copyWith(
        primaryColor: _primaryColorSwatch[500],
        primaryColorLight: _primaryColorSwatch[300],
        primaryColorDark: _primaryColorSwatch[900],
        accentColor: _accentColorSwatch[500],
        backgroundColor: Colors.white,
        buttonColor: _primaryColorSwatch[500],
        scaffoldBackgroundColor: Colors.white,
        textSelectionHandleColor: Colors.black,
        textSelectionColor: Colors.black12,
        cursorColor: Colors.black,
        toggleableActiveColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
          colorScheme:
              ColorScheme.fromSwatch(primarySwatch: _primaryColorSwatch),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ));
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
        primaryColor: _primaryColorSwatch[800],
        primaryColorLight: _primaryColorSwatch[500],
        primaryColorDark: _primaryColorSwatch[900],
        accentColor: _accentColorSwatch[500],
        backgroundColor: Colors.black,
        canvasColor: Color(0xFF1a1a1a),
        buttonColor: _accentColorSwatch[500],
        scaffoldBackgroundColor: Colors.black,
        textSelectionHandleColor: Colors.white,
        textSelectionColor: Colors.white70,
        cursorColor: Colors.white,
        toggleableActiveColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
          ),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
        buttonTheme: ButtonThemeData(
          colorScheme:
              ColorScheme.fromSwatch(primarySwatch: _accentColorSwatch),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ));
  }
}
