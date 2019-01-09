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
  HexGridWidget({@required this.hexGridContext, @required this.children,
    this.scrollListener});

  final HexGridContext hexGridContext;
  final List<T> children;

  final ValueChanged<Offset> scrollListener;

  _HexGridWidgetState _state;

  @override
  State<StatefulWidget> createState() {
    _state = _HexGridWidgetState(hexGridContext, children, scrollListener);
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

  //TODO: Use a widget instead of boolean. This widget will be used as a loader
  // widget and will be drawn when not null. If it is null then render the hex
  // grid even as it calculates the containers size. Thus the widget won't be
  // required and will always be set to null in [afterFirstLayout] to the hex
  // grid widget can render instead
  bool _isAfterFirstLayout = false;

  HexGridContext _hexGridContext;
  List<T> _children;
  List<Hex> _hexLayout;
  double _hexLayoutRadius = 0.0;

  double xPos = 0.0;
  double yPos = 0.0;
  double xViewPos = 0.0;
  double yViewPos = 0.0;
  Point origin = Point(0.0, 0.0);

  Animation<Offset> _flingAnimation;
  bool _enableFling = false;

  AnimationController _controller;
  ValueChanged<Offset> _scrollListener;

  _HexGridWidgetState(HexGridContext hexGridContext, List<T> children,
      ValueChanged<Offset> scrollListener) {
    _hexGridContext = hexGridContext;
    _children = children;
    _hexLayout = _buildHexLayout();

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

    final double containerWidth = this.containerWidth;
    final double containerHeight = this.containerHeight;

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

  set children(List<T> children) {
    setState(() {
      _children = children;
      _hexLayout = _buildHexLayout();
    });
  }

  double get containerHeight {
    RenderBox containerBox = _containerKey.currentContext.findRenderObject();
    return containerBox.size.height;
  }

  double get containerWidth {
    RenderBox containerBox = _containerKey.currentContext.findRenderObject();
    return containerBox.size.width;
  }

  ///Ensures we will always have hex widgets visible
  Tuple2<double, double> _confineHexGridWithinContainer(double newXPosition, double newYPosition) {
    //Localize these aggregated values to prevent redundant queries and wasted CPU cycles
    final double containerWidth = this.containerWidth;
    final double containerHeight = this.containerHeight;

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

    Tuple2<double, double> newPositions = _confineHexGridWithinContainer(
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
    final Offset position = referenceBox.globalToLocal(details.globalPosition);

    double newXPosition = xViewPos + (position.dx - xPos);
    double newYPosition = yViewPos + (position.dy - yPos);

    Tuple2<double, double> newPositions = _confineHexGridWithinContainer(
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
    final Offset position = referenceBox.globalToLocal(details.globalPosition);

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
        end: direction * distance * _hexGridContext.velocityFactor
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
        children: _buildHexWidgets(
            _hexGridContext.maxSize / _hexGridContext.densityFactor,
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

  List<Positioned> _buildHexWidgets(double hexSize, double layoutOriginX, double layoutOriginY) {
    Layout hexLayout = Layout.orientFlat(
        Point(hexSize, hexSize), Point(layoutOriginY, layoutOriginX)
    );

    List<Positioned> hexWidgetList = [];

    for (int i = 0; i < _hexLayout.length; i++) {
      hexWidgetList.add(_createPositionWidgetForHex(
          _children[i], _hexLayout[i], hexLayout));
    }

    return hexWidgetList;
  }

  List<Hex> _buildHexLayout() {
    Hex originHex = Hex(0, 0);

    List<Hex> hexList = [];
    hexList.add(originHex);

    //Start at one since we already seeded the origin
    int radius = 1;
    int i = 1;
    Hex neighborHex = originHex;

    while (i < _children.length) {
      neighborHex = neighborHex.neighbor(0);

      for (int direction = 0; direction < Hex.directions.length; direction++) {
        for (int r = 0; r < radius; r++) {
          if (i >= _children.length) {
            break;
          }

          hexList.add(neighborHex);
          neighborHex = neighborHex.neighbor((direction + 2) % 6);
          i++;
        }
      }

      radius++;
    }

    _hexLayoutRadius = radius * _hexGridContext.maxSize / _hexGridContext.densityFactor;
    return hexList;
  }

  Positioned _createPositionWidgetForHex(T hexGridChild, Hex hex, Layout hexLayout) {
    final Point hexToPixel = hex.toPixel(hexLayout);
    final Point reflectedOrigin = Point(origin.y, origin.x);
    final double distance = hexToPixel.distanceTo(reflectedOrigin);
    final double size = hexGridChild.getScaledSize(_hexGridContext, distance);

    //TODO: (?) Might not need to show this if the widget is out of view. This
    // could be determined with the x and y, the max width, and the
    // container width and height
    return Positioned(
        top: hexToPixel.x,
        left: hexToPixel.y,
        child: hexGridChild.toHexWidget(_hexGridContext, size)
    );
  }
}
