import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';

class TaleService {
  //Singleton
  TaleService._internal() {
//    talesCollectionsSubscription = _firestore
//        .collection(talesCollection)
//        .snapshots()
//        .listen((QuerySnapshot snapshot) {});
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
}
