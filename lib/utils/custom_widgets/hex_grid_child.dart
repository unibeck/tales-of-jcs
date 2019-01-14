import 'package:flutter/widgets.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_grid_context.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hexgrid.dart';

abstract class HexGridChild {

  Widget toHexWidget(HexGridContext hexGridContext, double size, UIHex hex);

  double getScaledSize(HexGridContext hexGridContext, double distanceFromOrigin);

}
