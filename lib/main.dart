import 'package:flutter/material.dart';

import 'package:fluro/fluro.dart';

import 'package:tales_of_jcs/home_page/home_page.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:tales_of_jcs/splash_screen/SplashScreen.dart';
import 'package:tales_of_jcs/utils/primary_app_theme.dart';

void main() {
  runApp(TalesOfJCSApp());
}

class TalesOfJCSApp extends StatelessWidget {
  static final Router router = _createRouter();

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => PrimaryAppTheme.buildTheme(brightness),
      themedWidgetBuilder: (context, theme) => MaterialApp(
          theme: theme,
          title: 'Tales of JCS',
          home: SplashScreen(),
          onGenerateRoute: router.generator),
    );
  }

  static Router _createRouter() {
    Router router = Router();

    // Define our splash page.
    router.define('splash', handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return SplashScreen();
    }));

    // Define our home page.
    router.define('home', transitionType: TransitionType.fadeIn, handler:
        Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return HomePage();
    }));

    return router;
  }
}
