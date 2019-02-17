import 'package:flutter/material.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/tale_detail_page/tag_modal_manifest.dart';

class AddNewTagModal extends StatefulWidget {
  AddNewTagModal({Key key, @required this.tale}) : super(key: key);

  final Tale tale;

  @override
  _AddNewTagModalState createState() => _AddNewTagModalState();
}

class _AddNewTagModalState extends State<AddNewTagModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: SizedBox(
          height: 64,
          child: Hero(
            tag: TagModalManifest.getNewChipHeroTag,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32))),
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                              textCapitalization: TextCapitalization.words,
//              maxLength: _maxTaleTitleLength,
                              maxLengthEnforced: false,
                              decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: "ADD NEW TAG"),
                              onSaved: (String value) {
//                _newTale.title = value;
                              },
                              validator: (String value) {
                                if (value == null || value.isEmpty) {
                                  return "Anything is better than nothing";
                                }
                              }),
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: TagModalManifest.getNewChipAddIconHeroTag(),
                      elevation: 3,
                      backgroundColor: Colors.green,
                      mini: true,
                      onPressed: () {},
                      child: Icon(Icons.add),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onFormSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
    }
  }
}
