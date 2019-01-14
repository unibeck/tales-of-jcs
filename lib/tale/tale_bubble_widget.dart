import 'package:flutter/material.dart';
import 'package:tales_of_jcs/tale/tale.dart';

class TaleBubbleWidget extends StatelessWidget {

  final GestureTapCallback onTap;
  final Tale tale;
  final double size;
  final double maxSize;
  final Color color;

  TaleBubbleWidget({
    @required this.onTap, @required this.tale,
    @required this.size, @required this.maxSize, @required this.color});

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
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                tale.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
              ),
            ),
          ),
        )
    );
  }
}
