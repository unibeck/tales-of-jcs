import 'package:flutter/material.dart';

///Used https://material.io/inline-tools/color/
/// to determine color swatch based on Yale and Harvard school colors. Also
/// https://material.io/tools/color is useful
class PrimaryAppTheme {
  PrimaryAppTheme._();

  static const int yaleBlueValue = 0xFF0f4d92;
  static const MaterialColor primaryYaleColorSwatch = MaterialColor(
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

  static const int yaleAccentValue = 0xFFff8d00;
  static const MaterialColor accentYaleColorSwatch = MaterialColor(
    yaleAccentValue,
    const <int, Color>{
      50: const Color (0xFFfff2df),
      100: const Color(0xFFffddb0),
      200: const Color(0xFFffc77d),
      300: const Color(0xFFffaf49),
      400: const Color(0xFFff9e22),
      500: const Color(yaleAccentValue),
      600: const Color(0xFFfa8100),
      700: const Color(0xFFf47100),
      800: const Color(0xFFee6002),
      900: const Color(0xFFe54304),
    },
  );

  static const int harvardCrimsonValue = 0xFFa51c30;
  static const MaterialColor primaryHarvardColorSwatch = MaterialColor(
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

//  static const int harvardAccentValue = 0xFFa51c30;
//  static const MaterialColor accentHarvardColorSwatch = MaterialColor(
//    harvardAccentValue,
//    const <int, Color>{
//      50: const Color(0xFFfbeaef),
//      100: const Color(0xFFf5cbd5),
//      200: const Color(0xFFe297a1),
//      300: const Color(0xFFd4707e),
//      400: const Color(0xFFde4f61),
//      500: const Color(0xFFe43b4c),
//      600: const Color(0xFFd4334a),
//      700: const Color(0xFFc22b42),
//      800: const Color(0xFFb5253b),
//      900: const Color(harvardCrimsonValue),
//    },
//  );

//  static const Color _yaleBlueLightColor = Color(0xFF5077c2);
//  static const Color _yaleBlueDarkColor = Color(0xFF002563);
//  static const Color _harvardCrimsonLightColor = Color(0xFFdc5259);
//  static const Color _harvardCrimsonDarkColor = Color(0xFF6f0009);

  static ThemeData buildTheme(Brightness brightness) {
    if (brightness == Brightness.light) {
      return _buildYaleTheme();
    } else {
      return _buildHarvardTheme();
    }
  }

  static ThemeData _buildYaleTheme() {
    return ThemeData.light().copyWith(
        primaryColor: primaryYaleColorSwatch[500],
        primaryColorLight: primaryYaleColorSwatch[300],
        primaryColorDark: primaryYaleColorSwatch[900],
        accentColor: primaryHarvardColorSwatch[500],
        backgroundColor: Colors.white,
        buttonColor: primaryHarvardColorSwatch[500],
        scaffoldBackgroundColor: Colors.white,
        textSelectionHandleColor: Colors.black,
        textSelectionColor: Colors.black12,
        cursorColor: Colors.black,
        toggleableActiveColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
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
              ColorScheme.fromSwatch(primarySwatch: primaryHarvardColorSwatch),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ));
  }

  static ThemeData _buildHarvardTheme() {
    return ThemeData.dark().copyWith(
        primaryColor: primaryHarvardColorSwatch[500],
        primaryColorLight: primaryHarvardColorSwatch[300],
        primaryColorDark: primaryHarvardColorSwatch[900],
        accentColor: primaryYaleColorSwatch[500],
        backgroundColor: Colors.black,
        canvasColor: Color(0xFF1a1a1a),
        buttonColor: primaryYaleColorSwatch[500],
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
          colorScheme: ColorScheme.fromSwatch(primarySwatch: primaryYaleColorSwatch),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ));
  }
}
