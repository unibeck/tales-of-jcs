import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddTaleWidget extends StatefulWidget {
  @override
  _AddTaleWidgetState createState() => _AddTaleWidgetState();
}

class _AddTaleWidgetState extends State<AddTaleWidget> {
  final _formKey = GlobalKey<FormState>();

  final int _maxTaleTitleLength = 20;

  @override
  Widget build(BuildContext context) {
    //TODO: When we have a markov chain and/or machine learning model AI for
    // JCS stories we can present a score of how JCS the story being entered is

    return Container(
      color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                      maxLength: _maxTaleTitleLength,
                      maxLengthEnforced: false,
                      keyboardType: TextInputType.text,
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: TextFormField(
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
                ],
              ),
              RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
  //                      _formKey.currentState.save();
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                  }
                },
                child: Text('Submit'),
              ),
            ]),
      ),
    );
  }
}
