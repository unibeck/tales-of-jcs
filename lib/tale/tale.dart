import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tales_of_jcs/tale/tag.dart';
import 'package:tales_of_jcs/user/user.dart';

class Tale {
  DocumentReference reference;
  String title;
  String story;
  DocumentReference publisher;
  DocumentReference rating;
  List<DocumentReference> readBy;
  String jcsVerified;
  List<DocumentReference> tags;
  DateTime dateCreated;
  DateTime dateLastModified;

  Tale();

  Tale.fromMap(Map<String, dynamic> map, {this.reference})
      : title = map['title'],
        story = map['story'],
        publisher = map['publisher'],
        rating = map['rating'],
        readBy = map['readBy']?.cast<DocumentReference>(),
        jcsVerified = map['jcsVerified'],
        tags = map['tags']?.cast<DocumentReference>(),
        dateCreated = map['dateCreated'],
        dateLastModified = map['dateLastModified'];

  Tale.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map<String, dynamic> toMap() => {
        'title': title,
        'story': story,
        'publisher': publisher,
        'rating': rating,
        'readBy': readBy,
        'jcsVerified': jcsVerified,
        'tags': tags,
        'dateCreated': dateCreated,
        'dateLastModified': dateLastModified,
      };
}
