import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tales_of_jcs/models/user/user.dart';

class UserService {
  //Singleton
  UserService._internal();

  static final UserService _instance = UserService._internal();

  static UserService get instance {
    return _instance;
  }

  static final Firestore _firestore = Firestore.instance;

  static String _usersCollection = "users";
  static String get usersCollection => _usersCollection;

  Future<void> retrieveUser(DocumentReference user) {}

  Future<void> updateUserLatestLogin(FirebaseUser fbUser) async {
    final DocumentReference userRef =
        _firestore.document("$usersCollection/${fbUser.uid}");

    _firestore.runTransaction((Transaction tx) async {
      DocumentSnapshot taleSnapshot = await tx.get(userRef);
      if (taleSnapshot.exists) {
        await tx
            .update(userRef, <String, dynamic>{"latestLogin": DateTime.now()});
      } else {
        //If the user doesn't exist, lets add them to the user table
        User newUser = User.fromFirebaseUser(fbUser,
            latestLogin: DateTime.now(), latestLogout: DateTime.now());
        await tx.set(userRef, newUser.toMap());
      }
    });
  }

  Future<void> updateUserLatestLogout(FirebaseUser fbUser) async {
    final DocumentReference userRef =
        _firestore.document("$usersCollection/${fbUser.uid}");

    _firestore.runTransaction((Transaction tx) async {
      DocumentSnapshot taleSnapshot = await tx.get(userRef);
      if (taleSnapshot.exists) {
        await tx
            .update(userRef, <String, dynamic>{"latestLogout": DateTime.now()});
      } else {
        //We should never into a situation where a user can logout, but is not
        // in the user table. Though if we do, let's create a user in the user
        // table
        User newUser = User.fromFirebaseUser(fbUser,
            latestLogin: DateTime.now(), latestLogout: DateTime.now());
        await tx.set(userRef, newUser.toMap());
      }
    });
  }
}
