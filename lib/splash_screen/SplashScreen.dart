import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tales_of_jcs/utils/primary_app_theme.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<Timer> loadData() async {
    return Timer(Duration(seconds: 3000), onDoneLoading);
  }

  onDoneLoading() async {
    Navigator.pushReplacementNamed(context, 'home');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
//        color: Colors.white,
        color: Color(PrimaryAppTheme.yaleBlueValue).withOpacity(1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Center(
                    child: Text(
                  "Tales of JCS",
                  style: Theme.of(context).textTheme.headline.copyWith(
//                    color: Color(PrimaryAppTheme.harvardCrimsonValue),
                    color: Colors.white,
//                    fontStyle: FontStyle.italic,
                    fontSize: 48,
                    fontFamily: "Roboto"
                  ),
                ))),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/unicorn_jcs.png'),
                      fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
