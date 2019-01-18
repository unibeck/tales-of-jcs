import 'package:flutter/material.dart';

import 'package:tales_of_jcs/home_page/home_page.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:tales_of_jcs/utils/primary_app_theme.dart';

void main() {
  runApp(TalesOfJCSApp());
}

class TalesOfJCSApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => PrimaryAppTheme.buildTheme(brightness),
      themedWidgetBuilder: (context, theme) => MaterialApp(
            theme: theme,
            title: 'Tales of JCS',
            home: HomePage(title: 'Tales'),
          ),
    );
  }
}
