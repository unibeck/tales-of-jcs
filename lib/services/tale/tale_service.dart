import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/services/auth/auth_service.dart';

class TaleService {
  //Singleton
  TaleService._internal() {
    //Only runs in debug mode, set the database to dev
    assert(() {
      _talesCollection = "tales-dev";
      return true;
    }());
  }

  static final TaleService _instance = TaleService._internal();

  static TaleService get instance {
    return _instance;
  }

  static final Firestore _firestore = Firestore.instance;

  static String _talesCollection = "tales";

  static String get talesCollection => _talesCollection;

  Stream<QuerySnapshot> get talesStream =>
      _firestore.collection(talesCollection).snapshots();

  final AuthService _authService = AuthService.instance;

  Future<List<Tale>> retrieveTalesCollection() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection(talesCollection).getDocuments();

    return querySnapshot.documents.map((DocumentSnapshot taleSnapshot) {
      return Tale.fromSnapshot(taleSnapshot);
    }).toList();
  }

  Future<void> createTale(Tale tale) {
    Map<String, dynamic> taleMap = tale.toMap();
    taleMap.addAll(<String, dynamic>{
      "dateCreated": FieldValue.serverTimestamp(),
      "dateLastModified": FieldValue.serverTimestamp(),
    });

    return _firestore.collection(talesCollection).document().setData(taleMap);
  }

  Future<Map<String, dynamic>> updateTaleStory(
      Tale tale, String updatedTaleStory) async {
    DocumentReference userRef = await _authService.getCurrentUserDocRef();

    tale.story = updatedTaleStory;
    tale.lastModifiedUser = userRef;
    tale.dateLastModified = Timestamp.now();

    tale.reference.updateData(<String, dynamic>{
      "story": updatedTaleStory,
      "lastModifiedUser": userRef,
      "dateLastModified": FieldValue.serverTimestamp()
    });

    return {"updatedTale": tale};
  }

  Future<Map<String, dynamic>> updateTaleStoryTX(
      DocumentReference taleRef, String updatedTaleStory) async {
    DocumentReference userRef = await _authService.getCurrentUserDocRef();

    return _firestore.runTransaction((Transaction tx) async {
      //Get latest record of the tale
      DocumentSnapshot taleSnapshot = await tx.get(taleRef);

      if (taleSnapshot.exists) {
        Tale tale = Tale.fromSnapshot(taleSnapshot);
        tale.story = updatedTaleStory;
        tale.lastModifiedUser = userRef;

        await tx.update(tale.reference, <String, dynamic>{
          "story": updatedTaleStory,
          "lastModifiedUser": userRef
        });

        return {"updatedTale": tale};
      } else {
        throw StateError(
            "The tagRef provided [${taleRef?.toString()}] does not exist in the database.");
      }
    });
  }
}
