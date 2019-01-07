class HexGridContext {

  final double minSize;
  final double maxSize;

  //Controls how significantly the hex child widgets shrink as the move further
  // from the origin
  final double scaleFactor;

  //Controls how close the widgets sit next to each other. Note if the
  // densityFactor is greater than three then the hex child widgets will overlap
  final double densityFactor;

  HexGridContext(this.minSize, this.maxSize, this.scaleFactor, this.densityFactor);

}
