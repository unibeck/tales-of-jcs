import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:hexagonal_grid_widget/hex_grid_context.dart';
import 'package:hexagonal_grid_widget/hex_grid_widget.dart';
import 'package:tales_of_jcs/home_page/add_tale_view/add_tale_view.dart';
import 'package:tales_of_jcs/home_page/tale_hex_grid_view/tale_hex_grid_child.dart';
import 'package:tales_of_jcs/home_page/tale_list_view/tale_list_widget.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/services/analytics/firebase_analytics_service.dart';
import 'package:tales_of_jcs/services/auth/auth_service.dart';
import 'package:tales_of_jcs/services/dev/dev_service.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';
import 'package:tales_of_jcs/splash_screen/SplashScreen.dart';
import 'package:tales_of_jcs/tale_detail_page/tale_detail_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  static const String routeName = "/HomePage";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  //Constants
  final double _minHexWidgetSize = 24;
  final double _maxHexWidgetSize = 128;
  final double _scaleFactor = 0.2;
  final double _densityFactor = 1.75;
  final double _velocityFactor = 0.3;

  //View related
  List<MenuChoice> _menuChildren;
  int _currentIndex;

  //Services
  final TaleService _taleService = TaleService.instance;
  final AuthService _authService = AuthService.instance;

  @override
  void initState() {
    super.initState();

    _currentIndex = 0;
    _initMenuChoices();
  }

  void _initMenuChoices() {
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
          onSelected: (context) {
            _authService.signOut().then((_) {
              return Navigator.pushReplacementNamed(
                  context, SplashScreen.routeName);
            });
          }));

    //Only runs in debug mode, to help with quicker development
    assert(() {
      _menuChildren.add(MenuChoice(
          title: "Run dev function",
          icon: Icons.exit_to_app,
          onSelected: (context) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Are you sure you want to run this dev function"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text("Yes"),
                      onPressed: () {
                        DevService.instance.updateAllUsers();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }));
      return true;
    }());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FirebaseAnalyticsService.observer.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    FirebaseAnalyticsService.observer.unsubscribe(this);

    super.dispose();
  }

  @override
  void didPush() {
    _sendCurrentTabToAnalytics();
  }

  @override
  void didPopNext() {
    _sendCurrentTabToAnalytics();
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
      body: _getMainView(context),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => setState(() {
              _currentIndex = index;
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

  Widget _getMainView(BuildContext context) {
    if (_currentIndex == 0) {
      return _getTaleHexGridView();
    } else if (_currentIndex == 1) {
      return _getTaleListView();
    } else if (_currentIndex == 2) {
      return _getAddTaleView();
    } else {
      FirebaseAnalyticsService.analytics.logEvent(
          name: "home_page_main_view_out_of_bounds",
          parameters: {"index": _currentIndex});

      //Should never get here, but lets default to hex view
      return _getTaleHexGridView();
    }
  }

  Widget _getTaleHexGridView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _taleService.talesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.data.documents.length == 0) {
          return Padding(
            padding: const EdgeInsets.all(48),
            child: Center(
              child: Text(
                "No tales have been added yet, go to the Add Tale tab to create the first!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subhead,
              ),
            ),
          );
        } else {
          return HexGridWidget(
              children:
                  snapshot.data.documents.map((DocumentSnapshot snapshot) {
                final Tale tale = Tale.fromSnapshot(snapshot);
                return TaleHexGridChild(
                    tale: tale,
                    onTap: () {
                      //Use unique route to assist in animation
                      Navigator.push(context, TaleDetailPageRoute(tale: tale));
                    });
              }).toList(),
              hexGridContext: HexGridContext(
                  _minHexWidgetSize,
                  _maxHexWidgetSize,
                  _scaleFactor,
                  _densityFactor,
                  _velocityFactor));
        }
      },
    );
  }

  Widget _getTaleListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _taleService.talesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.data.documents.length == 0) {
          return Padding(
            padding: const EdgeInsets.all(48),
            child: Center(
              child: Text(
                "No tales have been added yet, go to the Add Tale tab to create the first!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subhead,
              ),
            ),
          );
        } else {
          return Container(
              color: Theme.of(context).backgroundColor,
              child: ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    final Tale tale =
                        Tale.fromSnapshot(snapshot.data.documents[index]);
                    return TaleListWidget.fromTale(tale);
                  }));
        }
      },
    );
  }

  Widget _getAddTaleView() {
    return AddTaleWidget();
  }

  void _sendCurrentTabToAnalytics() {
    FirebaseAnalyticsService.analytics.setCurrentScreen(
      screenName: "${HomePage.routeName}/tab$_currentIndex",
    );
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
