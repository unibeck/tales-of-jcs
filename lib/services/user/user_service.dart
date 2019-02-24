import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  //Singleton
  UserService._internal();
  static final UserService _instance = UserService._internal();
  static UserService get instance {
    return _instance;
  }

  static final Firestore _firestore = Firestore.instance;
  static final String _talesCollection = "tales-test";

  final Stream<QuerySnapshot> talesStream =
      Firestore.instance.collection(_talesCollection).snapshots();

  Future<void> retrieveUser(DocumentReference user) {

  }
}
