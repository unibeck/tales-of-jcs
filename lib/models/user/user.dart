import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  final DocumentReference reference;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime latestLogin;
  final DateTime latestLogout;

  User(this.reference, this.name, this.email, this.photoUrl, this.latestLogin,
      this.latestLogout);

  User.fromMap(Map<String, dynamic> map, {this.reference})
      : name = map["name"],
        email = map["email"],
        photoUrl = map["photoUrl"],
        latestLogin = map["latestLogin"],
        latestLogout = map["latestLogout"];

  User.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  User.fromFirebaseUser(FirebaseUser fbUser,
      {this.reference, this.latestLogin, this.latestLogout})
      : name = fbUser.displayName,
        email = fbUser.email,
        photoUrl = fbUser.photoUrl;

  Map<String, dynamic> toMap() => {
        "name": name,
        "email": email,
        "photoUrl": photoUrl,
        "latestLogin": latestLogin,
        "latestLogout": latestLogout,
      };
}
