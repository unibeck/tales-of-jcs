import 'package:cloud_firestore/cloud_firestore.dart';

class TaleRating {
  DocumentReference reference;
  int rating;
  DocumentReference reviewer;

  TaleRating(this.rating, this.reviewer);

  TaleRating.fromMap(Map<String, dynamic> map, {this.reference})
      : rating = map["rating"],
        reviewer = map["reviewer"];

  TaleRating.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map<String, dynamic> toMap() => {
        "rating": rating,
        "reviewer": reviewer,
      };
}
