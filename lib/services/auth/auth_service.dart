import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tales_of_jcs/models/user/user.dart';
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
    if (googleUser == null) {
      // Attempt to sign in without user interaction
      googleUser = await _googleSignIn.signInSilently().catchError(() => null);
    }
    if (googleUser == null) {
      // Force the user to interactively sign in
      googleUser = await _googleSignIn.signIn();
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

  Future<DocumentReference> getCurrentUserDocRef() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return _firestore.document("${UserService.usersCollection}/${user.uid}");
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Stream<FirebaseUser> onAuthStateChanged() {
    return _firebaseAuth.onAuthStateChanged;
  }

  //Don't have to concern ourselves with disposing of this listener because the
  // service will run for the entirety of the app's lifecycle
  void _authStateListener() {
    _firebaseAuth.onAuthStateChanged.listen((FirebaseUser user) {
      if (user == null) {
        if (_lastKnownUser != null) {
          _userService
              .updateUserLatestLogout(_lastKnownUser)
              .catchError((error) {
            print("Error: $error");
          });

          _lastKnownUser = null;
        }
      } else {
        _lastKnownUser = user;
        FirebaseAnalyticsService.analytics.logLogin();

        _userService
            .updateUserLatestLogin(_lastKnownUser)
            .catchError((error) {
          print("Error: $error");
        });
      }
    });
  }
}
