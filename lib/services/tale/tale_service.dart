import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';

class TaleService {
  //Singleton
  TaleService._internal();

  static final TaleService _instance = TaleService._internal();

  static TaleService get instance {
    return _instance;
  }

  static final Firestore _firestore = Firestore.instance;
  static final String _talesCollection = "tales-test";

  final Stream<QuerySnapshot> talesStream =
      Firestore.instance.collection(_talesCollection).snapshots();

  Future<void> createTale(Tale tale) {
    Map<String, dynamic> taleMap = tale.toMap();
    taleMap.addAll(<String, dynamic>{
      "dateCreated": FieldValue.serverTimestamp(),
      "dateLastModified": FieldValue.serverTimestamp(),
    });

    return _firestore.collection(_talesCollection).document().setData(taleMap);
  }

  Future<void> addTagToTale(Tale tale, String tag) async {
    List<String> newTagList = List.from(tale.tags)..add(tag);

    return tale.reference.updateData(<String, dynamic>{"tags": newTagList});
  }

  //Transaction version of adding a tag to a tale. Though this is currently
  // broken in the cloud_firestore library
  Future<bool> addTagToTaleTX(Tale tale, String tag) async {
    List<String> newTagList = List.from(tale.tags)..add(tag);

    return Firestore.instance.runTransaction((Transaction tx) async {
      //Make sure the tale still exists before we update it
      DocumentSnapshot taleSnapshot = await tx.get(tale.reference);
      if (taleSnapshot.exists) {
        await tx.update(tale.reference, <String, dynamic>{"tags": newTagList});
        return {"updated": true};
      }

      return {"updated": false};
    })
        .then((result) => result["updated"])
        .catchError((error) {
      print("Error: $error");
      return false;
    });
  }

  Future<void> updateAllTales() async {
    _firestore.collection(_talesCollection).snapshots().first.then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot docSnapshot) async {
        Tale tale = Tale.fromSnapshot(docSnapshot);
//        await tale.reference.updateData(<String, dynamic>{"lastModifiedUser": FieldValue.delete()});
        await tale.reference.updateData(<String, dynamic>{"publisher": _firestore.document("users/QtjwqNcrT9eQBzAFvuZmrEiFLtj2")});
        print(tale.title);
      });
    });

  }
}
