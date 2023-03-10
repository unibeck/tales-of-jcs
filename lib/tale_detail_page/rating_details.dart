import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/models/tale/tale_rating.dart';
import 'package:tales_of_jcs/utils/custom_widgets/custom_shimmer.dart';

class RatingDetails extends StatefulWidget {
  RatingDetails({Key key, @required this.tale}) : super(key: key);

  Tale tale;

  @override
  _RatingDetailsState createState() => _RatingDetailsState();
}

class _RatingDetailsState extends State<RatingDetails> {
  //View related
  StreamSubscription<DocumentSnapshot> _taleSnapshotSubscription;
  List<TaleRating> _ratings;
  double _averageRating;

  @override
  void initState() {
    super.initState();

    _ratings = null;
    _averageRating = null;

    /////////////// Setup listeners ///////////////////////
    _taleSnapshotSubscription =
        widget.tale.reference.snapshots().listen((DocumentSnapshot snapshot) {
      Tale updatedTale = Tale.fromSnapshot(snapshot);

      if (updatedTale.ratings != null) {
        updateRatings(updatedTale);
      }
    });
  }

  Future<List<TaleRating>> updateRatings(Tale tale) async {
    return Future.wait(tale.ratings.map((DocumentReference reference) async {
      DocumentSnapshot snapshot = await reference.get();
      if (snapshot == null || !snapshot.exists) {
        return null;
      }

      return TaleRating.fromSnapshot(snapshot);
    })).then((List<TaleRating> ratings) {
      Timer(Duration(seconds: 1), () async {
        if (mounted) {
          setState(() {
            widget.tale = tale;
            _ratings = ratings.where((value) => value != null).toList();
            if (_ratings != null && _ratings.isNotEmpty) {
              _averageRating = _ratings
                      .map((TaleRating rating) => rating.rating)
                      .reduce((a, b) => a + b) /
                  _ratings.length;
            } else {
              _ratings = null;
              _averageRating = null;
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _taleSnapshotSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _getStarChildren(),
      subtitle: _getSubtitleRatingText(),
    );
  }

  Widget _getStarChildren() {
    //If we haven't loaded the rating references yet
    if (_averageRating == null || _ratings == null) {
      //If we have ratings to show eventually, but we're still loading
      if (widget.tale.ratings != null && widget.tale.ratings.isNotEmpty) {
        return Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.amber,
            child: Row(children: <Widget>[
              Icon(Icons.star),
              Icon(Icons.star),
              Icon(Icons.star),
              Icon(Icons.star),
              Icon(Icons.star),
            ]));
      } else {
        return Row(children: <Widget>[
          Icon(Icons.star, color: Colors.white),
          Icon(Icons.star, color: Colors.white),
          Icon(Icons.star, color: Colors.white),
          Icon(Icons.star, color: Colors.white),
          Icon(Icons.star, color: Colors.white),
        ]);
      }
    } else {
      //TODO: this causes a small overflow during animating into this
      // widget. "A RenderFlex overflowed by 0.787 pixels on the right"
      // This should be fine as it's not noticeable so early into the
      // animation and is small
      return Row(children: <Widget>[
        Icon(
          _averageRating >= 1
              ? Icons.star
              : (_averageRating >= 0.5 ? Icons.star_half : Icons.star_border),
          color: Colors.white,
        ),
        Icon(
          _averageRating >= 2
              ? Icons.star
              : (_averageRating >= 1.5 ? Icons.star_half : Icons.star_border),
          color: Colors.white,
        ),
        Icon(
          _averageRating >= 3
              ? Icons.star
              : (_averageRating >= 2.5 ? Icons.star_half : Icons.star_border),
          color: Colors.white,
        ),
        Icon(
          _averageRating >= 4
              ? Icons.star
              : (_averageRating >= 3.5 ? Icons.star_half : Icons.star_border),
          color: Colors.white,
        ),
        Icon(
          _averageRating >= 5
              ? Icons.star
              : (_averageRating >= 4.5 ? Icons.star_half : Icons.star_border),
          color: Colors.white,
        )
      ]);
    }
  }

  Widget _getSubtitleRatingText() {
    //If we haven't loaded the rating references yet
    if (_averageRating == null || _ratings == null) {
      //If we have ratings to show eventually, but we're still loading
      if (widget.tale.ratings != null && widget.tale.ratings.isNotEmpty) {
        return Text("Loading ratings...",
            style: Theme.of(context)
                .textTheme
                .subtitle
                .copyWith(color: Colors.white));
      } else {
        return Text("No one has rated this story yet, go be the first!",
            style: Theme.of(context)
                .textTheme
                .subtitle
                .copyWith(color: Colors.white));
      }
    } else {
      String pluralizeStr = Intl.plural(_ratings.length,
          zero: "from 0 ratings",
          one: "from 1 rating",
          other: "from ${_ratings.length} ratings");

      return Text("${_averageRating.toStringAsFixed(1)} stars $pluralizeStr",
          style: Theme.of(context)
              .textTheme
              .subtitle
              .copyWith(color: Colors.white));
    }
  }
}
