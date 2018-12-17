import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

  List<CircleButton> _children;
  double _velocityFactor = 1.0;
  ValueChanged<Offset> _scrollListener;

  double xPos = 0.0;
  double yPos = 0.0;
  double xViewPos = 0.0;
  double yViewPos = 0.0;

  AnimationController _controller;
  Animation<Offset> _flingAnimation;

  bool _enableFling = false;

  BubbleGridViewState(List<CircleButton> children, double velocityFactor,
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

    if (-newXPosition + containerWidth > width) {
      newXPosition = containerWidth - width;
    }

//    if (newYPosition > 0.0 || height < containerHeight) {
//      newYPosition = 0.0;
//    } else
//
    if (-newYPosition + containerHeight > height) {
      newYPosition = containerHeight - height;
    }

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
