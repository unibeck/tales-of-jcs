import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:tales_of_jcs/models/tale/tag.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/models/user/user.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';
import 'package:tales_of_jcs/tale_detail_page/add_new_tag_modal.dart';
import 'package:tales_of_jcs/tale_detail_page/tag_modal_manifest.dart';
import 'package:tales_of_jcs/tale_detail_page/tale_rating_dialog.dart';
import 'package:tales_of_jcs/utils/custom_widgets/custom_expansion_tile.dart';
import 'package:tales_of_jcs/utils/custom_widgets/doppelganger_avatar.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hero_modal_route.dart';
import 'package:tales_of_jcs/utils/primary_app_theme.dart';

class TaleDetailPage extends StatefulWidget {
  static const String routeName = "/TaleDetailPage";

  TaleDetailPage({Key key, @required this.tale}) : super(key: key);

  Tale tale;

  @override
  _TaleDetailPageState createState() => _TaleDetailPageState();
}

class _TaleDetailPageState extends State<TaleDetailPage> {
  //View related
  StreamSubscription<DocumentSnapshot> _taleSnapshotSubscription;
  List<Tag> _tags;

  double _averageRating;
  int _ratingCount;
  int _userSelectedRating;

  User _publisher;
  bool _loadingPublisher = false;
  User _lastModifiedUser;
  bool _loadingLastModifiedUser = false;

  bool _showAddNewTagWidget = true;
  Animation<double> _newChipAnimation;

  //Services
  final TaleService _taleService = TaleService.instance;

  @override
  void initState() {
    super.initState();

    _taleSnapshotSubscription =
        widget.tale.reference.snapshots().listen((DocumentSnapshot snapshot) {
      Tale updatedTale = Tale.fromSnapshot(snapshot);

      if (updatedTale.tags != null) {
        Future.wait(updatedTale.tags.map((DocumentReference reference) async {
          DocumentSnapshot snapshot = await reference.get();
          return Tag.fromSnapshot(snapshot);
        })).then((List<Tag> tags) {
          if (mounted) {
            setState(() {
              _publisher = null;
              _lastModifiedUser = null;
              _tags = tags;

              widget.tale = updatedTale;
            });
          }
        });
      }
    });

    //Init models
    _setRatingAverageAndCount();

    if (widget.tale.tags != null) {
      Future.wait(widget.tale.tags.map((DocumentReference reference) async {
        DocumentSnapshot snapshot = await reference.get();
        return Tag.fromSnapshot(snapshot);
      })).then((List<Tag> tags) {
        setState(() {
          _tags = tags;
        });
      });
    }
  }

  @override
  void dispose() {
    _newChipAnimation?.removeStatusListener(_newChipAnimationListener);
    _taleSnapshotSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  margin: EdgeInsets.zero,
                  color: PrimaryAppTheme.primaryYaleColorSwatch.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CustomExpansionTile(
                      onExpansionChanged: (bool isOpening) {
                        if (isOpening) {
                          _setPublisher();
                          _setLastModifiedUser();
                        }
                      },
                      iconColor: Colors.white,
                      title: Text(
                        "${widget.tale.story}",
                        style: Theme.of(context)
                            .textTheme
                            .subhead
                            .copyWith(color: Colors.white),
                      ),
                      children: _storyMetadata(context),
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
                  children: _buildTagChips(context),
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
                        _showRatingDialog();
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

  List<Widget> _storyMetadata(BuildContext context) {
    List<Widget> storyCardContent = [
      Divider(color: Theme.of(context).primaryColor)
    ];

    if (_publisher != null) {
      storyCardContent.add(ListTile(
          contentPadding: EdgeInsets.zero,
          leading: DoppelgangerAvatar.buildAvatar(context, _publisher,
              accountCircleSize: 40),
          title: Text("Original story published by ${_publisher.name}",
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: Colors.white))));
    } else if (_loadingPublisher) {
      storyCardContent.add(Text("Loading original publisher",
          style:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.white)));
    }

    if (widget.tale.dateLastModified != null && _lastModifiedUser != null) {
      DateFormat formatter = DateFormat.yMMMMd("en_US");
      String formattedLastModifiedDate =
          formatter.format(widget.tale.dateLastModified);

      storyCardContent.add(ListTile(
          contentPadding: EdgeInsets.zero,
          leading: DoppelgangerAvatar.buildAvatar(context, _lastModifiedUser,
              accountCircleSize: 40),
          title: Text(
              "Last modified by ${_lastModifiedUser.name} on $formattedLastModifiedDate",
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: Colors.white))));
    } else if (_loadingLastModifiedUser) {
      storyCardContent.add(Text("Loading last editor",
          style:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.white)));
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
    if (_publisher != null) {
      return;
    }

    if (widget.tale.publisher == null) {
      setState(() {
        _loadingPublisher = false;
      });
      return;
    } else {
      setState(() {
        _loadingPublisher = true;
      });
    }

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

  void _setLastModifiedUser() {
    if (_lastModifiedUser != null) {
      return;
    }

    if (widget.tale.lastModifiedUser == null) {
      setState(() {
        _loadingLastModifiedUser = false;
      });
      return;
    } else {
      setState(() {
        _loadingLastModifiedUser = true;
      });
    }

    widget.tale.lastModifiedUser.get().then((DocumentSnapshot snapshot) {
      setState(() {
        _lastModifiedUser = User.fromSnapshot(snapshot);
        _loadingLastModifiedUser = false;
      });
    }).catchError((err) {
      print(err);
      setState(() {
        _loadingLastModifiedUser = false;
      });
    });
  }

  List<Widget> _buildTagChips(BuildContext context) {
    List<Widget> tagChips = List<Widget>();

    //Add all tags associated with the Tale
    if (_tags != null) {
      tagChips = _tags.map((Tag tag) {
        return Hero(
          tag: TagModalManifest.getChipHeroTagFromTaleTag(tag.title),
          child: Chip(
            backgroundColor: PrimaryAppTheme.primaryYaleColorSwatch.shade800,
//            avatar: CircleAvatar(child: Text("${tag.likedByUsers.length}00")),
            avatar: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text("${tag.likedByUsers.length}00"),
                )),
            label: Text(tag.title,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.white)),
          ),
        );
      }).toList();
    }

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
            return _addNewTagWidget(toHeroContext, false, false);
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
              child: _addNewTagWidget(context, true, false),
            ),
            visible: _showAddNewTagWidget,
            child: _addNewTagWidget(context, true, false))));

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

  Widget _addNewTagWidget(
      BuildContext context, bool withAddTag, bool withAddTagAsHero) {
    return Card(
      color: Theme.of(context).primaryColorLight,
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

  void _showRatingDialog() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: TaleRatingDialogContent(
            onRatingChange: (double v) {
              //toInt simply truncates the decimal value
              setState(() {
                _userSelectedRating = v.toInt();
              });
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
                return;
              },
            ),
            FlatButton(
              child: Text("Save"),
              onPressed: () {
                print(
                    "The value of _userSelectedRating is [$_userSelectedRating]");
                Navigator.of(context).pop();
                return;
              },
            ),
          ],
        );
      },
    );
  }

//  List<Widget> _buildRatingStarButtons() {
//    int starsRemaining = _maxStarRating - _userSelectedRating;
//    List<Widget> ratingStarButtons = [];
//
//    for (int i = 1; i < _userSelectedRating; i++) {
//      ratingStarButtons.add(IconButton(
//        iconSize: 32,
//        onPressed: () {
//          setState(() {
//            _userSelectedRating = i;
//          });
//        },
//        icon: Icon(
//          Icons.star,
//          color: Colors.amber,
//        ),
//      ));
//    }
//
//    for (int i = 0; i <= starsRemaining; i++) {
//      ratingStarButtons.add(IconButton(
//        iconSize: 32,
//        onPressed: () {
//          setState(() {
//            _userSelectedRating = i + _userSelectedRating;
//          });
//        },
//        icon: Icon(
//          Icons.star_border,
//          color: Colors.amber,
//        ),
//      ));
//    }
//
//    return ratingStarButtons;
//  }

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
