import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/models/tale/tale_rating.dart';
import 'package:tales_of_jcs/services/auth/auth_service.dart';

class RatingService {
  //Singleton
  RatingService._internal() {
    //Only runs in debug mode, set the database to dev
    assert(() {
      _ratingsCollection = "ratings-dev";
      return true;
    }());
  }

  static final RatingService _instance = RatingService._internal();

  static RatingService get instance {
    return _instance;
  }

  static final Firestore _firestore = Firestore.instance;
  static final AuthService _authService = AuthService.instance;

  static String _ratingsCollection = "ratings";

  static String get ratingsCollection => _ratingsCollection;

  Future<DocumentReference> createNewRating(TaleRating rating) async {
    Map<String, dynamic> tagMap = rating.toMap();
    return _firestore.collection(ratingsCollection).add(tagMap);
  }

  ///Add a rating to the tale for a user if he doesn't already have one or
  /// update (create new/delete old) if he has already rated the tale. The
  /// reason we create a new rating and delete the old one is so listeners of
  /// the tale will see the rating references updated. If we simple updated the
  /// rating value of the pre-existing rating record, listeners of the tale
  /// wouldn't be notified since none of the rating references were updated.
  Future<Map<String, dynamic>> addRatingToTaleTX(
      DocumentReference taleRef, int newRatingValue) async {
    //First create the new Rating
    DocumentReference currentUserDocRef =
        await _authService.getCurrentUserDocRef();

    //Need to create the new Rating outside of the transaction so we have the
    // reference to add to the tale rating list
    DocumentReference newRatingRef =
        await createNewRating(TaleRating(newRatingValue, currentUserDocRef));

    return _firestore.runTransaction((Transaction tx) async {
      //Get latest record of the tale
      DocumentSnapshot taleSnapshot = await tx.get(taleRef);

      if (taleSnapshot.exists) {
        Tale tale = Tale.fromSnapshot(taleSnapshot);

        if (tale.ratings != null) {
          for (DocumentReference ratingRef in tale.ratings) {
            DocumentSnapshot snapshot = await ratingRef.get();
            TaleRating rating = TaleRating.fromSnapshot(snapshot);

            if (rating.reviewer == currentUserDocRef) {
              //Add the new rating reference to the tale
              await tx.update(tale.reference, <String, dynamic>{
                "ratings": FieldValue.arrayUnion([newRatingRef])
              });

              //Remove the old rating reference from the tale
              await tx.update(tale.reference, <String, dynamic>{
                "ratings": FieldValue.arrayRemove([ratingRef])
              });

              //Delete the old rating since we added a new one
              await tx.delete(ratingRef);

              return {"message": "Your rating has been updated!"};
            }
          }
        }

        await tx.update(taleSnapshot.reference, <String, dynamic>{
          "ratings": FieldValue.arrayUnion([newRatingRef])
        });
        return {"message": "Rating submited!"};
      } else {
        throw StateError(
            "The taleRef provided [${taleRef?.toString()}] does not exist in the database.");
      }
    }).catchError((error) async {
      //Delete the new rating ref we created before the transaction if anything
      // fails
      await newRatingRef.delete();
      throw error;
    });
  }
}
