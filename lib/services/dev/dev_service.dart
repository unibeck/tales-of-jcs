import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/models/user/user.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';
import 'package:tales_of_jcs/services/user/user_service.dart';

class DevService {
  //Singleton
  DevService._internal();

  static final DevService _instance = DevService._internal();

  static DevService get instance {
    return _instance;
  }

  static final Firestore _firestore = Firestore.instance;

  Future<void> updateAllUsers() async {
    _firestore
        .collection(UserService.usersCollection)
        .snapshots()
        .first
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot docSnapshot) async {
        if (docSnapshot.exists) {
          User user = User.fromSnapshot(docSnapshot);
//        await tale.reference.updateData(<String, dynamic>{"tags": FieldValue.delete()});
          await user.reference.updateData(<String, dynamic>{"isAdmin": true});
          print(user.name);
        }
      });
    });
  }

  Future<void> updateAllTales() async {
    _firestore
        .collection(TaleService.talesCollection)
        .snapshots()
        .first
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot docSnapshot) async {
        Tale tale = Tale.fromSnapshot(docSnapshot);
//        await tale.reference.updateData(<String, dynamic>{"tags": FieldValue.delete()});
        await tale.reference.updateData(<String, dynamic>{
          "publisher": _firestore.document("users/QtjwqNcrT9eQBzAFvuZmrEiFLtj2")
        });
        print(tale.title);
      });
    });
  }
}
