import 'package:flutter/material.dart';
import 'package:tales_of_jcs/utils/BubbleGridView.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BubbleGridView _bubbleGridView;
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    _bubbleGridView = new BubbleGridView(
      child: _buildWidgets(),
      velocityFactor: 2.0,
      scrollListener: (offset) {
        print("----------");
        print("new x and y scroll offset: " + offset.dx.toString() + " " + offset.dy.toString());
        print("x and y scroll offset getters: " + _bubbleGridView.x.toString() + " " + _bubbleGridView.y.toString());
        print("height and width of overscrolled widget: " + _bubbleGridView.height.toString() + " " + _bubbleGridView.width.toString());
        print("height and width of the container: " + _bubbleGridView.containerHeight.toString() + " " + _bubbleGridView.containerWidth.toString());
        print("----------");
      },
    );

    //_plugin.offset = new Offset(10.0, 10.0); // use this method to set a new offset where appropriate
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: new Center(
        child: _bubbleGridView
      ),
    );
  }

  Widget _buildWidgets() {
    List<Widget> list = new List();

    for (int i = 0; i < 1; i++) {
      list.add(
        new Positioned(
          top: 10.0,
          left: 130.0,
          child: CircleButton(
            onTap: () {
              final snackBar = SnackBar(content: Text("You tapped bubble $i"));
              Scaffold.of(context).showSnackBar(snackBar);
            },
            title: "Bubble $i",
          ),
        ),
      );
    }

    return new Stack(children: list);
  }
}

class CircleButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final String title;

  const CircleButton({Key key, this.onTap, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = 48;

    return InkResponse(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
//        padding: new EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          shape: BoxShape.circle,
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.body1,
        ),
      ),
    );
  }
}
