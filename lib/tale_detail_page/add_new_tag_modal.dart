import 'package:flutter/material.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';

class AddNewTagModal extends StatefulWidget {
  AddNewTagModal({Key key, @required this.tale}) : super(key: key);

  final Tale tale;

  @override
  _AddNewTagModalState createState() => _AddNewTagModalState();
}

class _AddNewTagModalState extends State<AddNewTagModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String _tagHeroChipNew = "tagHeroChip_new";

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
            tag: _tagHeroChipNew,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32))),
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
