import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tales_of_jcs/services/auth/auth_service.dart';

class FirebaseAnalyticsService {
  //Singleton
  FirebaseAnalyticsService._internal() {
    _authService.onAuthStateChanged().listen((FirebaseUser user) {
      print("The user is [$user]");

      if (user == null) {
        _analytics.setUserId(null);
      } else {
        _analytics.setUserId(user.uid);
      }
    });
  }

  static final FirebaseAnalyticsService _instance =
      FirebaseAnalyticsService._internal();

  static FirebaseAnalyticsService get instance {
    return _instance;
  }

  static final FirebaseAnalytics _analytics = FirebaseAnalytics();
  static final FirebaseAnalyticsObserver _observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  static FirebaseAnalytics get analytics => _analytics;

  static FirebaseAnalyticsObserver get observer => _observer;

  //Services
  final AuthService _authService = AuthService.instance;
}
