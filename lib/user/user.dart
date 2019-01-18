import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final DocumentReference reference;
  final String name;
  final String email;
  final String photoUrl;

  User(this.reference, this.name, this.email, this.photoUrl);

  User.fromMap(Map<String, dynamic> map, {this.reference})
      : name = map['name'],
        email = map['email'],
        photoUrl = map['photoUrl'];

  User.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
      };
}
