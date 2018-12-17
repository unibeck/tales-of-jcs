import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final String title;

  const CircleButton({Key key, this.onTap, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = 128;

    return InkResponse(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
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
