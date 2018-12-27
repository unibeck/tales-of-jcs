import 'dart:math';

import 'package:tales_of_jcs/tale/tale.dart';
import 'package:tales_of_jcs/tale/tale_rating.dart';
import 'package:tales_of_jcs/user/user.dart';

class TaleService {
  List<Tale> _tales = [];

  TaleService() {
    _testInit();
  }

  List<Tale> get tales {
    return _tales;
  }

  void _testInit() {
    User testUser = User("Jonathan", "rajonbeckman@gmail.com", "https://lh3.googleusercontent.com/a-/AAuE7mBXtoQUq3xobrQ6SX6LTEalZ9iZDp4g2ngFzYiCdQ=s192");

    int min = 1;
    int max = 5;
    Random rnd = Random();

    for (int i = 0; i < 5; i++) {
      _tales.add(
          Tale("Tale $i", "This is a story of a girl...", testUser,
              TaleRating(min + (max - min) * rnd.nextDouble(), testUser),
              [testUser], false, ["Funny"], DateTime.now(), DateTime.now()
          )
      );
    }
  }
}