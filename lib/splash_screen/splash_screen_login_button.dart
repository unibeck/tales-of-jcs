import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tales_of_jcs/home_page/home_page.dart';
import 'package:tales_of_jcs/services/analytics/firebase_analytics_service.dart';
import 'package:tales_of_jcs/services/auth/auth_service.dart';
import 'package:tales_of_jcs/utils/primary_app_theme.dart';

class SplashScreenButton extends StatefulWidget {
  @override
  _SplashScreenButtonState createState() => _SplashScreenButtonState();
}

class _SplashScreenButtonState extends State<SplashScreenButton> {
  bool _isLoggingIn = false;

  //Services
  final AuthService _authService = AuthService.instance;

  @override
  Widget build(BuildContext context) {
    if (_isLoggingIn) {
      return Padding(
        padding: EdgeInsets.only(top: 64),
        child: CircularProgressIndicator(),
      );
    } else {
      return Container(
        height: 48,
        margin: EdgeInsets.only(top: 64),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: PrimaryAppTheme.accentYaleColorSwatch.shade300,
                  offset: Offset(0, 8),
                  blurRadius: 16,
                  spreadRadius: -2),
            ],
            gradient: LinearGradient(
              colors: [
                PrimaryAppTheme.accentYaleColorSwatch.shade900,
                PrimaryAppTheme.accentYaleColorSwatch.shade300,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
        child: RawMaterialButton(
          highlightColor: PrimaryAppTheme.accentYaleColorSwatch.shade500,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onPressed: _loginAction,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 36),
            child: Text(
              "LOGIN",
              style: TextStyle(
                  color: Colors.white, fontSize: 24, fontFamily: "Roboto"),
            ),
          ),
        ),
      );
    }
  }

  void _loginAction() async {
    setState(() {
      _isLoggingIn = true;
    });

    _authService.signIn().then((FirebaseUser user) {
      Navigator.pushReplacementNamed(this.context, HomePage.routeName);
    }).catchError((error) {
      String errorMessage;
      if (error is AuthException) {
        errorMessage = error.message;
      } else {
        errorMessage = error.toString();
      }

      FirebaseAnalyticsService.analytics.logEvent(
          name: "failed_to_login", parameters: {"error": errorMessage});
      Scaffold.of(this.context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));

      setState(() {
        _isLoggingIn = false;
      });
    });
  }
}
