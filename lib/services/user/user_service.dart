import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tales_of_jcs/models/user/user.dart';

class UserService {
  //Singleton
  UserService._internal() {
    //Only runs in debug mode, set the database to dev
    assert(() {
      _usersCollection = "users-dev";
      return true;
    }());
  }

  static final UserService _instance = UserService._internal();

  static UserService get instance {
    return _instance;
  }

  static final Firestore _firestore = Firestore.instance;

  static String _usersCollection = "users";

  static String get usersCollection => _usersCollection;

  Future<void> retrieveUser(DocumentReference user) {}

  bool isUserJCS(User user) {
    return user.email == "jcantor-stone@jahnelgroup.com";
  }

  Future<void> updateUserLatestLogin(FirebaseUser fbUser) async {
    final DocumentReference userRef =
        _firestore.document("$usersCollection/${fbUser.uid}");

    _firestore.runTransaction((Transaction tx) async {
      DocumentSnapshot taleSnapshot = await tx.get(userRef);
      if (taleSnapshot.exists) {
        await tx
            .update(userRef, <String, dynamic>{"latestLogin": Timestamp.now()});
      } else {
        //If the user doesn't exist, lets add them to the user table
        User newUser = User.fromFirebaseUser(fbUser,
            latestLogin: Timestamp.now(), isAdmin: false);
        await tx.set(userRef, newUser.toMap());
      }
    });
  }
}
