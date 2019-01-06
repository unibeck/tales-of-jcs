import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tales_of_jcs/tale/tale.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_child_widget.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hexgrid.dart';

class TaleBubbleWidget extends HexChildWidget {

  final GestureTapCallback onTap;
  final String title;
  final double scaleFactor;

  _TaleBubbleWidgetState _state;
  Hex hex;

  TaleBubbleWidget({Key key, this.scaleFactor = 0.25,
    @required this.onTap, @required this.title}) : super(key: key);

  TaleBubbleWidget.fromTale(Tale tale) : this(
      onTap: () {}, //TODO
      title: tale.title
  );

  @override
  State<StatefulWidget> createState() {
    _state = _TaleBubbleWidgetState(size, scaleFactor, onTap, title);
    return _state;
  }

  @override
  double get size {
    return 128;
  }

  @override
  double get minSize {
    return 24;
  }

  @override
  void updateSize(double distanceFromOrigin) {
    _state?.updateSize(this.size, this.minSize, distanceFromOrigin);
  }

  @override
  set scaleFactor(double scaleFactor) {
    _state.scaleFactor = scaleFactor;
  }
}

class _TaleBubbleWidgetState extends State<TaleBubbleWidget> {

  double _width;
  double _height;
  double _scaleFactor;

  GestureTapCallback onTap;
  String title;

  _TaleBubbleWidgetState(double size, this._scaleFactor, this.onTap, this.title) {
    _width = size;
    _height = size;
  }

  set size(double size) {
    setState(() {
      _width = size;
      _height = size;
    });
  }

  set scaleFactor(double scaleFactor) {
    setState(() {
      scaleFactor = scaleFactor;
    });
  }

  void updateSize(double defaultSize, double minSize, double distanceFromOrigin) {
    double scaledSize = defaultSize - (distanceFromOrigin * _scaleFactor);
    size = max(scaledSize, minSize);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
//        decoration: BoxDecoration(
//            color: Colors.white,
//            border: Border.all(
//              color: Colors.black,
//              width: 2.0,
//            )
//        ),
        padding: EdgeInsets.all((widget.size - _width) / 2),
        child: InkResponse(
          onTap: widget.onTap,
          child: Container(
            width: _width,
            height: _height,
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
