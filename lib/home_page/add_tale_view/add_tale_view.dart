import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddTaleWidget extends StatefulWidget {
  @override
  _AddTaleWidgetState createState() => _AddTaleWidgetState();
}

class _AddTaleWidgetState extends State<AddTaleWidget> {
  final _formKey = GlobalKey<FormState>();
  final _tagFormFieldKey = GlobalKey<FormFieldState>();
  final int _maxTaleTitleLength = 20;
  final TextEditingController _tagTextController = TextEditingController();

  VoidCallback _handleAddTagAction;
  Map<String, Chip> _tagChipWidgets = {};

  @override
  void initState() {
    super.initState();

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
    _tagTextController.dispose();
    super.dispose();
  }

  void _addTagToTagChips() {
    setState(() {
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
//      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Stack(children: <Widget>[
          ListView(
            children: <Widget>[
              ListTile(
                title: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: _maxTaleTitleLength,
                      maxLengthEnforced: false,
                      decoration: InputDecoration(
                          hintText: 'Joshua did this crazy thing',
                          labelText: 'Story title'),
                      validator: (value) {
//                        if (value == null || value.isEmpty) {
//                          return 'Anything is better than nothing';
//                        } else if (value.length > _maxTaleTitleLength) {
//                          return 'The title has to be shorter than 20 characters';
//                        }
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
                      validator: (value) {
//                        if (value == null || value.isEmpty) {
//                          return 'You must have an interesting JCS story, enter it!';
//                        }

//                  if (value.length < 18 || value.split(" ").length < 8) {
//                    return 'Come on, put some effort into the story';
//                  }
                      }),
                ),
              ),
              ListTile(
                trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _handleAddTagAction),
                title: TextFormField(
                  key: _tagFormFieldKey,
                  controller: _tagTextController,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      InputDecoration(hintText: 'Impossible', labelText: 'Tag', errorMaxLines: 5),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        value.split(" ").length != 1) {
                      return 'Tags can only be one word';
                    }

                    if (_tagChipWidgets.containsKey(value)) {
                      return 'You have already added this tag';
                    }

                    if (_tagChipWidgets.length >= 3) {
                      return 'You can only add three tags to a story, '
                          'delete another one if you would like to add '
                          'this one instead';
                    }
                  },
                ),
              ),
              ListTile(
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
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    //                      _formKey.currentState.save();
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                  }
                },
                child: Text('Submit'),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
