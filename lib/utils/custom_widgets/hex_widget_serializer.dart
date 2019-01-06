import 'package:flutter/widgets.dart';

abstract class HexWidgetSerializer {

  double get minSize;
  double get minHeight => minSize;
  double get minWidth => minSize;

  double get maxSize;
  double get maxHeight => maxSize;
  double get maxWidth => maxSize;

  double get scaleFactor;

  Widget toHexWidget(double size);

  double getScaledSize(double distanceFromOrigin);

}
