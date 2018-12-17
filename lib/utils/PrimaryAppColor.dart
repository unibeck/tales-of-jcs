import 'package:flutter/material.dart';

class PrimaryAppColor {
  PrimaryAppColor._(); // this basically makes it so you can instantiate this class

  static const _yaleBluePrimaryValue = 0xFF0f4d92;

  static const MaterialColor primary = const MaterialColor(
    _yaleBluePrimaryValue,
    const <int, Color>{
      50:  const Color(0xFFe0e0e0),
      100: const Color(0xFFb3b3b3),
      200: const Color(0xFF808080),
      300: const Color(0xFF4d4d4d),
      400: const Color(0xFF262626),
      500: const Color(_yaleBluePrimaryValue),
      600: const Color(0xFF000000),
      700: const Color(0xFF000000),
      800: const Color(0xFF000000),
      900: const Color(0xFF000000),
    },
  );
}