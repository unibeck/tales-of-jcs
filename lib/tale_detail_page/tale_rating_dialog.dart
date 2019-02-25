import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:tales_of_jcs/models/tale/tag.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/services/analytics/firebase_analytics_service.dart';
import 'package:tales_of_jcs/services/tag/tag_service.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';
import 'package:tales_of_jcs/tale_detail_page/tag_modal_manifest.dart';

typedef OnRatingChange = void Function(double value);

class TaleRatingDialogContent extends StatefulWidget {

  TaleRatingDialogContent({Key key, @required this.onRatingChange}) : super(key: key);

  final OnRatingChange onRatingChange;

  @override
  _TaleRatingDialogContentState createState() => _TaleRatingDialogContentState();
}

class _TaleRatingDialogContentState extends State<TaleRatingDialogContent> {
  static const _maxStarRating = 5;

  int _userSelectedRating = _maxStarRating;

  @override
  void initState() {
    super.initState();

    _userSelectedRating = _maxStarRating;
  }

  @override
  Widget build(BuildContext context) {
    return SmoothStarRating(
      allowHalfRating: false,
      onRatingChanged: (double v) {
        widget.onRatingChange(v);

        //toInt simply truncates the decimal value
        setState(() {
          _userSelectedRating = v.toInt();
        });
      },
      starCount: _maxStarRating,
      rating: _userSelectedRating.toDouble(),
      size: 40.0,
      color: Colors.amber,
      borderColor: Colors.amber,
    );
  }
}
