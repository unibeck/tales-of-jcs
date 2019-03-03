import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tales_of_jcs/services/analytics/firebase_analytics_service.dart';
import 'package:tales_of_jcs/services/user/user_service.dart';

class AuthService {
  //Singleton
  AuthService._internal() {
    _authStateListener();
  }

  static final AuthService _instance = AuthService._internal();

  static AuthService get instance {
    return _instance;
  }

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static final Firestore _firestore = Firestore.instance;
  static final UserService _userService = UserService.instance;

  FirebaseUser _lastKnownUser;

  Future<FirebaseUser> signIn() async {
    // Attempt to get the currently authenticated user
    GoogleSignInAccount googleUser = _googleSignIn.currentUser;
    if (googleUser != null) {
      if (!isUserJG(googleUser.email)) {
        //Give the user a chance to interactively sign in with a JG user
        await _googleSignIn.signOut();
        googleUser = null;
      }
    }

    if (googleUser == null) {
      // Attempt to sign in without user interaction
      googleUser = await _googleSignIn.signInSilently();

      if (googleUser != null) {
        if (!isUserJG(googleUser.email)) {
          //Give the user a chance to interactively sign in with a JG user
          await _googleSignIn.signOut();
          googleUser = null;
        }
      }
    }

    if (googleUser == null) {
      // Force the user to interactively sign in
      googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        if (!isUserJG(googleUser.email)) {
          throw new AuthException(
              "", "You must use a Jahnel Group Google account to sign in");
        }
      }
    }

    if (googleUser == null) {
      throw new AuthException(
          "", "You must use a Jahnel Group Google account to sign in");
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  bool isUserJG(String email) {
    return email != null && email.endsWith("@jahnelgroup.com");
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser fbUser = await _firebaseAuth.currentUser();

    if (fbUser != null) {
      if (!isUserJG(fbUser.email)) {
        throw new AuthException(
            "", "You must use a Jahnel Group Google account to sign in");
      }
    }

    return fbUser;
  }

  Future<DocumentReference> getCurrentUserDocRef() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return _firestore.document("${UserService.usersCollection}/${user.uid}");
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    return _firebaseAuth.signOut();
  }

  Stream<FirebaseUser> onAuthStateChanged() {
    return _firebaseAuth.onAuthStateChanged;
  }

  //Don't have to concern ourselves with disposing of this listener because the
  // service will run for the entirety of the app's lifecycle
  void _authStateListener() {
    _firebaseAuth.onAuthStateChanged.listen((FirebaseUser user) {
      if (user != null) {
        _lastKnownUser = user;
        FirebaseAnalyticsService.analytics.logLogin();

        _userService.updateUserLatestLogin(_lastKnownUser).catchError((error) {
          print("Error: $error");
        });
      }
    });
  }
}
