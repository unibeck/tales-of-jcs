import 'package:flutter/material.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/tale_detail_page/rating_details.dart';
import 'package:tales_of_jcs/tale_detail_page/tag_details.dart';
import 'package:tales_of_jcs/tale_detail_page/tale_rating_dialog.dart';
import 'package:tales_of_jcs/tale_detail_page/tale_story_content.dart';

class TaleDetailPage extends StatelessWidget {
  static const String routeName = "/TaleDetailPage";

  TaleDetailPage({Key key, @required this.tale}) : super(key: key);

  Tale tale;

  @override
  Widget build(BuildContext context) {
    return Hero(
      createRectTween: _createRectTween,
      tag: "${tale.reference.documentID}_background",
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColorDark,
        ),
        body: Container(
          color: Theme.of(context).primaryColorDark,
          child: Stack(children: <Widget>[
            ListView(children: <Widget>[
              ListTile(
                title: Hero(
                    child: Text(tale.title,
                        style: Theme.of(context)
                            .textTheme
                            .display2
                            .copyWith(color: Colors.white)),
                    tag: "${tale.reference.documentID}_title"),
              ),
              RatingDetails(tale: tale),
              TaleStoryContent(tale: tale),
              TagDetails(tale: tale),
            ]),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () => _showRatingDialog(context),
                      child: Text("Rate"),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  static RectTween _createRectTween(Rect begin, Rect end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return TaleRatingDialogContent(tale: tale);
        });
  }
}

class TaleDetailPageRoute<T> extends PageRouteBuilder<T> {
  TaleDetailPageRoute({@required Tale tale})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget child) {
                    return TaleDetailPage(tale: tale);
                  });
            },
            settings: RouteSettings(name: "${TaleDetailPage.routeName}/bubble"),
            maintainState: true);
}
