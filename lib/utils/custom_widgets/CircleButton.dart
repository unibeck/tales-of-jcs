import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  static const double defaultSize = 128;

  final GestureTapCallback onTap;
  final String title;

  const CircleButton({Key key, @required this.onTap, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        width: defaultSize,
        height: defaultSize,
//        padding: new EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
