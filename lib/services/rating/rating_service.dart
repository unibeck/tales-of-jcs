import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/models/tale/tale_rating.dart';
import 'package:tales_of_jcs/services/auth/auth_service.dart';

class RatingService {
  //Singleton
  RatingService._internal();

  static final RatingService _instance = RatingService._internal();

  static RatingService get instance {
    return _instance;
  }

  static final Firestore _firestore = Firestore.instance;
  static final AuthService _authService = AuthService.instance;

  static String _ratingsCollection = "rating";

  static String get ratingsCollection => _ratingsCollection;

  Future<DocumentReference> createNewRating(TaleRating rating) async {
    Map<String, dynamic> tagMap = rating.toMap();
    return _firestore.collection(ratingsCollection).add(tagMap);
  }

  Future<Map<String, dynamic>> addRatingToTaleTX(
      Tale tale, int newRatingValue) async {
    //First create the new Rating
    DocumentReference currentUserDocRef =
        await _authService.getCurrentUserDocRef();
    DocumentReference newRatingRef =
        await createNewRating(TaleRating(newRatingValue, currentUserDocRef));

    return _firestore.runTransaction((Transaction tx) async {
      //Get latest record of the tale
      //TODO: This doesn't work as a transaction
      //DocumentSnapshot taleSnapshot = await tx.get(tale.reference);

      List<DocumentReference> newRatingRefList;
      if (tale.ratings != null) {
        List<TaleRating> ratings = await Future.wait(
            tale.ratings.map((DocumentReference reference) async {
          DocumentSnapshot snapshot = await tx.get(reference);
          return TaleRating.fromSnapshot(snapshot);
        }));

        for (TaleRating rating in ratings) {
          //Let's prevent duplicate ratings
          if (rating.reviewer == currentUserDocRef) {
            await tx.update(
                rating.reference, <String, dynamic>{"rating": newRatingValue});

            await tx.delete(newRatingRef);
            return {"message": "Your rating has been updated!"};
          }
        }

        //If we got here then it is safe to add the new rating
        newRatingRefList = List.from(tale.ratings)..add(newRatingRef);
      } else {
        newRatingRefList = [newRatingRef];
      }

      await tx.update(
          tale.reference, <String, dynamic>{"ratings": newRatingRefList});
      return {"message": "Rating submited!"};
    }).catchError((error) async {
      //Delete the new rating ref we created before the transaction if anything
      // fails
      await newRatingRef.delete();
      throw error;
    });
  }
}
