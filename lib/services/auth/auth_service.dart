import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tales_of_jcs/services/analytics/firebase_analytics_service.dart';

class AuthService {
  //Singleton
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  static AuthService get instance {
    return _instance;
  }

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<FirebaseUser> signIn() async {
    // Attempt to get the currently authenticated user
    GoogleSignInAccount googleUser = _googleSignIn.currentUser;
    if (googleUser == null) {
      // Attempt to sign in without user interaction
      googleUser = await _googleSignIn
          .signInSilently()
          .whenComplete(() => FirebaseAnalyticsService.analytics.logLogin())
          .catchError(() => null);
    }
    if (googleUser == null) {
      // Force the user to interactively sign in
      googleUser = await _googleSignIn
          .signIn()
          .whenComplete(() => FirebaseAnalyticsService.analytics.logLogin());
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<FirebaseUser> getCurrentUser() async {
    return await _firebaseAuth.currentUser();
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Stream<FirebaseUser> onAuthStateChanged() {
    return _firebaseAuth.onAuthStateChanged;
  }
}
