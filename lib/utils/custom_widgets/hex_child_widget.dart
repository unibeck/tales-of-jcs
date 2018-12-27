import 'package:flutter/material.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hexgrid.dart';

/// Any widget that extends HexChildWidget should have congruent height and width
/// This will be known simple as size of the HexViewWidget.
abstract class HexChildWidget extends StatefulWidget {

  double get minSize;
  double get minHeight => minSize;
  double get minWidth => minSize;
  double get size;
  double get height => size;
  double get width => size;

  set scaleFactor(double scaleFactor);

  Hex get hex;
  set hex(Hex hex);

  const HexChildWidget({Key key}) : super(key: key);


  void updateSize(Offset origin);


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Hex &&
              runtimeType == other.runtimeType &&
              hex.q == other.q &&
              hex.r == other.r;

  @override
  int get hashCode =>
      hex.q.hashCode ^
      hex.r.hashCode;
}
