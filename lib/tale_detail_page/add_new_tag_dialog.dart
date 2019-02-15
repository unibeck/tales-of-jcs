import 'package:flutter/material.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';

class AddNewTagDialog extends StatefulWidget {
  AddNewTagDialog({Key key, @required this.tale}) : super(key: key);

  final Tale tale;

  @override
  _AddNewTagDialogState createState() => _AddNewTagDialogState();
}

class _AddNewTagDialogState extends State<AddNewTagDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String _tagHeroChipNew = "tagHeroChip_new";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: _tagHeroChipNew,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        contentPadding: const EdgeInsets.all(8),
        content: Form(
          key: _formKey,
          child: TextFormField(
              textCapitalization: TextCapitalization.words,
//              maxLength: _maxTaleTitleLength,
              maxLengthEnforced: false,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: "Impossible"),
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
    );
  }

  void _onFormSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
    }
  }
}

class AddNewTagDialogRoute<T> extends PageRouteBuilder<T> {
  AddNewTagDialogRoute({@required Tale tale, RouteSettings settings})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget child) {
                    return AddNewTagDialog(tale: tale);
                  });
            },
            settings: settings);
}
