import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tales_of_jcs/tale/tale.dart';
import 'package:tales_of_jcs/tale/tale_bubble_widget.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_grid_child.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_grid_context.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hexgrid.dart';

class TaleHexGridChild extends HexGridChild {

  final Tale tale;
  final GestureTapCallback onTap;
  final List<Color> radiusColors = [
    Color(0xFF2D365C),
    Color(0xFF083663),
    Color(0xFF07489C),
    Color(0xFF165DC0),
    Color(0xFF0E90E1),
    Color(0xFF89D3FB),
    Color(0xFFAFDBDE)
  ];

  TaleHexGridChild({@required this.tale, @required this.onTap});

  @override
  Widget toHexWidget(HexGridContext hexGridContext, double size, UIHex hex) {
    return TaleBubbleWidget(
      onTap: onTap,
      tale: tale,
      size: size,
      maxSize: hexGridContext.maxSize,
      color: radiusColors[hex.radius % radiusColors.length],
    );
  }

  @override
  double getScaledSize(HexGridContext hexGridContext, double distanceFromOrigin) {
    double scaledSize = hexGridContext.maxSize - (distanceFromOrigin * hexGridContext.scaleFactor);
    return max(scaledSize, hexGridContext.minSize);
  }
}