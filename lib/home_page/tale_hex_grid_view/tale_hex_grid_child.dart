import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hexagonal_grid/hexagonal_grid.dart';
import 'package:hexagonal_grid_widget/hex_grid_child.dart';
import 'package:hexagonal_grid_widget/hex_grid_context.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/utils/primary_app_theme.dart';

class TaleHexGridChild extends HexGridChild {
  final Tale tale;
  final GestureTapCallback onTap;

  TaleHexGridChild({@required this.tale, @required this.onTap});

  @override
  Widget toHexWidget(BuildContext context, HexGridContext hexGridContext,
      double size, UIHex hex) {
    return Container(
        padding: EdgeInsets.all((hexGridContext.maxSize - size) / 2),
        child: InkResponse(
          onTap: onTap,
          child: Hero(
            tag: "${tale.reference.documentID}_background",
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: _getColorFromBrightness(
                    Theme.of(context).brightness, hex.orbital),
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

  Color _getColorFromBrightness(Brightness brightness, int index) {
    int numOfColorsFromSwatch = 7;
    int colorsShadeToStartAt = 900;
    int colorShade =
        colorsShadeToStartAt - ((index % numOfColorsFromSwatch) * 100);

    if (brightness == Brightness.light) {
      return PrimaryAppTheme.primaryColorSwatch[colorShade];
    } else {
      return PrimaryAppTheme.accentColorSwatch[colorShade];
    }
  }
}
