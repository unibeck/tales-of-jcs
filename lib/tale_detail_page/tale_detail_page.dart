import 'package:flutter/material.dart';

import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';

class TaleDetailPage extends StatefulWidget {
  TaleDetailPage({Key key, @required this.tale}) : super(key: key);

  final Tale tale;

  @override
  _TaleDetailPageState createState() => _TaleDetailPageState();
}

class _TaleDetailPageState extends State<TaleDetailPage> {
  //View related

  //Services
  final TaleService _taleService = TaleService.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: When we have a markov chain and/or machine learning model AI for
    // JCS stories we can present a score of how JCS the story being entered is

    return Hero(
      createRectTween: _createRectTween,
      tag: "${widget.tale.reference.documentID}_background",
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColorDark,
        ),
        body: Container(
//          constraints: BoxConstraints.expand(),
          color: Theme.of(context).primaryColorDark,
          child: ListView(children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Hero(
                  child: Text(widget.tale.title),
                  tag: "${widget.tale.reference.documentID}_title"),
            ),
          ]),
        ),
      ),
    );
  }

  static RectTween _createRectTween(Rect begin, Rect end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }
}

class TaleDetailPageRoute<T> extends PageRouteBuilder<T> {
  TaleDetailPageRoute({@required Tale tale, RouteSettings settings})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget child) {
                    return TaleDetailPage(tale: tale);
                  });
            },
            settings: settings);
}
