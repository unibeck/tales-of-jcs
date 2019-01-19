import 'package:cloud_firestore/cloud_firestore.dart';

class Tag {
  final DocumentReference reference;
  final String title;

  Tag(this.reference, this.title);

  Tag.fromMap(Map<String, dynamic> map, {this.reference})
      : title = map['title'];

  Tag.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map<String, dynamic> toJson() => {'title': title};
}
