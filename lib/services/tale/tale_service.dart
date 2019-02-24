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
      'dateCreated': FieldValue.serverTimestamp(),
      'dateLastModified': FieldValue.serverTimestamp(),
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

//  final StreamController<List<Tale>> _onNotificationsUpdate =
//  StreamController<List<Tale>>.broadcast();

//  Future<FirebaseUser> currentUser() {
//    Query query = db.collection("users").startAt(searchText).endAt(searchText+ "\uf8ff");
//    return firebaseAuth.currentUser();
//  }

//  Future<void> addTagsToTale(Tale tale, Tag tag) {
//    DocumentReference taleRef = Firestore.instance.collection('users').document(uid);
//    if (tale.reference == null) {
//
//    }
//
//    Map<String, dynamic> taleMap = tag.toMap();
//
//    firestore.runTransaction((Transaction tx) async {
//      DocumentSnapshot postSnapshot = await tx.get(taleRef);
//      if (postSnapshot.exists) {
//        // Extend 'favorites' if the list does not contain the recipe ID:
//        if (!postSnapshot.data['favorites'].contains(recipeId)) {
//          await tx.update(favoritesReference, <String, dynamic>{
//            'favorites': FieldValue.arrayUnion([recipeId])
//          });
//          // Delete the recipe ID from 'favorites':
//        } else {
//          await tx.update(favoritesReference, <String, dynamic>{
//            'favorites': FieldValue.arrayRemove([recipeId])
//          });
//        }
//      } else {
//        // Create a document for the current user in collection 'users'
//        // and add a new array 'favorites' to the document:
//        await tx.set(favoritesReference, {
//          'favorites': [recipeId]
//        });
//      }
//    }).then((result) {
//      return true;
//    }).catchError((error) {
//      print('Error: $error');
//      return false;
//    });
//
//    return firestore.collection('tags').document().setData(taleMap);
//  }

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
