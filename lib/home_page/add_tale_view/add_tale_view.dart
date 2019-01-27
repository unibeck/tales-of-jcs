import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tales_of_jcs/tale/tale.dart';
import 'package:tales_of_jcs/tale/tale_service.dart';

class AddTaleWidget extends StatefulWidget {
  @override
  _AddTaleWidgetState createState() => _AddTaleWidgetState();
}

class _AddTaleWidgetState extends State<AddTaleWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _tagFormFieldKey =
      GlobalKey<FormFieldState>();
  final int _maxTaleTitleLength = 20;

  FocusNode _tagFormFieldFocusNode;
  bool _finalCheckBeforeSubmit;

  TextEditingController _tagTextController;
  Map<String, Chip> _tagChipWidgets;
  Tale _newTale;
  VoidCallback _handleAddTagAction;

  //Services
  final TaleService _taleService = TaleService.instance;

  @override
  void initState() {
    super.initState();

    _tagFormFieldFocusNode = FocusNode();

    //Remove the error message once leaving the tag text box focus. This is
    // because the tag input is treated a different than the other inputs as
    // the user adds tags as chips via the input instead of the tag text
    // being the input
    _tagFormFieldFocusNode.addListener(() {
      if (!_tagFormFieldFocusNode.hasFocus) {
        _tagFormFieldKey.currentState.reset();
      }
    });

    _initFormState();
  }

  void _initFormState() {
    _finalCheckBeforeSubmit = false;

    _tagTextController = TextEditingController();
    _tagChipWidgets = {};
    _newTale = Tale();

    _tagTextController.addListener(() {
      setState(() {
        if (_tagTextController.text == null ||
            _tagTextController.text.isEmpty) {
          _handleAddTagAction = null;
        } else {
          _handleAddTagAction = _addTagToTagChips;
        }
      });
    });
  }

  @override
  void dispose() {
    _tagFormFieldFocusNode?.dispose();
    _tagTextController?.dispose();

    super.dispose();
  }

  void _addTagToTagChips() {
    setState(() {
      _finalCheckBeforeSubmit = false;

      if (_tagFormFieldKey.currentState.validate()) {
        final String textOfNewChip = _tagTextController.text;

        _tagChipWidgets.putIfAbsent(
            textOfNewChip,
            () => Chip(
                  label: Text(textOfNewChip),
                  deleteIcon: Icon(Icons.cancel),
                  onDeleted: () {
                    setState(() {
                      _tagChipWidgets.remove(textOfNewChip);
                    });
                  },
                ));

        _tagTextController.text = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //TODO: When we have a markov chain and/or machine learning model AI for
    // JCS stories we can present a score of how JCS the story being entered is

    return Container(
      color: Theme.of(context).backgroundColor,
      child: Form(
        key: _formKey,
        child: Stack(children: <Widget>[
          ListView(
            children: <Widget>[
              ListTile(
                title: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: TextFormField(
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: _maxTaleTitleLength,
                      maxLengthEnforced: false,
                      decoration: InputDecoration(
                          hintText: 'Joshua did this crazy thing',
                          labelText: 'Story title'),
                      onSaved: (value) {
                        _newTale.title = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Anything is better than nothing';
                        } else if (value.length > _maxTaleTitleLength) {
                          return 'The title has to be shorter than 20 characters';
                        }
                      }),
                ),
              ),
              ListTile(
                title: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      decoration: InputDecoration(
                          hintText: 'This one time, at band camp...',
                          labelText: 'Story'),
                      onSaved: (value) {
                        _newTale.story = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'You must have an interesting JCS story, enter it!';
                        }

                        if (value.length < 18 || value.split(" ").length < 8) {
                          return 'Come on, put some effort into the story';
                        }
                      }),
                ),
              ),
              ListTile(
                title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 8,
                        child: TextFormField(
                          key: _tagFormFieldKey,
                          controller: _tagTextController,
                          textCapitalization: TextCapitalization.words,
                          focusNode: _tagFormFieldFocusNode,
                          decoration: InputDecoration(
                              hintText: 'Impossible',
                              labelText: 'Tag',
                              errorMaxLines: 5),
                          onSaved: (value) {
                            //We purposely don't add `value` as a tag since the
                            // user didn't explicitly add it. There is a check
                            // later to inform the user about the WIP input
                            _newTale.tags.addAll(_tagChipWidgets.keys);
                          },
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                value.split(" ").length != 1) {
                              return 'Tags can only be one word';
                            }

                            if (_finalCheckBeforeSubmit && _tagChipWidgets.length < 1) {
                              return 'Add at least one tag';
                            }

                            if (_tagChipWidgets.containsKey(value)) {
                              return 'You have already added this tag';
                            }
                          },
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: IconButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 17),
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _handleAddTagAction),
                      ),
                    ]),
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.only(bottom: 72, left: 16, right: 16),
                title: Wrap(
                  spacing: 8,
                  children: _tagChipWidgets.values.toList(),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: RaisedButton(
                onPressed: _onFormSubmit,
                child: Text('Submit'),
              ),
            ),
          )
        ]),
      ),
    );
  }

  void _onFormSubmit() async {
    _finalCheckBeforeSubmit = true;

    if (_formKey.currentState.validate()) {
      if (_tagTextController.text != null &&
          _tagTextController.text.isNotEmpty) {
        await _showWIPTagTextDialog(_tagTextController.text);
        return;
      }

      _formKey.currentState.save();

      //TODO: Add publisher information, need user/auth service first

      Future<void> createTaleFuture = _taleService.createTale(_newTale);
      _showIndeterminateProgressDialog();

      createTaleFuture.whenComplete(() {
        Navigator.of(context).pop();
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Success')));

        //Reset the form's state
        setState(() {
          _formKey.currentState.reset();
          _initFormState();
        });
      }).catchError((error) {
        Navigator.of(context).pop();
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Failed')));
      });
    }
  }

  Future<void> _showWIPTagTextDialog(final String tagText) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Work in Progress?"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.body1,
              children: <TextSpan>[
                TextSpan(text: 'You entered '),
                TextSpan(
                    text: '$tagText',
                    style: Theme.of(context).textTheme.body1.copyWith(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        ', but never added it as a tag. You must add it as a tag or clear it before resubmitting.')
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
                return;
              },
            ),
          ],
        );
      },
    );
  }

  void _showIndeterminateProgressDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Submitting"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
