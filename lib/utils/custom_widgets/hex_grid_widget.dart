import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tales_of_jcs/utils/custom_widgets/bubble_loader.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_grid_child.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_grid_context.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hexgrid.dart';
import 'package:tuple/tuple.dart';
import 'package:after_layout/after_layout.dart';

class HexGridWidget<T extends HexGridChild> extends StatefulWidget {
  HexGridWidget({@required this.children, @required this.hexGridContext,
    this.velocityFactor, this.scrollListener});

  final HexGridContext hexGridContext;
  final List<T> children;

  final double velocityFactor;
  final ValueChanged<Offset> scrollListener;

  _HexGridWidgetState _state;

  @override
  State<StatefulWidget> createState() {
    _state = _HexGridWidgetState(hexGridContext, children, velocityFactor, scrollListener);
    return _state;
  }

  //Set the x and y scroll offset
  set offset(Offset offset) {
    _state.offset = offset;
  }
}

// ignore: conflicting_generic_interfaces
class _HexGridWidgetState<T extends HexGridChild> extends State<HexGridWidget>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<HexGridWidget> {
  final GlobalKey _containerKey = GlobalKey();
  final GlobalKey _positionedKey = GlobalKey();
  bool _isAfterFirstLayout = false;

  HexGridContext _hexGridContext;
  List<T> _children;
  double _hexLayoutRadius;

  double xPos = 0.0;
  double yPos = 0.0;
  double xViewPos = 0.0;
  double yViewPos = 0.0;
  Point origin = Point(0.0, 0.0);

  double _velocityFactor = 1.0;
  Animation<Offset> _flingAnimation;
  bool _enableFling = false;

  AnimationController _controller;
  ValueChanged<Offset> _scrollListener;

  _HexGridWidgetState(HexGridContext hexGridContext, List<T> children,
      double velocityFactor, ValueChanged<Offset> scrollListener) {
    _hexGridContext = hexGridContext;
    _children = children;

    if (velocityFactor != null) {
      _velocityFactor = velocityFactor;
    }

    if (scrollListener != null) {
      _scrollListener = scrollListener;
    }
  }

  @override
  void initState() {
    super.initState();

    _isAfterFirstLayout = false;

    _controller = AnimationController(vsync: this)
      ..addListener(_handleFlingAnimation);
  }

  @override
  void dispose() {
    _controller?.dispose();

    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _isAfterFirstLayout = true;

    double containerWidth = this.containerWidth;
    double containerHeight = this.containerHeight;

    //Determine the origin of the container. Since we'll be using origin w.r.t
    // to the bounding boxes of the hex children, which are positioned by
    // top and left values, we'll have to adjust by half of the widget size to
    // get the technical origin.
    origin = Point(
        (containerWidth / 2) - (_hexGridContext.maxSize / 2),
        (containerHeight / 2) - (_hexGridContext.maxSize / 2));

    //Center the hex grid to origin
    offset = Offset(origin.x, origin.y);
  }

  set offset(Offset offset) {
    setState(() {
      xViewPos = offset.dx;
      yViewPos = offset.dy;
    });
  }

  double get height {
    RenderBox renderBox = _positionedKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  double get width {
    RenderBox renderBox = _positionedKey.currentContext.findRenderObject();
    return renderBox.size.width;
  }

  double get containerHeight {
    RenderBox containerBox = _containerKey.currentContext.findRenderObject();
    return containerBox.size.height;
  }

  double get containerWidth {
    RenderBox containerBox = _containerKey.currentContext.findRenderObject();
    return containerBox.size.width;
  }

  ///Ensures we will always have widgets visible
  Tuple2<double, double> containPositionWithinContainer(double newXPosition, double newYPosition) {
    //Localize these aggregated values to prevent redundant queries and wasted CPU cycles
    double containerWidth = this.containerWidth;
    double containerHeight = this.containerHeight;

    //Don't allow the right of the hex grid widget to exceed pass the left half
    // of the container
    if (newXPosition < (containerWidth / 2) - _hexLayoutRadius - (_hexGridContext.maxSize)) {
      newXPosition = (containerWidth / 2) - _hexLayoutRadius - (_hexGridContext.maxSize);
    }

    //Don't allow the left of the hex grid widget to exceed pass the right half
    // of the container
    if (newXPosition > (containerWidth / 2) + _hexLayoutRadius) {
      newXPosition = (containerWidth / 2) + _hexLayoutRadius;
    }

    //Don't allow the bottom of the hex grid widget to exceed pass the top half
    // of the container
    if (newYPosition < (containerHeight / 2) - _hexLayoutRadius - (_hexGridContext.maxSize)) {
      newYPosition = (containerHeight / 2) - _hexLayoutRadius - (_hexGridContext.maxSize);
    }

    //Don't allow the top of the hex grid widget to exceed pass the bottom half
    // of the container
    if (newYPosition > (containerHeight / 2) + _hexLayoutRadius) {
      newYPosition = (containerHeight / 2) + _hexLayoutRadius;
    }

    return Tuple2<double, double>(newXPosition, newYPosition);
  }

  void _handleFlingAnimation() {
    if (!_enableFling || _flingAnimation.value.dx.isNaN ||
        _flingAnimation.value.dy.isNaN) {
      return;
    }

    double newXPosition = xPos + _flingAnimation.value.dx;
    double newYPosition = yPos + _flingAnimation.value.dy;

    Tuple2<double, double> newPositions = containPositionWithinContainer(
        newXPosition, newYPosition);

    newXPosition = newPositions.item1;
    newYPosition = newPositions.item2;

    setState(() {
      xViewPos = newXPosition;
      yViewPos = newYPosition;
    });

    _sendScrollValues();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isAfterFirstLayout) {
      return;
    }

    final RenderBox referenceBox = context.findRenderObject();
    Offset position = referenceBox.globalToLocal(details.globalPosition);

    double newXPosition = xViewPos + (position.dx - xPos);
    double newYPosition = yViewPos + (position.dy - yPos);

    Tuple2<double, double> newPositions = containPositionWithinContainer(
        newXPosition, newYPosition);

    newXPosition = newPositions.item1;
    newYPosition = newPositions.item2;

    setState(() {
      xViewPos = newXPosition;
      yViewPos = newYPosition;
    });

    xPos = position.dx;
    yPos = position.dy;

    _sendScrollValues();
  }

  void _handlePanDown(DragDownDetails details) {
    if (!_isAfterFirstLayout) {
      return;
    }

    _enableFling = false;
    final RenderBox referenceBox = context.findRenderObject();
    Offset position = referenceBox.globalToLocal(details.globalPosition);

    xPos = position.dx;
    yPos = position.dy;
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isAfterFirstLayout) {
      return;
    }

    final double magnitude = details.velocity.pixelsPerSecond.distance;
    final double velocity = magnitude / 1000;

    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size).shortestSide;

    xPos = xViewPos;
    yPos = yViewPos;

    _enableFling = true;
    _flingAnimation = Tween<Offset>(
        begin: Offset(0.0, 0.0),
        end: direction * distance * _velocityFactor
    ).animate(_controller);
    _controller
      ..value = 0.0
      ..fling(velocity: velocity);
  }

  _sendScrollValues() {
    if (_scrollListener != null) {
      _scrollListener(Offset(xViewPos, yViewPos));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget childToShow;
    if (!_isAfterFirstLayout) {
      childToShow = BubbleLoader();
    } else {
      childToShow = Stack(
        key: _positionedKey,
        children: buildHexLayout(
            Layout.getOrientFlatSizeFromSymmetricalSize(
                _hexGridContext.maxSize / _hexGridContext.densityFactor
            ),
            xViewPos, yViewPos
        )
      );
    }

    return GestureDetector(
        onPanDown: _handlePanDown,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          key: _containerKey,
          child: childToShow
        ),
    );
  }

  //TODO: Potentially use https://www.redblobgames.com/grids/hexagons/#rings-spiral as
  // a better algorithm to layout in a spiral manner
  List<Positioned> buildHexLayout(Point hexSize, double layoutOriginX, double layoutOriginY) {
    Hex originHex = Hex(0, 0);
    Hex furthestHex = originHex;
    Layout hexLayout = Layout
        .orientFlat(hexSize, Point(layoutOriginY, layoutOriginX));

    //Contains a set of unique widgets with preserved iteration order
    LinkedHashSet<Positioned> hexSet = LinkedHashSet();
    hexSet.add(createPositionWidgetForHex(
        _children[0], originHex, hexLayout));

    //Contains a queue Hex to determine the children of next suitable Hex
    Queue<Hex> parentHexQueue = Queue();
    parentHexQueue.add(originHex);

    //Start at one since we already seeded the origin
    for (int i = 1; i < _children.length; i++) {
      Hex parentHex = parentHexQueue.removeFirst();

      for (int direction = 0; direction < Hex.directions.length; direction++) {
        if (i >= _children.length) {
          break;
        }

        Hex neighborHex = parentHex.neighbor(direction);
        Positioned positionedHexWidget = createPositionWidgetForHex(
            _children[i], neighborHex, hexLayout);

        if (!hexSet.contains(positionedHexWidget)) {
          i++;
          hexSet.add(positionedHexWidget);
          parentHexQueue.add(neighborHex);

          //The last hex we add will always be the furthest one from the origin
          furthestHex = neighborHex;
        }
      }
    }

    _calculateRadius(furthestHex, hexLayout);

    return hexSet.toList();
  }

  Positioned createPositionWidgetForHex(T hexGridChild, Hex hex, Layout hexLayout) {
    final Point hexToPixel = hex.toPixel(hexLayout);
    final Point reflectedOrigin = Point(origin.y, origin.x);
    final double distance = hexToPixel.distanceTo(reflectedOrigin);
    final double size = hexGridChild.getScaledSize(_hexGridContext, distance);

    return Positioned(
        top: hexToPixel.x,
        left: hexToPixel.y,
        child: hexGridChild.toHexWidget(_hexGridContext, size)
    );
  }

  void _calculateRadius(Hex furthestHex, Layout hexLayout) {
    final Point hexToPixel = furthestHex.toPixel(hexLayout);
    final Point reflectedOrigin = Point(hexLayout.origin.x, hexLayout.origin.y);
    final double distance = hexToPixel.distanceTo(reflectedOrigin);

    //Always allow some play since the furthestHex might be the origin,
    // thus a distance of 0 which wouldn't be any fun
    _hexLayoutRadius = max(distance, _hexGridContext.maxSize / 2);
  }
}
