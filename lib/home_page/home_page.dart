import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:hexagonal_grid_widget/hex_grid_context.dart';
import 'package:hexagonal_grid_widget/hex_grid_widget.dart';
import 'package:tales_of_jcs/home_page/add_tale_view/add_tale_view.dart';

import 'package:tales_of_jcs/home_page/tale_hex_grid_view/tale_hex_grid_child.dart';
import 'package:tales_of_jcs/home_page/tale_list_view/tale_list_widget.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Constants
  final double _minHexWidgetSize = 24;
  final double _maxHexWidgetSize = 128;
  final double _scaleFactor = 0.2;
  final double _densityFactor = 1.75;
  final double _velocityFactor = 0.3;

  //View related
  List<MenuChoice> _menuChildren;
  int _currentIndex;
  Widget _mainViewWidget;

  //Services
  final TaleService _taleService = TaleService.instance;

  @override
  void initState() {
    super.initState();

    _setMainView(0);

    _menuChildren = []
      ..add(MenuChoice(
          title: "Change Theme",
          icon: Icons.invert_colors,
          onSelected: (context) {
            DynamicTheme.of(context).setBrightness(
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark);
          }))
      ..add(MenuChoice(
          title: "Logout",
          icon: Icons.exit_to_app,
          //TODO: Make actually logout call
          onSelected: (context) {
            return Navigator.pushReplacementNamed(context, 'splash');
          }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tales"),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<MenuChoice>(
            onSelected: (MenuChoice choice) => choice.onSelected(context),
            itemBuilder: (BuildContext context) {
              return _menuChildren.map((MenuChoice choice) {
                return PopupMenuItem<MenuChoice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _mainViewWidget,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => setState(() {
              _setMainView(index);
            }),
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.bubble_chart),
            title: Text("Bubble View"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text("List View"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            title: Text("Add Tale"),
          ),
        ],
      ),
    );
  }

  void _setMainView(int index) {
    _currentIndex = index;
    if (_currentIndex == 0) {
      _mainViewWidget = _getTaleHexGridView();
    } else if (_currentIndex == 1) {
      _mainViewWidget = _getTaleListView();
    } else if (_currentIndex == 2) {
      _mainViewWidget = _getAddTaleView();
    } else {
      //TODO: log error
    }
  }

  Widget _getTaleHexGridView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _taleService.talesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        return HexGridWidget(
            children:
                snapshot.data.documents.map((DocumentSnapshot docSnapshot) {
              final Tale tale = Tale.fromSnapshot(docSnapshot);
              return TaleHexGridChild(
                  tale: tale,
                  onTap: () {
                    Navigator.pushNamed(context, 'tale_detail');
                  });
            }).toList(),
            hexGridContext: HexGridContext(_minHexWidgetSize, _maxHexWidgetSize,
                _scaleFactor, _densityFactor, _velocityFactor));
      },
    );
  }

  Widget _getTaleListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _taleService.talesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        return Container(
            color: Theme.of(context).backgroundColor,
            child: ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  final Tale tale =
                      Tale.fromSnapshot(snapshot.data.documents[index]);
                  return TaleListWidget.fromTale(tale);
                }));
      },
    );
  }

  Widget _getAddTaleView() {
    return AddTaleWidget();
  }
}

typedef MenuChoiceSelected = void Function(BuildContext context);

class MenuChoice {
  const MenuChoice(
      {@required this.title, @required this.icon, @required this.onSelected});

  final String title;
  final IconData icon;
  final MenuChoiceSelected onSelected;
}
