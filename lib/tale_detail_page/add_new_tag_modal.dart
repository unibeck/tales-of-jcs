import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tales_of_jcs/models/tale/tag.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/services/analytics/firebase_analytics_service.dart';
import 'package:tales_of_jcs/services/tag/tag_service.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';
import 'package:tales_of_jcs/tale_detail_page/tag_modal_manifest.dart';
import 'package:tales_of_jcs/utils/progress_state.dart';

class AddNewTagModal extends StatefulWidget {
  static const String routeName = "/AddNewTagModal";

  AddNewTagModal({Key key, @required this.tale}) : super(key: key);

  Tale tale;

  @override
  _AddNewTagModalState createState() => _AddNewTagModalState();
}

class _AddNewTagModalState extends State<AddNewTagModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> _tagTitles;
  StreamSubscription<DocumentSnapshot> _taleSnapshotSubscription;

  ProgressState _saveTagProgressState = ProgressState.IDLE;
  String _saveTagMessage;
  Timer _showErrorSavingTagTimer;
  Timer _showSuccessSavingTagTimer;

  bool _hasValidationError = false;
  String _newTagStr;

  //Services
  final TagService _tagService = TagService.instance;

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
              if (tags != null) {
                _tagTitles = tags.map((Tag tag) => tag.title).toList();
              }
              widget.tale = updatedTale;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _showErrorSavingTagTimer?.cancel();
    _showSuccessSavingTagTimer?.cancel();
    _taleSnapshotSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double paddingAtTopAndBottomOfCard = 8;
    if (_hasValidationError) {
      paddingAtTopAndBottomOfCard = 16;
    }

    return Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Hero(
          tag: TagModalManifest.getNewChipHeroTag,
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32))),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, paddingAtTopAndBottomOfCard, 8,
                  paddingAtTopAndBottomOfCard),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: _getCardTextContent(),
                  ),
                  _getCardActionContent()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCardTextContent() {
    if (_saveTagProgressState == ProgressState.ERROR) {
      return Text("There was an error saving the tag, please try again later");
    } else if (_saveTagProgressState == ProgressState.SUCCESS) {
      return Text("$_newTagStr was successfully added");
    } else {
      return Form(
        key: _formKey,
        child: TextFormField(
            textCapitalization: TextCapitalization.words,
            maxLengthEnforced: false,
            decoration: InputDecoration(
                fillColor: Colors.white,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                hintText: "ADD NEW TAG"),
            onSaved: (String value) {
              _newTagStr = value.trim();
            },
            validator: (String value) {
              if (value == null || value.isEmpty) {
                setState(() {
                  _hasValidationError = true;
                });
                return "Anything is better than nothing";
              }

              value = value.trim();

              if (value.split(" ").length != 1) {
                setState(() {
                  _hasValidationError = true;
                });
                return "Tags can only be one word";
              }

              if (_tagTitles != null && _tagTitles.contains(value)) {
                setState(() {
                  _hasValidationError = true;
                });
                return "The story already contains this tag";
              }

              setState(() {
                _hasValidationError = false;
              });
            }),
      );
    }
  }

  Widget _getCardActionContent() {
    if (_saveTagProgressState == ProgressState.LOADING) {
      return CircularProgressIndicator();
    } else if (_saveTagProgressState == ProgressState.ERROR) {
      return Icon(Icons.error, color: Colors.red, size: 48);
    } else if (_saveTagProgressState == ProgressState.SUCCESS) {
      return Icon(Icons.check_circle, color: Colors.green, size: 48);
    } else {
      return FloatingActionButton(
        heroTag: TagModalManifest.getNewChipAddIconHeroTag(),
        elevation: 3,
        backgroundColor: Colors.green,
        mini: true,
        onPressed: _onFormSubmit,
        child: Icon(Icons.add),
      );
    }
  }

  void _onFormSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      Future<Map<String, dynamic>> updateTaleFuture =
          _tagService.addTagToTaleTX(widget.tale.reference, _newTagStr);

      setState(() {
        _saveTagProgressState = ProgressState.LOADING;
      });

      updateTaleFuture.then((Map<String, dynamic> result) {
        setState(() {
          _saveTagProgressState = ProgressState.SUCCESS;
          _saveTagMessage = result["message"];
        });

        _showSuccessSavingTagTimer?.cancel();
        _showSuccessSavingTagTimer =
            Timer.periodic(Duration(seconds: 3), (Timer timer) async {
          Navigator.of(context).pop();
        });
      }).catchError((Error error) {
        FirebaseAnalyticsService.analytics
            .logEvent(name: "failed_to_add_tag_to_existing_tale", parameters: {
          "taleReference": widget.tale.reference.toString(),
          "tagAttemptingToAdd": _newTagStr,
          "error": error.toString()
        });
        print("Error: $error");

        setState(() {
          _saveTagProgressState = ProgressState.ERROR;
        });

        _showErrorSavingTagTimer?.cancel();
        _showErrorSavingTagTimer =
            Timer.periodic(Duration(seconds: 3), (Timer timer) async {
          setState(() {
            _saveTagProgressState = ProgressState.IDLE;
          });
        });
      });
    }
  }
}
