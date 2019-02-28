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

  static String _talesCollection = "tales-test";
  static String get talesCollection => _talesCollection;

  final Stream<QuerySnapshot> talesStream =
      Firestore.instance.collection(talesCollection).snapshots();

  Future<void> createTale(Tale tale) {
    Map<String, dynamic> taleMap = tale.toMap();
    taleMap.addAll(<String, dynamic>{
      "dateCreated": FieldValue.serverTimestamp(),
      "dateLastModified": FieldValue.serverTimestamp(),
    });

    return _firestore.collection(talesCollection).document().setData(taleMap);
  }
}
