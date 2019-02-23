import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class FirebaseAnalyticsService {
  //Singleton
  FirebaseAnalyticsService._internal();

  static final FirebaseAnalyticsService _instance = FirebaseAnalyticsService._internal();

  static FirebaseAnalyticsService get instance {
    return _instance;
  }

  static final FirebaseAnalytics _analytics = FirebaseAnalytics();
  static final FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(analytics: _analytics);

  static FirebaseAnalytics get analytics => _analytics;
  static FirebaseAnalyticsObserver get observer => _observer;
}