import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tales_of_jcs/utils/custom_widgets/CircleButton.dart';

class BubbleGridView extends StatefulWidget {
  BubbleGridView({@required this.children,
    this.velocityFactor, this.scrollListener});

  final List<CircleButton> children;
  final double velocityFactor;
  final ValueChanged<Offset> scrollListener;

  BubbleGridViewState _state;

  @override
  State<StatefulWidget> createState() {
    _state = new BubbleGridViewState(children, velocityFactor, scrollListener);
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

class BubbleGridViewState extends State<BubbleGridView>
    with SingleTickerProviderStateMixin {
  final GlobalKey _containerKey = new GlobalKey();
  final GlobalKey _positionedKey = new GlobalKey();

  List<BubbleButton> _children;
  double _velocityFactor = 1.0;
  ValueChanged<Offset> _scrollListener;

  double xPos = 0.0;
  double yPos = 0.0;
  double xViewPos = 0.0;
  double yViewPos = 0.0;

//  double x = 0.0;
//  double y = 0.0;
  double centerX = 0.0;
  double centerY = 0.0;
  double offsetX = 0.0;
  double offsetY = 0.0;

  AnimationController _controller;
  Animation<Offset> _flingAnimation;

  bool _enableFling = false;

  BubbleGridViewState(List<CircleButton> children, double velocityFactor,
      ValueChanged<Offset> scrollListener) {
    _children = wrapCircles(children);
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
      centerX = containerWidth / 2;
      centerY = containerHeight / 2;
    });

    super.initState();
    _controller = new AnimationController(vsync: this)
      ..addListener(_handleFlingAnimation);
  }
  
  List<BubbleButton> wrapCircles(List<CircleButton> list) {
    int RADIUS = 50;
    int PADDING = 55;
    int PADDINGY = 45;
    int x = 0;
    int y = 0;
    List<BubbleButton> bubbleButtonList;
    
    for (int i = 0; i < 10; i += 1) {
      for (int j = 0; j < 10; j += 1) {
        bubbleButtonList.add(BubbleButton(
            x, y,
            onTap: () {
              final snackBar = SnackBar(content: Text("You tapped bubble $i"));
              Scaffold.of(context).showSnackBar(snackBar);
            },
            title: "Bubble $i"
        ));

        x += RADIUS + PADDING;
      }

      if (i % 2 == 0) {
        x = PADDING;
      } else {
        x = 0;
      }

      y += RADIUS + PADDINGY;
    }

    return bubbleButtonList;
  }

  void draw() {
    var scale,
        closest;

//    offsetX = mouseX - centerX;
//    offsetY = mouseY - centerY;
//    ctx.translate(offsetX, offsetY);

    closest = getClosest();

    for (int i = 0; i < _children.length; i++) {
      scale = getDistance(_children[i]);
    }
  }

  CircleButton getClosest() {
    var close,
        dx,
        dy,
        dist,
        closest;

    for (int i = 0; i < _children.length; i++) {
      dx = _children[i].x + offsetX - centerX;
      dy = _children[i].y + offsetY - centerY;

      dist = sqrt(dx * dx + dy * dy);

      if (!close) {
        close = dist;
        closest = i;
      } else if (dist < close) {
        close = dist;
        closest = i;
      }
    }

    return closest;
  }

  double getDistance(BubbleButton bubble) {
    var dx,
        dy,
        dist;

    dx = bubble.x + offsetX - centerX;
    dy = bubble.y + offsetY - centerY;

    dist = sqrt(dx * dx + dy * dy);
    double scale = 1 - (dist / 400);
    scale = scale > 0 ? scale : 0;

    return scale;
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

  //canvas.height
  double get containerHeight {
    RenderBox containerBox = _containerKey.currentContext.findRenderObject();
    return containerBox.size.height;
  }

  //canvas.width
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

    if (-newXPosition + containerWidth > width) {
      newXPosition = containerWidth - width;
    }

//    if (newYPosition > 0.0 || height < containerHeight) {
//      newYPosition = 0.0;
//    } else

    if (-newYPosition + containerHeight > height) {
      newYPosition = containerHeight - height;
    }

    setState(() {
      xViewPos = newXPosition;
      yViewPos = newYPosition;
    });

//    _sendScrollValues();
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

//    _sendScrollValues();
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
    return new GestureDetector(
      onPanDown: _handlePanDown,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: new Container(
          key: _containerKey,
          child: new Stack(
            overflow: Overflow.visible,
            children: _children.map((widget) {
              return new Positioned(
                //TODO: Need a positionKey for all (or only the center widget?) widgets. For now this only works with one widget
                key: _positionedKey,
                top: yViewPos,
                left: xViewPos,
                child: widget,
              );
            }).toList(),
          )
      ),
    );
  }
}

class BubbleButton extends CircleButton {
  final GestureTapCallback onTap;
  final String title;
  double _x;
  double _y;

  BubbleButton(x, y, {Key key, @required this.onTap, @required this.title}) : super(key: key, onTap: onTap, title: title);

  double get x => _x;

  set x(double value) {
    _x = value;
  }

  double get y => _y;

  set y(double value) {
    _y = value;
  }
}
