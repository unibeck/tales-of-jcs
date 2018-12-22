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
  final List<Widget> _children = [];
  int _currentIndex = 0;

  BubbleGridView _bubbleGridView;

  @override
  void initState() {
    super.initState();
    _bubbleGridView = new BubbleGridView(
      children: _buildWidgets(),
      velocityFactor: 0.3,
      scrollListener: (offset) {
        print("----------");
        print("new x and y scroll offset: " + offset.dx.toString() + " " + offset.dy.toString());
        print("x and y scroll offset getters: " + _bubbleGridView.x.toString() + " " + _bubbleGridView.y.toString());
        print("height and width of overscrolled widget: " + _bubbleGridView.height.toString() + " " + _bubbleGridView.width.toString());
        print("height and width of the container: " + _bubbleGridView.containerHeight.toString() + " " + _bubbleGridView.containerWidth.toString());
        print("----------");
      },
    );

    _children.add(Center(child: _bubbleGridView));
    _children.add(ListView(
      children: <Widget>[
        Text("Story 1"),
        Text("Story 2"),
        Text("Story 3"),
      ],
    ));
    _children.add(Text("Add Screen"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.bubble_chart),
            title: new Text("Bubble View"),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.list),
            title: new Text("List View"),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.add_circle),
            title: new Text("Add Tale"),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<CircleButton> _buildWidgets() {
    List<CircleButton> list = new List();

    for (int i = 0; i < 26; i++) {
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
