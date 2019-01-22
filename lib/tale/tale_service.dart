import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tales_of_jcs/tale/tale.dart';

class TaleService {
  //Singleton
  TaleService._internal();
  static final TaleService _instance = TaleService._internal();
  static TaleService get instance {
    return _instance;
  }

  final Firestore firestore = Firestore.instance;

  List<Tale> _tales = [];
  final StreamController<List<Tale>> _onNotificationsUpdate =
      StreamController<List<Tale>>.broadcast();

//  Future<FirebaseUser> currentUser() {
//    return firebaseAuth.currentUser();
//  }

  Future<void> createTale(Tale tale) {
    Map<String, dynamic> taleMap = tale.toMap();
    taleMap.addAll(<String, dynamic>{
      'dateCreated': FieldValue.serverTimestamp(),
      'dateLastModified': FieldValue.serverTimestamp(),
    });

    return firestore.collection('tales').document().setData(taleMap);
  }

  List<Tale> get tales {
    return _tales;
  }

//  void _testInit() {
//    User testUser = User("Jonathan", "rajonbeckman@gmail.com",
//        "https://lh3.googleusercontent.com/a-/AAuE7mBXtoQUq3xobrQ6SX6LTEalZ9iZDp4g2ngFzYiCdQ=s192");
//
//    int min = 1;
//    int max = 5;
//    Random rnd = Random();
//
//    for (int i = 0; i < 126; i++) {
//      _tales.add(Tale(
//          "Tale $i",
//          "This is a story of a girl...",
//          testUser,
//          TaleRating(min + (max - min) * rnd.nextDouble(), testUser),
//          [testUser],
//          false,
//          ["Funny"],
//          DateTime.now(),
//          DateTime.now()));
//    }
//  }
}
