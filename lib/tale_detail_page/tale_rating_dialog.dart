import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:tales_of_jcs/models/tale/tag.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/services/analytics/firebase_analytics_service.dart';
import 'package:tales_of_jcs/services/rating/rating_service.dart';
import 'package:tales_of_jcs/services/tag/tag_service.dart';
import 'package:tales_of_jcs/services/tale/tale_service.dart';
import 'package:tales_of_jcs/tale_detail_page/tag_modal_manifest.dart';
import 'package:tales_of_jcs/utils/progress_state.dart';

typedef OnRatingChange = void Function(double value);

class TaleRatingDialogContent extends StatefulWidget {
  TaleRatingDialogContent({Key key, @required this.tale, this.onRatingChange})
      : super(key: key);

  final Tale tale;
  final OnRatingChange onRatingChange;

  @override
  _TaleRatingDialogContentState createState() =>
      _TaleRatingDialogContentState();
}

class _TaleRatingDialogContentState extends State<TaleRatingDialogContent> {
  static const _maxStarRating = 5;

  int _userSelectedRating = _maxStarRating;
  List<String> _rateModalTitles = [
    "Yale.",
    "Jury Duty",
    "Horrific",
    "Bareable",
    "Splendid",
    "Awesome-sauce"
  ];

  ProgressState _saveRatingProgressState = ProgressState.IDLE;
  String _saveRatingMessage;
  Timer _showErrorSavingRatingTimer;
  Timer _showSuccessSavingRatingTimer;

  //Services
  final RatingService _ratingService = RatingService.instance;

  @override
  void initState() {
    super.initState();

    _userSelectedRating = _maxStarRating;
    _saveRatingMessage = "Success";
  }

  @override
  void dispose() {
    _showErrorSavingRatingTimer?.cancel();
    _showSuccessSavingRatingTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Center(child: Text(_rateModalTitles[_userSelectedRating])),
      titlePadding: EdgeInsets.fromLTRB(0, 24, 0, 0),
      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.unmodifiable(() sync* {
          if (_saveRatingProgressState == ProgressState.IDLE) {
            yield Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text("Tap on or slide the stars to rate"),
            );
          }
          yield Center(child: _getDialogContent());
        }()),
      ),
      actions: List.unmodifiable(() sync* {
        yield FlatButton(
          child: Text("Close"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        );
        if (_saveRatingProgressState == ProgressState.IDLE) {
          yield FlatButton(
            child: Text("Rate"),
            onPressed: _saveRating,
          );
        }
      }()),
    );
  }

  Widget _getDialogContent() {
    if (_saveRatingProgressState == ProgressState.LOADING) {
      return Padding(
        padding: EdgeInsets.only(top: 16),
        child: CircularProgressIndicator(),
      );
    } else if (_saveRatingProgressState == ProgressState.ERROR) {
      return Padding(
        padding: EdgeInsets.only(top: 16),
        child: Column(
          children: <Widget>[
            Icon(Icons.error, color: Colors.red, size: 48),
            Text("Error, please try again later")
          ],
        ),
      );
    } else if (_saveRatingProgressState == ProgressState.SUCCESS) {
      return Padding(
        padding: EdgeInsets.only(top: 16),
        child: Column(
          children: <Widget>[
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            Text(_saveRatingMessage)
          ],
        ),
      );
    } else {
      return SmoothStarRating(
        allowHalfRating: false,
        onRatingChanged: (double v) {
          if (widget.onRatingChange != null) {
            widget.onRatingChange(v);
          }

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

  void _saveRating() {
    Future<Map<String, dynamic>> addRatingFuture =
        _ratingService.addRatingToTaleTX(widget.tale, _userSelectedRating);

    setState(() {
      _saveRatingProgressState = ProgressState.LOADING;
    });

    addRatingFuture.then((Map<String, dynamic> result) {
      setState(() {
        _saveRatingProgressState = ProgressState.SUCCESS;
        _saveRatingMessage = result["message"];
      });

      _showSuccessSavingRatingTimer?.cancel();
      _showSuccessSavingRatingTimer =
          Timer(Duration(seconds: 3), () async {
        Navigator.of(context).pop();
      });
    }).catchError((error) {
      FirebaseAnalyticsService.analytics
          .logEvent(name: "failed_to_add_rating_to_existing_tale", parameters: {
        "taleReference": widget.tale.reference.toString(),
        "ratingAttemptingToAdd": _userSelectedRating,
        "error": error.toString()
      });
      print("Error: $error");

      setState(() {
        _saveRatingProgressState = ProgressState.ERROR;
      });

      _showErrorSavingRatingTimer?.cancel();
      _showErrorSavingRatingTimer =
          Timer(Duration(seconds: 3), () async {
        setState(() {
          _saveRatingProgressState = ProgressState.IDLE;
        });
      });
    });
  }
}
