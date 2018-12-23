import 'package:flutter/material.dart';
import 'package:tales_of_jcs/tale/tale.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_child_widget.dart';

class TaleBubbleWidget extends HexChildWidget {

  GestureTapCallback onTap;
  String title;

  TaleBubbleWidget({Key key, @required this.onTap, @required this.title})
      :super(key: key);


  TaleBubbleWidget.fromTale(Tale tale) {
    onTap = () {}; //TODO
    title = tale.title;
  }

  @override
  double get size {
    return 128;
  }

  @override
  Widget build(BuildContext context) {
    return InkResponse(
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
    );
  }
}
