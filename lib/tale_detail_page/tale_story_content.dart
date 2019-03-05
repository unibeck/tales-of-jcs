import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/models/user/user.dart';
import 'package:tales_of_jcs/services/auth/auth_service.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';
import 'package:tales_of_jcs/services/user/user_service.dart';
import 'package:tales_of_jcs/utils/custom_widgets/custom_expansion_tile.dart';
import 'package:tales_of_jcs/utils/custom_widgets/doppelganger_avatar.dart';
import 'package:tales_of_jcs/utils/primary_app_theme.dart';
import 'package:tales_of_jcs/utils/tale_story_utils.dart';

class TaleStoryContent extends StatefulWidget {
  TaleStoryContent({Key key, @required this.tale}) : super(key: key);

  Tale tale;

  @override
  _TaleStoryContentState createState() => _TaleStoryContentState();
}

class _TaleStoryContentState extends State<TaleStoryContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //View related
  User _publisher;
  bool _loadingPublisher = false;
  User _lastModifiedUser;
  bool _loadingLastModifiedUser = false;

  bool _isEditingTaleStory = false;
  bool _isUpdatingTaleStory = false;
  String _updatedTaleStory;

  User _currentUser;

  //Services
  final AuthService _authService = AuthService.instance;
  final UserService _userService = UserService.instance;
  final TaleService _taleService = TaleService.instance;

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
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      title: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: PrimaryAppTheme.primaryColorSwatch(Theme.of(context).brightness)
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
    );
  }

  Widget _getTextContent() {
    if (_isEditingTaleStory) {
      return Form(
          key: _formKey,
          child: TextFormField(
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
              }));
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
                    onPressed: _validateUpdatedTaleStory,
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

  Future<void> _validateUpdatedTaleStory() async {
    if (_formKey.currentState.validate()) {
      //Let users know we started creating the tag and tale
      setState(() {
        _isEditingTaleStory = false;
        _isUpdatingTaleStory = true;
      });

      //Populate all data models from form
      _formKey.currentState.save();

      Future<Map<String, dynamic>> createTaleFuture = _taleService
          .updateTaleStoryTX(widget.tale.reference, _updatedTaleStory);

      createTaleFuture.then((Map<String, dynamic> result) {
        Tale updatedTale = result["updatedTale"];

        //Reset the form's state
        setState(() {
          _isUpdatingTaleStory = false;
          widget.tale = updatedTale;
          _formKey.currentState.reset();
        });

        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text("The tale story has been updated!")));
      }).catchError((error) {
        setState(() {
          _isEditingTaleStory = false;
          _isUpdatingTaleStory = false;
        });

        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Failed to update story, please try again later")));
      });
    }
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
}
