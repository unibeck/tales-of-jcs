import 'package:flutter/material.dart';

/// Any widget that extends HexChildWidget should have congruent height and width
/// This will be known simple as size of the HexViewWidget.
abstract class HexChildWidget extends StatelessWidget {

  double get size;

  const HexChildWidget({Key key}) : super(key: key);
}
