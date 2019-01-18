import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hexagonal_grid/hexagonal_grid.dart';
import 'package:hexagonal_grid_widget/hex_grid_child.dart';
import 'package:hexagonal_grid_widget/hex_grid_context.dart';
import 'package:tales_of_jcs/tale/tale.dart';

class TaleHexGridChild extends HexGridChild {
  final Tale tale;
  final GestureTapCallback onTap;
  final List<Color> orbitalColors = [
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
  Widget toHexWidget(BuildContext context, HexGridContext hexGridContext,
      double size, UIHex hex) {
    return Container(
        padding: EdgeInsets.all((hexGridContext.maxSize - size) / 2),
        child: InkResponse(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: orbitalColors[hex.orbital % orbitalColors.length],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                tale.title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
        ));
  }

  @override
  double getScaledSize(
      HexGridContext hexGridContext, double distanceFromOrigin) {
    double scaledSize = hexGridContext.maxSize -
        (distanceFromOrigin * hexGridContext.scaleFactor);
    return max(scaledSize, hexGridContext.minSize);
  }
}
