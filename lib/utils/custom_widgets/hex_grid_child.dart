import 'package:flutter/widgets.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_grid_context.dart';

abstract class HexGridChild {

  Widget toHexWidget(HexGridContext hexGridContext, double size);

  double getScaledSize(HexGridContext hexGridContext, double distanceFromOrigin);

}
