import 'package:flutter/material.dart';
import 'package:tales_of_jcs/utils/custom_widgets/BubbleGridView.dart';
import 'package:tales_of_jcs/utils/custom_widgets/CircleButton.dart';

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
      children: _buildWidgets(),
      velocityFactor: 0.16,
      scrollListener: (offset) {
        print("----------");
        print("new x and y scroll offset: " + offset.dx.toString() + " " + offset.dy.toString());
        print("x and y scroll offset getters: " + _bubbleGridView.x.toString() + " " + _bubbleGridView.y.toString());
        print("height and width of overscrolled widget: " + _bubbleGridView.height.toString() + " " + _bubbleGridView.width.toString());
        print("height and width of the container: " + _bubbleGridView.containerHeight.toString() + " " + _bubbleGridView.containerWidth.toString());
        print("----------");
      },
    );

//    _bubbleGridView.offset = new Offset(10.0, 10.0);
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

  List<CircleButton> _buildWidgets() {
    List<CircleButton> list = new List();

    for (int i = 0; i < 8; i++) {
      list.add(
        CircleButton(
          onTap: () {
            final snackBar = SnackBar(content: Text("You tapped bubble $i"));
            Scaffold.of(context).showSnackBar(snackBar);
          },
          title: "Bubble $i",
        ),
      );
    }

    return list;
  }
}
