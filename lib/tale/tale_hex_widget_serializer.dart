import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:tales_of_jcs/tale/tale.dart';
import 'package:tales_of_jcs/tale/tale_bubble_widget.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_widget_serializer.dart';

class TaleHexWidgetSerializer extends HexWidgetSerializer {

  //TODO: Take list of Tales?
  final Tale tale;
  final double minSize;
  final double maxSize;
  final double scaleFactor;

  TaleHexWidgetSerializer(this.tale, this.minSize, this.maxSize, this.scaleFactor);

  @override
  Widget toHexWidget(double size) {
    return TaleBubbleWidget(
      onTap: () {}, //TODO
      title: tale.title,
      size: size,
      maxSize: maxSize
    );
  }

  @override
  double getScaledSize(double distanceFromOrigin) {
    double scaledSize = maxSize - (distanceFromOrigin * scaleFactor);
    return max(scaledSize, minSize);
  }
}
