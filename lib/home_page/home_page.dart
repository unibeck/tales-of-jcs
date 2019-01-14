import 'package:flutter/material.dart';
import 'package:tales_of_jcs/tale/tale_hex_grid_child.dart';
import 'package:tales_of_jcs/tale/tale_list_widget.dart';
import 'package:tales_of_jcs/tale/tale_service.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_grid_context.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_grid_widget.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final double _minHexWidgetSize = 24;
  final double _maxHexWidgetSize = 128;
  final double _scaleFactor = 0.2;
  final double _densityFactor = 1.75;
  final double _velocityFactor = 0.3;

  final List<Widget> _children = [];
  int _currentIndex = 0;

  HexGridWidget _bubbleGridView;
  TaleService _taleService = TaleService();

  @override
  void initState() {
    super.initState();
    _bubbleGridView = HexGridWidget(
      children: _taleService.tales.map((tale) {
        return TaleHexGridChild(tale: tale, onTap: () {});
      }).toList(),
      hexGridContext: HexGridContext(_minHexWidgetSize, _maxHexWidgetSize,
          _scaleFactor, _densityFactor, _velocityFactor
      )
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
