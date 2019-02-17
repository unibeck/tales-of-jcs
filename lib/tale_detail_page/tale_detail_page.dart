import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/models/user/user.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';
import 'package:tales_of_jcs/tale_detail_page/add_new_tag_dialog.dart';
import 'package:tales_of_jcs/utils/custom_widgets/HeroDialogRoute.dart';

class TaleDetailPage extends StatefulWidget {
  TaleDetailPage({Key key, @required this.tale}) : super(key: key);

  final Tale tale;

  @override
  _TaleDetailPageState createState() => _TaleDetailPageState();
}

class _TaleDetailPageState extends State<TaleDetailPage> {
  final String _tagHeroChip = "tagHeroChip_";

  //View related
  double _averageRating;
  int _ratingCount;
  User _publisher;
  bool _loadingPublisher = true;
  User _lastModifiedUser;
  bool _showAddNewTagWidget = true;

  //Services
  final TaleService _taleService = TaleService.instance;

  @override
  void initState() {
    super.initState();

    //Init models
    _setRatingAverageAndCount();
    _setPublisher();
    _setLastModifiedUser();
  }

  @override
  Widget build(BuildContext context) {
    //Build widgets
    List<Widget> _tagChips = _buildTagChips(context);
    Widget avatar = _buildPublisherAvatar(context);

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
          child: Stack(children: <Widget>[
            ListView(children: <Widget>[
              ListTile(
                title: Hero(
                    child: Text(widget.tale.title,
                        style: Theme.of(context)
                            .textTheme
                            .display2
                            .copyWith(color: Colors.white)),
                    tag: "${widget.tale.reference.documentID}_title"),
              ),
              ListTile(
                title: Row(
                  children: <Widget>[
                    Icon(
                      Icons.star,
                      color: Colors.white,
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.white,
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.white,
                    ),
                    Icon(
                      Icons.star_half,
                      color: Colors.white,
                    ),
                    Icon(
                      Icons.star_border,
                      color: Colors.white,
                    ),
                  ],
                ),
                subtitle: Text(
                    "($_averageRating Stars out of $_ratingCount ratings)",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle
                        .copyWith(color: Colors.white)),
              ),
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                title: Card(
                  margin: EdgeInsets.all(0),
                  color: Theme.of(context).canvasColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildStoryCardContent(),
                    ),
                  ),
                ),
              ),
              ListTile(
                contentPadding:
                    EdgeInsets.only(bottom: 72, left: 16, right: 16),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: _tagChips,
                ),
              ),
            ]),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
//                      color: Colors.white,
                      onPressed: () {},
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

  List<Widget> _buildStoryCardContent() {
    List<Widget> storyCardContent = [
      ListTile(
        title: Text("${widget.tale.story}"),
      ),
    ];

    if (_publisher != null) {
      storyCardContent
          .add(Text("Original story published by ${_publisher.name}"));
    } else if (_loadingPublisher) {
      storyCardContent.add(Text("Loading original publisher"));
    }

    if (widget.tale.dateLastModified != null && _lastModifiedUser != null) {
      storyCardContent.add(Text(
          "Last modified by ${_publisher.name} on ${widget.tale.dateLastModified.toString()}"));
    }

    //TODO: Build this. Only show if there are children to show
    if (false) {
      storyCardContent.add(ButtonTheme.bar(
        // make buttons use the appropriate styles for cards
        child: ButtonBar(
          children: <Widget>[
            //TODO: Only show if currentUser is publisher or admin
            FlatButton(
              child: Text("EDIT"),
              onPressed: () {},
            ),
            //TODO: Only show if currentUser is admin
            FlatButton(
              child: Text("APPROVE"),
              onPressed: () {},
            ),
          ],
        ),
      ));
    }

    return storyCardContent;
  }

  void _setRatingAverageAndCount() async {
    if (widget.tale.ratings == null || widget.tale.ratings.isEmpty) {
      //TODO: Actually implement
//      return;
    }

    setState(() {
      _averageRating = 3.5;
      _ratingCount = 2;
//      _ratingCount = widget.tale.ratings.length;
    });
  }

  void _setPublisher() {
    if (widget.tale.publisher == null) {
      setState(() {
        _loadingPublisher = false;
      });
      return;
    }

    setState(() {
      _loadingPublisher = true;
    });

    widget.tale.publisher.get().then((DocumentSnapshot snapshot) {
      setState(() {
        _publisher = User.fromSnapshot(snapshot);
        _loadingPublisher = false;
      });
    }).catchError((err) {
      print(err);
      setState(() {
        _loadingPublisher = false;
      });
    });
  }

  void _setLastModifiedUser() async {
    if (widget.tale.lastModifiedUser == null) {
      return;
    }

    User lastModifiedUser =
        User.fromSnapshot(await widget.tale.lastModifiedUser.get());
    setState(() {
      _lastModifiedUser = lastModifiedUser;
    });
  }

  List<Widget> _buildTagChips(BuildContext context) {
    List<Widget> tagChips = List<Widget>();

    tagChips = widget.tale.tags.map((String tag) {
      return Hero(
        tag: "$_tagHeroChip$tag",
        child: Chip(
          backgroundColor: Theme.of(context).canvasColor,
          avatar: CircleAvatar(child: Icon(Icons.account_circle)),
          label: Text(tag),
        ),
      );
    }).toList();

//    tagChips.add(Hero(
//        tag: "${_tagHeroChip}new",
//        child: Chip(
//            onDeleted: _addNewTag,
//            deleteIcon: Icon(Icons.add_circle_outline),
//            backgroundColor: Theme.of(context).canvasColor,
//            label: Text("ADD NEW TAG"))));

    tagChips.add(Hero(
        flightShuttleBuilder: (
          BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,
        ) {
          animation.addStatusListener((AnimationStatus status) {
            if (AnimationStatus.dismissed == status) {
              setState(() {
                _showAddNewTagWidget = true;
              });
            } else if (AnimationStatus.completed == status) {
              setState(() {
                _showAddNewTagWidget = false;
              });
            }
          });

          final Hero toHero = toHeroContext.widget;

          if (flightDirection == HeroFlightDirection.push) {
            return toHero.child;
          } else {
            return Center(child: _addNewTagWidget());
//            return _addNewTagWidget();
//            return Center(child: toHero.child);
//            return toHero.child;
          }
        },
        tag: "${_tagHeroChip}new",
        child: Visibility(
            replacement: Opacity(
              opacity: 0,
              child: _addNewTagWidget(),
            ),
            visible: _showAddNewTagWidget,
            child: _addNewTagWidget())));

    return tagChips;
  }

  Widget _addNewTagWidget() {
    return Material(
      borderRadius: BorderRadius.circular(16),
      child: InkResponse(
        onTap: _addNewTag,
        child: Padding(
          padding: EdgeInsets.all(2),
          child: Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Text("ADD NEW TAG"),
                ),
                Icon(Icons.add_circle_outline)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addNewTag() {
    Navigator.push(context, HeroDialogRoute(builder: (BuildContext context) {
      return AddNewTagDialog(tale: widget.tale);
    }));

//    Navigator.push(context, AddNewTagDialogRoute(tale: widget.tale));
//    Navigator.push(context, AddNewTagDialogRoute2(tale: widget.tale));
//    Navigator.push(context, AddNewTagDialogRoute3(tale: widget.tale));
  }

  Widget _buildPublisherAvatar(BuildContext context) {
    Widget avatar;

    if (_publisher == null) {
      avatar = CircleAvatar(child: Icon(Icons.account_circle, size: 40));
    } else if (_publisher.photoUrl == null) {
      avatar = CircleAvatar(child: Text(_publisher.name[0]));
    } else {
      avatar = CircleAvatar(
        backgroundImage: NetworkImage(_publisher.photoUrl),
      );
    }

    return avatar;
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
