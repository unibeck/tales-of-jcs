import 'package:cloud_firestore/cloud_firestore.dart';

class Tale {
  DocumentReference reference;
  String title;
  String story;
  DocumentReference publisher;
  DocumentReference lastModifiedUser;
  List<DocumentReference> tags = [];
  List<DocumentReference> ratings = [];

  //TODO: This should be on the user record, but vice-versa (.e. talesRead)
  List<DocumentReference> readBy = [];

  String jcsVerified;

  Timestamp dateCreated;
  Timestamp dateLastModified;

  Tale();

  Tale.fromMap(Map<String, dynamic> map, {this.reference})
      : title = map["title"],
        story = map["story"],
        publisher = map["publisher"],
        lastModifiedUser = map["lastModifiedUser"],
        tags = map["tags"]?.cast<DocumentReference>(),
        ratings = map["ratings"]?.cast<DocumentReference>(),
        readBy = map["readBy"]?.cast<DocumentReference>(),
        jcsVerified = map["jcsVerified"],
        dateCreated = map["dateCreated"],
        dateLastModified = map["dateLastModified"];

  Tale.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map<String, dynamic> toMap() => {
        "title": title,
        "story": story,
        "publisher": publisher,
        "lastModifiedUser": lastModifiedUser,
        "tags": tags,
        "rating": ratings,
        "readBy": readBy,
        "jcsVerified": jcsVerified,
        "dateCreated": dateCreated,
        "dateLastModified": dateLastModified,
      };
}
