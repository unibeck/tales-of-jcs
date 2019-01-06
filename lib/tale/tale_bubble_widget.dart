import 'package:flutter/material.dart';

class TaleBubbleWidget extends StatelessWidget {

  final GestureTapCallback onTap;
  final String title;
  final double size;
  final double maxSize;

  TaleBubbleWidget({
    @required this.onTap, @required this.title,
    @required this.size, @required this.maxSize});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all((maxSize - size) / 2),
        child: InkResponse(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
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
        )
    );
  }
}
