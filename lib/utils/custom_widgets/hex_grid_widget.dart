import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tales_of_jcs/utils/custom_widgets/bubble_loader.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hexgrid.dart';
import 'package:tuple/tuple.dart';
import 'package:after_layout/after_layout.dart';

import 'package:tales_of_jcs/utils/custom_widgets/hex_child_widget.dart';

class HexGridWidget<T extends HexChildWidget> extends StatefulWidget {
  HexGridWidget({@required this.children,
    this.velocityFactor, this.scrollListener});

  final List<T> children;
  final double velocityFactor;
  final ValueChanged<Offset> scrollListener;

  _HexGridWidgetState _state;

  @override
  State<StatefulWidget> createState() {
    _state = _HexGridWidgetState(children, velocityFactor, scrollListener);
    return _state;
  }

  // set x and y scroll offset of the overflowed widget
  set offset(Offset offset) {
    _state.offset = offset;
  }
}

class _HexGridWidgetState<T extends HexChildWidget> extends State<HexGridWidget>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<HexGridWidget> {
  final GlobalKey _containerKey = GlobalKey();
  final GlobalKey _positionedKey = GlobalKey();

  List<T> _children;
  double _hexChildWidgetSize = 0;
  double _velocityFactor = 1.0;

  double xPos = 0.0;
  double yPos = 0.0;
  double xViewPos = 0.0;
  double yViewPos = 0.0;
  Point origin = Point(0.0, 0.0);

  bool _isAfterFirstLayout = false;
  AnimationController _controller;
  ValueChanged<Offset> _scrollListener;
  Animation<Offset> _flingAnimation;
  bool _enableFling = false;

  _HexGridWidgetState(List<T> children, double velocityFactor,
      ValueChanged<Offset> scrollListener) {
    _children = children;
    _hexChildWidgetSize = _children[0].size;

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
        (containerWidth / 2) - (_hexChildWidgetSize / 2),
        (containerHeight / 2) - (_hexChildWidgetSize / 2));

    //Center the hex grid to origin. See comment above about adjusting for
    // vertical center
    offset = Offset(
        origin.x,
        origin.y);
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

  Tuple2<double, double> containPositionWithinContainer(double newXPosition, double newYPosition) {
    //Localize these aggregated values to prevent redundant queries and wasted CPU cycles
    double containerWidth = this.containerWidth;
    double containerHeight = this.containerHeight;
    double width = this.width;
    double height = this.height;

    //Don't allow the left of the hex grid widget to exceed more than half way
    // right of the container height
    if (newXPosition > containerWidth / 2) {
      newXPosition = containerWidth / 2;
    }

    //Don't allow the right of the hex grid widget to exceed more than half way
    // left of the container height
    if (newXPosition < (containerWidth / 2) - width) {
      newXPosition = (containerWidth / 2) - width;
    }

    //Don't allow the top of the hex grid widget to exceed more than half way
    // down the container height
    if (newYPosition > containerHeight / 2) {
      newYPosition = containerHeight / 2;
    }

    //Don't allow the bottom of the hex grid widget to exceed more than half way
    // up the container height
    if (newYPosition < (containerHeight / 2) - height) {
      newYPosition = (containerHeight / 2) - height;
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
//    if (!_isAfterFirstLayout) {
//      childToShow = BubbleLoader();
//    } else {
      childToShow = Stack(
        key: _positionedKey,
        children: buildHexLayout(
            Layout.getOrientFlatSizeFromSymmetricalSize(
              //TODO: Abstract 2.5 to customizable parameter, denseFactor.
              // Controls how close the widgets set next to each other. Note if
              // denseFactor is greater than three then they will overlap
                _hexChildWidgetSize / 3.25
            ),
            xViewPos, yViewPos
        )
      );
//    }

    return GestureDetector(
        onPanDown: _handlePanDown,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
//            border: Border.all(width: 2)
          ),
          key: _containerKey,
          child: childToShow
        ),
    );
  }

  List<Positioned> buildHexLayout(Point hexSize, double layoutOriginX, double layoutOriginY) {
    Hex originHex = Hex(0, 0);
    _children[0].hex = originHex;
    Layout hexLayout = Layout.orientFlat(hexSize, Point(layoutOriginY, layoutOriginX));

    //Contains a set of unique widgets with preserved iteration order
    LinkedHashSet<Positioned> hexSet = LinkedHashSet();
    hexSet.add(createPositionWidgetForHex(_children[0], hexLayout));

    //Contains a queue Hex to determine the children of next
    Queue<Hex> parentHexQueue = Queue();
    parentHexQueue.add(originHex);

    //Start at on since we already seeded the collections
    for (int i = 1; i < _children.length; i++) {
      Hex parentHex = parentHexQueue.removeFirst();

      for (int direction = 0; direction < Hex.directions.length; direction++) {
        if (i >= _children.length) {
          break;
        }

        Hex neighborHex = parentHex.neighbor(direction);
        _children[i].hex = neighborHex;
        Positioned positionedHexWidget = createPositionWidgetForHex(
            _children[i], hexLayout);

        if (!hexSet.contains(positionedHexWidget)) {
          i++;
          hexSet.add(positionedHexWidget);
          parentHexQueue.add(neighborHex);
        }
      }
    }

    return hexSet.toList();
  }

  Positioned createPositionWidgetForHex(T hexWidget, Layout hexLayout) {
    final Point hexToPixel = hexWidget.hex.toPixel(hexLayout);
    final Point reflectedOrigin = Point(origin.y, origin.x);
    final double distance = hexToPixel.distanceTo(reflectedOrigin);

    return Positioned(
        top: hexToPixel.x,
        left: hexToPixel.y,
//        width: size,
//        height: size,
        child: hexWidget..updateSize(distance)
    );
  }
}
