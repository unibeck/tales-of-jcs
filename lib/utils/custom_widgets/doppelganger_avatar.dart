import 'package:flutter/material.dart';
import 'package:tales_of_jcs/models/user/user.dart';

class DoppelgangerAvatar {

  static Widget buildAvatar(BuildContext context, User user, {double accountCircleSize}) {
    Widget avatar;

    if (user == null) {
      if (accountCircleSize != null) {
        avatar = CircleAvatar(child: Icon(Icons.account_circle, size: 40));
      } else {
        avatar = CircleAvatar(child: Icon(Icons.account_circle));
      }
    } else if (user.photoUrl == null) {
      avatar = CircleAvatar(child: Text(user.name[0]));
    } else {
      avatar = CircleAvatar(
        backgroundImage: NetworkImage(user.photoUrl),
      );
    }

    return avatar;
  }

}