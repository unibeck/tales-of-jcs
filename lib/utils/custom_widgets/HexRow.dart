import 'package:flutter/material.dart';

class HexRow {
  static const double defaultSize = 128;

  final int indexFromOrigin;
  List<Widget> children;

  HexRow({@required this.indexFromOrigin, @required this.children});

}
