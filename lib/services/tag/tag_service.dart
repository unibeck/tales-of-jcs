import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tales_of_jcs/models/tale/tag.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/services/auth/auth_service.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';

class TagService {
  //Singleton
  TagService._internal();
  static final TagService _instance = TagService._internal();
  static TagService get instance {
    return _instance;
  }

  static final Firestore _firestore = Firestore.instance;
  static final AuthService _authService = AuthService.instance;
  static final TaleService _taleService = TaleService.instance;

  static String _tagsCollection = "tags-test";
  static String get tagsCollection => _tagsCollection;

  Future<DocumentReference> createNewTag(Tag tag) async {
    Map<String, dynamic> tagMap = tag.toMap();
    return _firestore.collection(tagsCollection).add(tagMap);
  }

  Future<List<DocumentReference>> createNewTags(List<Tag> tags) {
    List<Future<DocumentReference>> futures = [];

    if (tags != null) {
      tags.forEach((Tag tag) => futures.add(createNewTag(tag)));
    }

    return Future.wait(futures);
  }

  Future<void> addNewTagToTale(Tale tale, String tagStr) async {
    Tag newTag = Tag(tagStr, [await _authService.getCurrentUserDocRef()]);
    DocumentReference newTagRef = await createNewTag(newTag);

    List<DocumentReference> newTagList = List.from(tale.tags)..add(newTagRef);
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
}
