import 'package:cloud_firestore/cloud_firestore.dart';

class Tag {
  DocumentReference reference;
  String title;
  List<DocumentReference> likedByUsers;

  Tag(this.title, this.likedByUsers);

  Tag.fromMap(Map<String, dynamic> map, {this.reference})
      : title = map["title"],
        likedByUsers = map["likedByUsers"]?.cast<DocumentReference>();

  Tag.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map<String, dynamic> toMap() => {
        "title": title,
        "likedByUsers": likedByUsers,
      };
}
