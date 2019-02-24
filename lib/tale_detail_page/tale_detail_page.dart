import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/models/user/user.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';
import 'package:tales_of_jcs/tale_detail_page/add_new_tag_modal.dart';
import 'package:tales_of_jcs/tale_detail_page/tag_modal_manifest.dart';
import 'package:tales_of_jcs/utils/custom_widgets/custom_expansion_tile.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hero_modal_route.dart';
import 'package:tales_of_jcs/utils/primary_app_theme.dart';

class TaleDetailPage extends StatefulWidget {
  static const String routeName = "/TaleDetailPage";

  TaleDetailPage({Key key, @required this.tale}) : super(key: key);

  final Tale tale;

  @override
  _TaleDetailPageState createState() => _TaleDetailPageState();
}

class _TaleDetailPageState extends State<TaleDetailPage> {
  //View related
  double _averageRating;
  int _ratingCount;
  User _publisher;
  bool _loadingPublisher = true;
  User _lastModifiedUser;
  bool _showAddNewTagWidget = true;
  Animation<double> _newChipAnimation;

  //Services
  final TaleService _taleService = TaleService.instance;

  @override
  void initState() {
    super.initState();

    //Init models
    _setRatingAverageAndCount();

    //TODO: Make this lazy initialized
    _setPublisher();
    _setLastModifiedUser();
  }

  @override
  void dispose() {
    _newChipAnimation?.removeStatusListener(_newChipAnimationListener);
    super.dispose();
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
                //TODO: this causes a small overflow during animating into this
                // widget. "A RenderFlex overflowed by 0.787 pixels on the right"
                // This should be fine as it's not noticeable so early into the
                // animation and is small
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
                  elevation: 0,
                  margin: EdgeInsets.all(0),
//                  color: Theme.of(context).canvasColor,
                  color: PrimaryAppTheme.primaryYaleColorSwatch.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CustomExpansionTile(
                      iconColor: Colors.white,
                      title: Text(
//                        "hey",
//                          textAlign: TextAlign.left,
                        "${widget.tale.story}",
                        style: Theme.of(context)
                            .textTheme
                            .subhead
                            .copyWith(color: Colors.white),
//                        style: TextStyle(color: Colors.white),
                      ),
                      children: _additionalStoryContent(),
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
                      onPressed: () {
//                        _taleService.updateAllTales();
                      },
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

  List<Widget> _additionalStoryContent() {
    List<Widget> storyCardContent = [];

    if (_publisher != null) {
      storyCardContent.add(ListTile(
//          leading: ,
          title: Text("Original story published by ${_publisher.name}")));
    } else if (_loadingPublisher) {
      storyCardContent.add(Text("Loading original publisher"));
    }

    if (widget.tale.dateLastModified != null && _lastModifiedUser != null) {
      DateFormat formatter = DateFormat.yMMMMd("en_US");
      String formattedLastModifiedDate =
          formatter.format(widget.tale.dateLastModified);

      storyCardContent.add(Text(
          "Last modified by ${_lastModifiedUser.name} on $formattedLastModifiedDate"));
    }

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

    //Add all tags associated with the Tale
    tagChips = widget.tale.tags.map((String tag) {
      return Hero(
        tag: TagModalManifest.getChipHeroTagFromTaleTag(tag),
        child: Chip(
          backgroundColor: Theme.of(context).canvasColor,
          avatar: CircleAvatar(child: Icon(Icons.account_circle)),
          label: Text(tag),
        ),
      );
    }).toList();

    //Add a chip for a user to add additional tags
    tagChips.add(Hero(
        flightShuttleBuilder: (
          BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,
        ) {
          _newChipAnimation?.removeStatusListener(_newChipAnimationListener);
          _newChipAnimation = animation;

          //Manage the visibility of the add tag widget to keep the widget
          // hidden when we're animating and using the add tag modal
          _newChipAnimation.addStatusListener(_newChipAnimationListener);

          if (flightDirection == HeroFlightDirection.push) {
            final Hero toHero = toHeroContext.widget;
            return toHero.child;
          } else {
            //Since the toHero.child is hidden we can't use it to animate as we
            // do in the HeroFlightDirection.push block. Instead we reproduce
            // the widget to display a visible version
            return _addNewTagWidget(false, false);
          }
        },
        tag: TagModalManifest.getNewChipHeroTag,
        //We use a visibility widget so we can hide the add tag widget on the
        // detail page when the add tag modal is open
        child: Visibility(
            //We use an invisible widget so the Hero can still correctly animate
            // to the widget's position
            replacement: Opacity(
              opacity: 0,
              child: _addNewTagWidget(true, false),
            ),
            visible: _showAddNewTagWidget,
            child: _addNewTagWidget(true, false))));

    return tagChips;
  }

  void _newChipAnimationListener(AnimationStatus status) {
    if (AnimationStatus.dismissed == status) {
      setState(() {
        _showAddNewTagWidget = true;
      });
    } else if (AnimationStatus.completed == status) {
      setState(() {
        _showAddNewTagWidget = false;
      });
    }
  }

  Widget _addNewTagWidget(bool withAddTag, bool withAddTagAsHero) {
    return Card(
      margin: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32))),
      child: InkWell(
        onTap: _addNewTag,
        child: Padding(
          padding: EdgeInsets.all(2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.unmodifiable(() sync* {
              yield Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Text("ADD NEW TAG"),
              );
              if (withAddTag) {
                if (withAddTagAsHero) {
                  yield Hero(
                      tag: TagModalManifest.getNewChipAddIconHeroTag(),
                      child: Icon(Icons.add_circle_outline));
                } else {
                  yield Icon(Icons.add_circle_outline);
                }
              }
            }()),
          ),
        ),
      ),
    );
  }

  void _addNewTag() {
    Navigator.push(
        context,
        HeroModalRoute(
            settings: RouteSettings(
                name: "${TaleDetailPage.routeName}${AddNewTagModal.routeName}"),
            builder: (BuildContext context) {
              return AddNewTagModal(tale: widget.tale);
            }));
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
        );
}
