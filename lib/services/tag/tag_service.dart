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

    List<DocumentReference> newTagList;
    if (tale.tags != null) {
      newTagList = List.from(tale.tags)..add(newTagRef);
    } else {
      newTagList = [newTagRef];
    }

    return tale.reference.updateData(<String, dynamic>{"tags": newTagList});
  }

  Future<Map<String, dynamic>> addTagToTaleTX(
      DocumentReference taleRef, String newTagStr) async {
    //First create the new Tag
    DocumentReference currentUserDocRef =
        await _authService.getCurrentUserDocRef();
    DocumentReference newTagRef =
        await createNewTag(Tag(newTagStr, [currentUserDocRef]));

    return _firestore.runTransaction((Transaction tx) async {
      //Get latest record of the tale
      DocumentSnapshot taleSnapshot = await tx.get(taleRef);

      if (taleSnapshot.exists) {
        Tale tale = Tale.fromSnapshot(taleSnapshot);

        List<DocumentReference> newTagRefList;
        if (tale.tags != null) {
          List<Tag> tags = await Future.wait(
              tale.tags.map((DocumentReference reference) async {
            DocumentSnapshot snapshot = await reference.get();
            return Tag.fromSnapshot(snapshot);
          }));

          //Check if any duplicates were made between UI validation and the
          // transaction starting
          for (Tag tag in tags) {
            //If a duplicate is found then simply add the user to the
            // likedByUser field of the tag since they were trying to add it
            // anyways. Then safely return out as we don't want to do anymore
            // processing
            if (tag.title == (newTagStr)) {

              //Only add the user if he isn't already part of the list
              if (tag.likedByUsers == null ||
                  tag.likedByUsers.contains(currentUserDocRef)) {
                List<DocumentReference> likedByUsers =
                    List.from(tag.likedByUsers ?? [])..add(currentUserDocRef);

                await tx.update(tag.reference,
                    <String, dynamic>{"likedByUsers": likedByUsers});
              }

              return {"message": "Tag updated"};
            }
          }

          //If we got here then it is still safe to add the new tag
          newTagRefList = List.from(tale.tags)..add(newTagRef);
        } else {
          newTagRefList = [newTagRef];
        }

        await tx
            .update(tale.reference, <String, dynamic>{"tags": newTagRefList});
        return {"message": "Tag submited!"};
      } else {
        throw StateError(
            "The taleRef provided [${taleRef?.toString()}] does not exist in the database.");
      }
    }).catchError((error) async {
      //Delete the new tag ref we created before the transaction if anything
      // fails
      await newTagRef.delete();
      throw error;
    });
  }
}
