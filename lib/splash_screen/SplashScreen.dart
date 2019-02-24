import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tales_of_jcs/home_page/home_page.dart';
import 'package:tales_of_jcs/utils/primary_app_theme.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "/SplashScreen";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  int _jcsAnimationDurationInMilliSecs = 1000;
  int _pauseAfterJCSAnimationInMilliSecs = 2000;

  AnimationController _controller;
  Animation<double> _jcsMovementAnimation;
  Timer _splashScreenTimer;

  @override
  void initState() {
    super.initState();

    //Only runs in debug mode, to help with quicker development
    assert(() {
      _jcsAnimationDurationInMilliSecs = 10;
      _pauseAfterJCSAnimationInMilliSecs = 10000000;
      return true;
    }());

    _controller = AnimationController(
      duration: Duration(milliseconds: _jcsAnimationDurationInMilliSecs),
      vsync: this,
    );
    _jcsMovementAnimation = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
          ..addListener(() {
            setState(() {});
          });
    _controller.forward();

    _splashScreenTimer = Timer(
        Duration(
            milliseconds: _jcsAnimationDurationInMilliSecs +
                _pauseAfterJCSAnimationInMilliSecs), () {
      return Navigator.pushReplacementNamed(context, HomePage.routeName);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _splashScreenTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: SplashScreenPainter(),
        child: Stack(
          children: <Widget>[
            Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 96),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Tales of JCS",
                        style: Theme.of(context).textTheme.headline.copyWith(
                            color: Colors.white,
                            fontSize: 48,
                            fontFamily: "Roboto"),
                      ),
                      Container(
                        height: 48,
                        margin: EdgeInsets.only(top: 64),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: PrimaryAppTheme
                                      .accentYaleColorSwatch.shade300,
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
                          highlightColor:
                              PrimaryAppTheme.accentYaleColorSwatch.shade500,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          onPressed: () {},
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 36),
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontFamily: "Roboto"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            FutureBuilder(
              future: _getJCSImage(),
              builder:
                  (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
                if (snapshot.hasData) {
                  ui.Image image = snapshot.data;

                  return Align(
                    alignment: Alignment.bottomCenter
                        .add(Alignment(0, _jcsMovementAnimation?.value ?? 0)),
                    child: Container(
                      height: image.height.toDouble(),
                      width: image.width.toDouble(),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage('assets/images/unicorn_jcs.png'),
                              fit: BoxFit.fill),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<ui.Image> _getJCSImage() {
    Completer<ui.Image> completer = new Completer<ui.Image>();
    AssetImage('assets/images/unicorn_jcs.png')
        .resolve(ImageConfiguration())
        .addListener(
            (ImageInfo info, bool _) => completer.complete(info.image));
    return completer.future;
  }
}

class SplashScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;
    Paint paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color = PrimaryAppTheme.primaryYaleColorSwatch.shade700;
    canvas.drawPath(mainBackground, paint);

    Path ovalPath = Path();

    //Start paint from 20% height to the left
    ovalPath.moveTo(0, height * 0.2);

    //Paint a curve from current position to middle of the screen
    ovalPath.quadraticBezierTo(
        width * 0.45, height * 0.25, width * 0.51, height * 0.5);

    //Paint a curve from current position to bottom left of screen at width * 0.1
    ovalPath.quadraticBezierTo(width * 0.58, height * 0.8, width * 0.1, height);

    //Draw remaining line to bottom left side
    ovalPath.lineTo(0, height);

    //Close line to reset it back
    ovalPath.close();

    paint.color = PrimaryAppTheme.primaryYaleColorSwatch.shade600;
    canvas.drawPath(ovalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
