import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:tales_of_jcs/tale/tale.dart';
import 'package:tales_of_jcs/tale/tale_bubble_widget.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_grid_child.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_grid_context.dart';

class TaleHexGridChild extends HexGridChild {

  final Tale tale;
  final GestureTapCallback onTap;

  TaleHexGridChild({@required this.tale, @required this.onTap});

  @override
  Widget toHexWidget(HexGridContext hexGridContext, double size) {
    return TaleBubbleWidget(
        onTap: onTap,
        tale: tale,
        size: size,
        maxSize: hexGridContext.maxSize
    );
  }

  @override
  double getScaledSize(HexGridContext hexGridContext, double distanceFromOrigin) {
    double scaledSize = hexGridContext.maxSize - (distanceFromOrigin * hexGridContext.scaleFactor);
    return max(scaledSize, hexGridContext.minSize);
  }
}