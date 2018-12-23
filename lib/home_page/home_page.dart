import 'package:flutter/material.dart';
import 'package:tales_of_jcs/tale/tale_bubble_widget.dart';
import 'package:tales_of_jcs/tale/tale_list_widget.dart';
import 'package:tales_of_jcs/tale/tale_service.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_grid_widget.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_child_widget.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _children = [];
  int _currentIndex = 0;

  HexGridWidget _bubbleGridView;
  TaleService _taleService = TaleService();

  @override
  void initState() {
    super.initState();
    _bubbleGridView = HexGridWidget(
      children: _taleService.tales.map((tale) {
        return TaleBubbleWidget.fromTale(tale);
      }).toList(),
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
    _children.add(ListView.builder(
        itemCount: _taleService.tales.length,
        itemBuilder: (context, index) {
          return TaleListWidget.fromTale(_taleService.tales[index]);
        }
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
}
