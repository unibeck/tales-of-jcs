import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tales_of_jcs/tale/tag.dart';
import 'package:tales_of_jcs/tale/tale_rating.dart';
import 'package:tales_of_jcs/user/user.dart';

class Tale {
  final DocumentReference reference;
  final String title;
  final String story;
  final DocumentReference publisher;
  final TaleRating rating;
  final List<User> readBy;
  final String jcsVerified;
  final List<Tag> tags;
  final DateTime dateCreated;
  final DateTime dateLastModified;

  Tale(
      this.reference,
      this.title,
      this.story,
      this.publisher,
      this.rating,
      this.readBy,
      this.jcsVerified,
      this.tags,
      this.dateCreated,
      this.dateLastModified);

  Tale.fromMap(Map<String, dynamic> map, {this.reference})
      : title = map['title'],
        story = map['story'],
        publisher = map['publisher'],
        rating = map['rating'],
        readBy = map['readBy'].cast<User>(),
        jcsVerified = map['jcsVerified'],
        tags = map['tags'].cast<Tag>(),
        dateCreated = map['dateCreated'],
        dateLastModified = map['dateLastModified'];

  Tale.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map<String, dynamic> toJson() => {
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
