import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/models/user/user.dart';
import 'package:tales_of_jcs/tale_detail_page/tale_detail_page.dart';
import 'package:tales_of_jcs/utils/custom_widgets/doppelganger_avatar.dart';

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
    return ListTile(
      leading: DoppelgangerAvatar.buildAvatar(context, _publisher),
      title: Text(widget.tale.title),
      onTap: () {
        return Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: "${TaleDetailPage.routeName}/list"),
            builder: (context) => TaleDetailPage(tale: widget.tale),
          ),
        );
      },
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
