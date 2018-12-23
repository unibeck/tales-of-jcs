import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'package:tales_of_jcs/utils/custom_widgets/vertical_origin_list.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_child_widget.dart';

class HexGridWidget<T extends HexChildWidget> extends StatefulWidget {
  HexGridWidget({@required this.children,
    this.velocityFactor, this.scrollListener});

  final List<T> children;
  final double velocityFactor;
  final ValueChanged<Offset> scrollListener;

  HexGridWidgetState _state;

  @override
  State<StatefulWidget> createState() {
    _state = new HexGridWidgetState(children, velocityFactor, scrollListener);
    return _state;
  }

  // set x and y scroll offset of the overflowed widget
  set offset(Offset offset) {
    _state.offset = offset;
  }

  // x scroll offset of the overflowed widget
  double get x {
    return _state.x;
  }

  // x scroll offset of the overflowed widget
  double get y {
    return _state.y;
  }

  // height of the overflowed widget
  double get height {
    return _state.height;
  }

  // width of the overflowed widget
  double get width {
    return _state.width;
  }

  // height of the container that holds the overflowed widget
  double get containerHeight {
    return _state.containerHeight;
  }

  // width of the container that holds the overflowed widget
  double get containerWidth {
    return _state.containerWidth;
  }
}

class HexGridWidgetState<T extends HexChildWidget> extends State<HexGridWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey _containerKey = new GlobalKey();
  final GlobalKey _positionedKey = new GlobalKey();

  List<T> _children;
  double _velocityFactor = 1.0;
  ValueChanged<Offset> _scrollListener;

  double xPos = 0.0;
  double yPos = 0.0;
  double xViewPos = 0.0;
  double yViewPos = 0.0;

  AnimationController _controller;
  Animation<Offset> _flingAnimation;

  bool _enableFling = false;

  HexGridWidgetState(List<T> children, double velocityFactor,
      ValueChanged<Offset> scrollListener) {
    _children = children;

    if (velocityFactor != null) {
      this._velocityFactor = velocityFactor;
    }

    if (scrollListener != null) {
      _scrollListener = scrollListener;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //Take the center of the widget and center it to the center of the container
      double widgetXContainerWidthCenter = -((containerWidth / 2) - width / 2);
      double widgetXContainerHeightCenter = -((containerHeight / 2) - height / 2);

      xPos = widgetXContainerWidthCenter;
      yPos = widgetXContainerHeightCenter;
      offset = new Offset(widgetXContainerWidthCenter, widgetXContainerHeightCenter);
    });

    super.initState();
    _controller = new AnimationController(vsync: this)
      ..addListener(_handleFlingAnimation);
  }

  set offset(Offset offset) {
    setState(() {
      xViewPos = -offset.dx;
      yViewPos = -offset.dy;
    });
  }

  double get x {
    return -xViewPos;
  }

  double get y {
    return -yViewPos;
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

  void _handleFlingAnimation() {
    if (!_enableFling || _flingAnimation.value.dx.isNaN ||
        _flingAnimation.value.dy.isNaN) {
      return;
    }

    double newXPosition = xPos + _flingAnimation.value.dx;
    double newYPosition = yPos + _flingAnimation.value.dy;

//    if (newXPosition > 0.0 || width < containerWidth) {
//      newXPosition = 0.0;
//    } else

//    if (-newXPosition + containerWidth > width) {
//      newXPosition = containerWidth - width;
//    }

//    if (newYPosition > 0.0 || height < containerHeight) {
//      newYPosition = 0.0;
//    } else

//    if (-newYPosition + containerHeight > height) {
//      newYPosition = containerHeight - height;
//    }

    setState(() {
      xViewPos = newXPosition;
      yViewPos = newYPosition;
    });

    _sendScrollValues();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox referenceBox = context.findRenderObject();
    Offset position = referenceBox.globalToLocal(details.globalPosition);

    double newXPosition = xViewPos + (position.dx - xPos);
    double newYPosition = yViewPos + (position.dy - yPos);


//    if (newXPosition > 0.0 || width < containerWidth) {
//      newXPosition = 0.0;
//    } else

//    if (-newXPosition + containerWidth > width) {
//      newXPosition = containerWidth - width;
//    }

//    if (newYPosition > 0.0 || height < containerHeight) {
//      newYPosition = 0.0;
//    } else
//
//    if (-newYPosition + containerHeight > height) {
//      newYPosition = containerHeight - height;
//    }

    setState(() {
      xViewPos = newXPosition;
      yViewPos = newYPosition;
    });

    xPos = position.dx;
    yPos = position.dy;

    _sendScrollValues();
  }

  void _handlePanDown(DragDownDetails details) {
    _enableFling = false;
    final RenderBox referenceBox = context.findRenderObject();
    Offset position = referenceBox.globalToLocal(details.globalPosition);

    xPos = position.dx;
    yPos = position.dy;
  }

  void _handlePanEnd(DragEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    final double velocity = magnitude / 1000;

    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size).shortestSide;

    xPos = xViewPos;
    yPos = yViewPos;

    _enableFling = true;
    _flingAnimation = new Tween<Offset>(
        begin: new Offset(0.0, 0.0),
        end: direction * distance * _velocityFactor
    ).animate(_controller);
    _controller
      ..value = 0.0
      ..fling(velocity: velocity);
  }

  _sendScrollValues() {
    if (_scrollListener != null) {
      _scrollListener(new Offset(-xViewPos, -yViewPos));
    }
  }

  @override
  Widget build(BuildContext context) {
    //Always start with at least three rows where the middle row is the origin row
    VerticalOriginList verticalOriginList = VerticalOriginList(_children[0]);
    int childrenIndex = 1;

    //Index of which row to add to
    int cycleRowIndex = 0;

    //Alternate where to add the next row
    bool addRowToTop = false;

    while (childrenIndex < _children.length) {
      List<T> currentRowToAppendTo = verticalOriginList.stack[cycleRowIndex ~/ 2];

      if (currentRowToAppendTo != verticalOriginList.originRow) {
        Tuple3<int, int, bool> childrenIndexXcycleRowIndex = addNewRowIfAppropriate(
            childrenIndex, cycleRowIndex, addRowToTop, verticalOriginList);

        childrenIndex = childrenIndexXcycleRowIndex.item1;
        cycleRowIndex = childrenIndexXcycleRowIndex.item2;
        addRowToTop = childrenIndexXcycleRowIndex.item3;
      }

      //If we still have children left, then add a widget to currentRowToAppendTo
      if (childrenIndex < _children.length) {
        if (currentRowToAppendTo.length % 2 == 0) {
          currentRowToAppendTo.insert(0, _children[childrenIndex++]);
        } else {
          currentRowToAppendTo.add(_children[childrenIndex++]);
        }

        cycleRowIndex++;
      }

      //If we still have another child left, then add a widget to currentRowToAppendTo
      if (childrenIndex < _children.length) {
        if (currentRowToAppendTo .length % 2 == 0) {
          currentRowToAppendTo.insert(0, _children[childrenIndex++]);
        } else {
          currentRowToAppendTo.add(_children[childrenIndex++]);
        }

        cycleRowIndex++;
      }

      //Cycle through the rows, multiplied by two since we always want
      // two widgets per row
      if (cycleRowIndex >= verticalOriginList.stack.length * 2) {
        cycleRowIndex = 0;
      }
    }

    return new GestureDetector(
      onPanDown: _handlePanDown,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Container(
//        decoration: BoxDecoration(
//            color: Colors.white,
//            border: Border.all(
//              color: Colors.black,
//              width: 2.0,
//            )
//        ),
        key: _containerKey,
        child: Stack(
          children: <Widget>[
            Positioned(
              key: _positionedKey,
              top: yViewPos,
              left: xViewPos,
              child: Container(
//                decoration: BoxDecoration(
//                    color: Colors.white,
//                    border: Border.all(
//                      color: Colors.black,
//                      width: 2.0,
//                    )
//                ),
                child: Column(
                  children: verticalOriginList.buildRowStack
                ),
              )
            )
          ],
          ),
      )
    );
  }

  Tuple3<int, int, bool> addNewRowIfAppropriate(int childrenIndex, int cycleRowIndex,
      bool addRowToTop, VerticalOriginList verticalOriginList) {
    if (verticalOriginList.stack[cycleRowIndex ~/ 2].length == 2) {
      //Add an extra row with one widget if the row we're currently at has two widgets

      List<T> newRow = []..add(_children[childrenIndex++]);
      addNewRowWithWidgets(newRow, addRowToTop, verticalOriginList);

      addRowToTop = !addRowToTop;
      cycleRowIndex += 2;
    } else if (verticalOriginList.stack[cycleRowIndex ~/ 2].length == 3) {
      //Add an extra row with at most two widgets if the row we're currently at has three widgets

      List<T> newRow = []..add(_children[childrenIndex++]);
      if (childrenIndex < _children.length) {
        newRow.add(_children[childrenIndex++]);
      }
      addNewRowWithWidgets(newRow, addRowToTop, verticalOriginList);

      addRowToTop = !addRowToTop;
      cycleRowIndex += 2;
    }

    return Tuple3<int, int, bool>(childrenIndex, cycleRowIndex, addRowToTop);
  }

  void addNewRowWithWidgets(List<T> newRow, bool addRowToTop, VerticalOriginList verticalOriginList) {
    //Add the extra bubble to a new row
    if (addRowToTop) {
      //Add new row to the top
      verticalOriginList.addRowToAboveChildren(newRow);
    } else {
      //Add new row to the bottom
      verticalOriginList.addRowToBelowChildren(newRow);
    }
  }
}
