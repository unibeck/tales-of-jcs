import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tales_of_jcs/models/tale/tag.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/models/tale/tale_rating.dart';
import 'package:tales_of_jcs/services/auth/auth_service.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';

class RatingService {
  //Singleton
  RatingService._internal();

  static final RatingService _instance = RatingService._internal();

  static RatingService get instance {
    return _instance;
  }

  static final Firestore _firestore = Firestore.instance;
  static final AuthService _authService = AuthService.instance;
  static final TaleService _taleService = TaleService.instance;

  static String _ratingsCollection = "rating-test";

  static String get ratingsCollection => _ratingsCollection;

  Future<DocumentReference> createNewRating(TaleRating rating) async {
    Map<String, dynamic> tagMap = rating.toMap();
    return _firestore.collection(ratingsCollection).add(tagMap);
  }

  Future<void> addRatingToTaleTX(
      DocumentReference taleRef, int newRatingValue) async {
    //First create the new Tag
    DocumentReference currentUserDocRef =
        await _authService.getCurrentUserDocRef();
    DocumentReference newRatingRef =
        await createNewRating(TaleRating(newRatingValue, currentUserDocRef));

    Future<Map<String, dynamic>> test = _firestore.runTransaction((Transaction tx) async {
      //Get latest record of the tale
      DocumentSnapshot taleSnapshot = await tx.get(taleRef);

      if (taleSnapshot.exists) {
        Tale tale = Tale.fromSnapshot(taleSnapshot);

        List<DocumentReference> newRatingRefList;
        if (tale.ratings != null) {
          List<TaleRating> ratings = await Future.wait(
              tale.ratings.map((DocumentReference reference) async {
            DocumentSnapshot snapshot = await reference.get();
            return TaleRating.fromSnapshot(snapshot);
          }));

          for (TaleRating rating in ratings) {
            //Let's prevent duplicate ratings
            if (rating.reviewer == currentUserDocRef) {
              await tx.update(rating.reference,
                  <String, dynamic>{"rating": newRatingValue});

              return "Updated your rating";
            }
          }

          //If we got here then it is safe to add the new rating
          newRatingRefList = List.from(tale.ratings)..add(newRatingRef);
        } else {
          newRatingRefList = [newRatingRef];
        }

        await tx.update(
            tale.reference, <String, dynamic>{"ratings": newRatingRefList});
        return "Rating submitted!";
      } else {
        throw StateError(
            "The taleRef provided [${taleRef?.toString()}] does not exist in the database.");
      }
    }).catchError((Error error) async {
      //Delete the new rating ref we created before the transaction if anything
      // fails
      await newRatingRef.delete();
      throw error;
    });

    print(test);
  }
}
