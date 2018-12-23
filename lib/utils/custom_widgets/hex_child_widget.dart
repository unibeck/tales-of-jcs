import 'package:flutter/material.dart';

/// Any widget that extends HexChildWidget should have congruent height and width
/// This will be known simple as size of the HexViewWidget.
abstract class HexChildWidget extends StatefulWidget {

  double get size;
  double get minSize;
  set scaleFactor(double scaleFactor);

  void updateSize(Offset origin);

  const HexChildWidget({Key key}) : super(key: key);
}
