import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/models/user/user.dart';

class TaleListWidget extends StatefulWidget {
  final GestureTapCallback onTap;
  final Tale tale;

  TaleListWidget({Key key, @required this.onTap, @required this.tale})
      : super(key: key);

  TaleListWidget.fromTale(Tale tale)
      : this.onTap = null,
        this.tale = tale;

  @override
  _TaleListWidgetState createState() => _TaleListWidgetState();
}

class _TaleListWidgetState extends State<TaleListWidget> {
  User _publisher;
  StreamSubscription _publisherSubscription;

  @override
  void initState() {
    super.initState();

    _setPublisher();
  }

  @override
  void dispose() {
    _publisherSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (_publisher == null) {
      avatar = CircleAvatar(child: Icon(Icons.account_circle, size: 40));
    } else if (_publisher.photoUrl == null) {
      avatar = CircleAvatar(child: Text(_publisher.name[0]));
    } else {
      avatar = CircleAvatar(
        backgroundImage: NetworkImage(_publisher.photoUrl),
      );
    }

    return ListTile(
      leading: avatar,
      title: Text(widget.tale.title),
      onTap: () => Navigator.pushNamed(context, 'tale_detail'),
    );
  }

  void _setPublisher() {
    if (widget.tale.publisher != null) {
      final Stream<DocumentSnapshot> publisherStream =
          widget.tale.publisher.snapshots();

      _publisherSubscription =
          publisherStream.listen((DocumentSnapshot snapshot) {
        setState(() {
          _publisher = User.fromSnapshot(snapshot);
        });
      });
    }
  }
}
