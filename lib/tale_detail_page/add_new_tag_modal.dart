import 'package:flutter/material.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';
import 'package:tales_of_jcs/tale_detail_page/tag_modal_manifest.dart';

class AddNewTagModal extends StatefulWidget {
  AddNewTagModal({Key key, @required this.tale}) : super(key: key);

  final Tale tale;

  @override
  _AddNewTagModalState createState() => _AddNewTagModalState();
}

class _AddNewTagModalState extends State<AddNewTagModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _showUpdatingProgressIndicator = false;
  bool _hasError = false;
  String _newTagStr;

  //Services
  final TaleService _taleService = TaleService.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double paddingAtTopAndBottomOfCard = 8;
    if (_hasError) {
      paddingAtTopAndBottomOfCard = 16;
    }

    Widget formActionWidget = _getFormActionWidget();

    return Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Hero(
              tag: TagModalManifest.getNewChipHeroTag,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32))),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, paddingAtTopAndBottomOfCard,
                      8, paddingAtTopAndBottomOfCard),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Form(
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
                                    _hasError = true;
                                  });
                                  return "Anything is better than nothing";
                                }

                                value = value.trim();

                                if (value
                                    .split(" ")
                                    .length != 1) {
                                  setState(() {
                                    _hasError = true;
                                  });
                                  return "Tags can only be one word";
                                }

                                if (widget.tale.tags.contains(value)) {
                                  setState(() {
                                    _hasError = true;
                                  });
                                  return "The story already contains this tag";
                                }

                                setState(() {
                                  _hasError = false;
                                });
                              }),
                        ),
                      ),
                      formActionWidget
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getFormActionWidget() {
    if (_showUpdatingProgressIndicator) {
      return CircularProgressIndicator();
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

      Future<void> updateTaleFuture = _taleService.addTagToTale(
          widget.tale, _newTagStr);
      setState(() {
        _showUpdatingProgressIndicator = true;
      });

      updateTaleFuture.whenComplete(() {
        Navigator.of(context).pop();
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Added $_newTagStr!")));

        //Reset the form's state
        setState(() {
          _formKey.currentState.reset();
        });
      }).catchError((error) {
        Navigator.of(context).pop();
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Failed updating tale, please try again")));
      });
    }
  }
}
