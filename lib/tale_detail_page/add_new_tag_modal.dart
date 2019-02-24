import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/services/analytics/firebase_analytics_service.dart';
import 'package:tales_of_jcs/services/tag/tag_service.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';
import 'package:tales_of_jcs/tale_detail_page/tag_modal_manifest.dart';

class AddNewTagModal extends StatefulWidget {
  AddNewTagModal({Key key, @required this.tale}) : super(key: key);

  final Tale tale;
  static const String routeName = "/AddNewTagModal";

  @override
  _AddNewTagModalState createState() => _AddNewTagModalState();
}

class _AddNewTagModalState extends State<AddNewTagModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _showUpdatingProgressIndicator = false;
  bool _errorSavingTag = false;
  Timer _showErrorSavingTagTimer;

  bool _hasValidationError = false;
  String _newTagStr;

  //Services
  final TaleService _taleService = TaleService.instance;
  final TagService _tagService = TagService.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _showErrorSavingTagTimer?.cancel();
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
    if (_errorSavingTag) {
      return Text("There was an error saving the tag, please try again later");
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

              if (widget.tale.tags.contains(value)) {
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
    if (_showUpdatingProgressIndicator) {
      return CircularProgressIndicator();
    } else if (_errorSavingTag) {
      return Icon(Icons.error, color: Colors.red, size: 48);
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

      Future<void> updateTaleFuture =
          _tagService.addNewTagToTale(widget.tale, _newTagStr);
      setState(() {
        _showUpdatingProgressIndicator = true;
      });

      updateTaleFuture.then((_) {
        Navigator.of(context).pop();
      }).catchError((error) {
        FirebaseAnalyticsService.analytics.logEvent(
            name: "failed_to_add_tag_to_existing_tale",
            parameters: {
              "taleReference": widget.tale.reference,
              "tagAttemptingToAdd": _newTagStr,
//              "userReference": _userService.getCurrentUser().reference
            });
        print("Error: $error");

        setState(() {
          _showUpdatingProgressIndicator = false;
          _errorSavingTag = true;
        });

        _showErrorSavingTagTimer?.cancel();
        _showErrorSavingTagTimer =
            Timer.periodic(Duration(seconds: 3), (Timer timer) async {
          setState(() {
            _showUpdatingProgressIndicator = false;
            _errorSavingTag = false;
          });
        });
      });
    }
  }
}
