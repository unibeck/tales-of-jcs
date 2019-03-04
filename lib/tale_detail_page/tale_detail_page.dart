import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/models/user/user.dart';
import 'package:tales_of_jcs/services/auth/auth_service.dart';
import 'package:tales_of_jcs/services/user/user_service.dart';
import 'package:tales_of_jcs/tale_detail_page/rating_details.dart';
import 'package:tales_of_jcs/tale_detail_page/tag_details.dart';
import 'package:tales_of_jcs/tale_detail_page/tale_rating_dialog.dart';
import 'package:tales_of_jcs/utils/custom_widgets/custom_expansion_tile.dart';
import 'package:tales_of_jcs/utils/custom_widgets/doppelganger_avatar.dart';
import 'package:tales_of_jcs/utils/primary_app_theme.dart';
import 'package:tales_of_jcs/utils/tale_story_utils.dart';

class TaleDetailPage extends StatefulWidget {
  static const String routeName = "/TaleDetailPage";

  TaleDetailPage({Key key, @required this.tale}) : super(key: key);

  Tale tale;

  @override
  _TaleDetailPageState createState() => _TaleDetailPageState();
}

///Purposely leave the tale title and tale story static and not live as that
/// would be jarring as a user to be reading and having text change on you
class _TaleDetailPageState extends State<TaleDetailPage> {
  //View related
  User _publisher;
  bool _loadingPublisher = false;
  User _lastModifiedUser;
  bool _loadingLastModifiedUser = false;

  bool _isEditingTaleStory = false;
  String _updatedTaleStory;

  User _currentUser;

  //Services
  final AuthService _authService = AuthService.instance;
  final UserService _userService = UserService.instance;

  @override
  void initState() {
    super.initState();

    _updatedTaleStory = "";

    _authService.getCurrentUserDocRef().then((DocumentReference userRef) {
      userRef.get().then((DocumentSnapshot userSnapshot) {
        User user = User.fromSnapshot(userSnapshot);
        if (mounted) {
          setState(() {
            _currentUser = user;
          });
        }
      });
    });
  }

  @override
  void dispose() {
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
              RatingDetails(tale: widget.tale),
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                title: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  color: PrimaryAppTheme.primaryColorSwatch(
                          Theme.of(context).brightness)
                      .shade800,
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
                      title: _getTextContent(),
                      children: _storyMetadata(context),
                    ),
                  ),
                ),
              ),
              TagDetails(tale: widget.tale),
            ]),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: _showRatingDialog,
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

  Widget _getTextContent() {
    if (_isEditingTaleStory) {
      return TextFormField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          initialValue: widget.tale.story,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
          onSaved: (String value) {
            _updatedTaleStory = value;
          },
          validator: (String value) {
            return TaleStoryUtils.validateInput(value);
          });
    } else {
      return Text(
        "${widget.tale.story}",
        style:
            Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),
      );
    }
  }

  List<Widget> _storyMetadata(BuildContext context) {
    List<Widget> storyCardContent = [];

    if (!_isEditingTaleStory) {
      storyCardContent.add(Divider(color: Theme.of(context).primaryColor));

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
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: Colors.white)));
      }

      if (widget.tale.dateLastModified != null && _lastModifiedUser != null) {
        DateFormat formatter = DateFormat.yMMMMd("en_US");
        String formattedLastModifiedDate =
            formatter.format(widget.tale.dateLastModified.toDate());

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
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: Colors.white)));
      }
    }

    if (_currentUser != null) {
      if (_publisher?.reference == _currentUser.reference ||
          _currentUser.isAdmin ||
          _userService.isUserJCS(_currentUser)) {
        storyCardContent.add(ButtonTheme.bar(
          child: ButtonBar(
            children: List.unmodifiable(() sync* {
              //Only the publisher, an admin, or JCS should have the ability to
              // edit a story
              if (_publisher?.reference == _currentUser.reference ||
                  _currentUser.isAdmin ||
                  _userService.isUserJCS(_currentUser)) {
                //Display a show and cancel button if the user is editing
                // the tale's story. Otherwise, display the option to edit
                if (_isEditingTaleStory) {
                  yield OutlineButton(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    textColor: Colors.white,
                    child: Text("CANCEL"),
                    onPressed: () {
                      setState(() {
                        _isEditingTaleStory = false;
                      });
                    },
                  );
                  yield OutlineButton(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    textColor: Colors.white,
                    child: Text("SAVE"),
                    onPressed: () {
                      setState(() {
                        //TODO: form validate and save
                        _isEditingTaleStory = false;
                      });
                    },
                  );
                } else {
                  yield OutlineButton(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    textColor: Colors.white,
                    child: Text("EDIT"),
                    onPressed: () {
                      setState(() {
                        _isEditingTaleStory = true;
                      });
                    },
                  );
                }
              }
              if (_currentUser.isAdmin ||
                  _userService.isUserJCS(_currentUser)) {
                //Don't display the APPROVE button during editing as it may
                // confuse the user
                if (!_isEditingTaleStory) {
                  yield OutlineButton(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    textColor: Colors.white,
                    child: Text("APPROVE"),
                    onPressed: () {},
                  );
                }
              }
            }()),
          ),
        ));
      }
    }

    return storyCardContent;
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

  void _showRatingDialog() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return TaleRatingDialogContent(tale: widget.tale);
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
