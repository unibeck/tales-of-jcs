import 'package:cloud_firestore/cloud_firestore.dart';

class Tale {
  DocumentReference reference;
  String title;
  String story;
  DocumentReference publisher;

  List<DocumentReference> ratings;
  double averageRating;

  List<DocumentReference> readBy = [];
  String jcsVerified;
  List<String> tags = [];
  DateTime dateCreated;
  DateTime dateLastModified;
  DocumentReference lastModifiedUser;

  Tale();

  Tale.fromMap(Map<String, dynamic> map, {this.reference})
      : title = map["title"],
        story = map["story"],
        publisher = map["publisher"],
        ratings = map["rating"],
        readBy = map["readBy"]?.cast<DocumentReference>(),
        jcsVerified = map["jcsVerified"],
        tags = map["tags"]?.cast<String>(),
        dateCreated = map["dateCreated"],
        dateLastModified = map["dateLastModified"];

  Tale.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map<String, dynamic> toMap() => {
        "title": title,
        "story": story,
        "publisher": publisher,
        "rating": ratings,
        "readBy": readBy,
        "jcsVerified": jcsVerified,
        "tags": tags,
        "dateCreated": dateCreated,
        "dateLastModified": dateLastModified,
      };
}
