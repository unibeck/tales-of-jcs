import 'package:flutter/material.dart';
import 'package:tales_of_jcs/tale/tale.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_child_widget.dart';

class TaleListWidget extends StatelessWidget {

  GestureTapCallback onTap;
  String title;
  String publisherPhotoUrl;

  TaleListWidget({Key key, @required this.onTap, @required this.title})
      :super(key: key);

  TaleListWidget.fromTale(Tale tale) {
    onTap = () {}; //TODO
    title = tale.title;
    publisherPhotoUrl = tale.publisher.photoUrl;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(publisherPhotoUrl),
      ),
      title: Text(title),
    );
  }
}
