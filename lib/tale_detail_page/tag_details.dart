import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tales_of_jcs/models/tale/tag.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/models/tale/tale_rating.dart';
import 'package:tales_of_jcs/tale_detail_page/add_new_tag_modal.dart';
import 'package:tales_of_jcs/tale_detail_page/tag_modal_manifest.dart';
import 'package:tales_of_jcs/tale_detail_page/tale_detail_page.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hero_modal_route.dart';
import 'package:tales_of_jcs/utils/primary_app_theme.dart';

class TagDetails extends StatefulWidget {
  TagDetails({Key key, @required this.tale}) : super(key: key);

  Tale tale;

  @override
  _TagDetailsState createState() => _TagDetailsState();
}

class _TagDetailsState extends State<TagDetails> {
  final Random random = Random();
  final int min = 12;
  final int max = 26;

  //View related
  StreamSubscription<DocumentSnapshot> _taleSnapshotSubscription;
  List<Tag> _tags;

  bool _showAddNewTagWidget = true;
  Animation<double> _newChipAnimation;

  List<String> _initShimmerChipStrings = [];

  @override
  void initState() {
    super.initState();

    //Create n Strings of r length,
    // where n = number of tags and r is a random number between min and max
    if (widget.tale.tags != null) {
      _initShimmerChipStrings = widget.tale.tags.map((DocumentReference ref) {
        return List<String>.generate(min + random.nextInt(max - min), (int i) {
          return " ";
        }).join();
      }).toList();
    }

    /////////////// Setup listeners ///////////////////////
    _taleSnapshotSubscription =
        widget.tale.reference.snapshots().listen((DocumentSnapshot snapshot) {
      Tale updatedTale = Tale.fromSnapshot(snapshot);
      setState(() {
        widget.tale = updatedTale;
      });

      if (updatedTale.tags != null) {
        updateTags(updatedTale.tags);
      }
    });
  }

  Future<List<TaleRating>> updateTags(List<DocumentReference> tagsRef) async {
    return Future.wait(tagsRef.map((DocumentReference reference) async {
      DocumentSnapshot snapshot = await reference.get();
      return Tag.fromSnapshot(snapshot);
    })).then((List<Tag> tags) {
      Timer(Duration(seconds: 1), () async {
        if (mounted) {
          setState(() {
            _tags = tags;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _newChipAnimation?.removeStatusListener(_newChipAnimationListener);
    _taleSnapshotSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.only(bottom: 72, left: 16, right: 16),
        title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: _buildWrapContent(context)));
  }

  List<Widget> _buildWrapContent(BuildContext context) {
    if (_tags != null) {
      return _buildTagChips(context);
    } else {
      return _buildShimmerChips();
    }
  }

  List<Widget> _buildTagChips(BuildContext context) {
    List<Widget> tagChips = List<Widget>();

    //Add all tags associated with the Tale
    if (_tags != null) {
      tagChips = _tags.map((Tag tag) {
        return _tagToHeroChip(tag);
      }).toList();
    }

    //Add a chip for a user to add additional tags
    tagChips.add(_addNewTagHeroChip());

    return tagChips;
  }

  List<Widget> _buildShimmerChips() {
    return List.unmodifiable(() sync* {
      for (String str in _initShimmerChipStrings) {
        yield Shimmer.fromColors(
            baseColor: PrimaryAppTheme.primaryYaleColorSwatch.shade800,
            highlightColor: PrimaryAppTheme.primaryYaleColorSwatch.shade300,
            child: Chip(
              label: Text(str),
            ));
      }
      yield _addNewTagHeroChip();
    }());
  }

  Hero _tagToHeroChip(Tag tag) {
    return Hero(
      tag: TagModalManifest.getChipHeroTagFromTaleTag(tag.title),
      child: Chip(
        backgroundColor: PrimaryAppTheme.primaryYaleColorSwatch.shade800,
        labelPadding: EdgeInsets.only(left: 2),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text("${tag.likedByUsers.length}",
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.white)),
                )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(tag.title,
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Hero _addNewTagHeroChip() {
    return Hero(
        flightShuttleBuilder: (
          BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,
        ) {
          _newChipAnimation?.removeStatusListener(_newChipAnimationListener);
          _newChipAnimation = animation;

          //Manage the visibility of the add tag widget to keep the widget
          // hidden when we're animating and using the add tag modal
          _newChipAnimation.addStatusListener(_newChipAnimationListener);

          if (flightDirection == HeroFlightDirection.push) {
            final Hero toHero = toHeroContext.widget;
            return toHero.child;
          } else {
            //Since the toHero.child is hidden we can't use it to animate as we
            // do in the HeroFlightDirection.push block. Instead we reproduce
            // the widget to display a visible version
            return _addNewTagChip(toHeroContext, false, false);
          }
        },
        tag: TagModalManifest.getNewChipHeroTag,
        //We use a visibility widget so we can hide the add tag widget on the
        // detail page when the add tag modal is open
        child: Visibility(
            //We use an invisible widget so the Hero can still correctly animate
            // to the widget's position
            replacement: Opacity(
              opacity: 0,
              child: _addNewTagChip(context, true, false),
            ),
            visible: _showAddNewTagWidget,
            child: _addNewTagChip(context, true, false)));
  }

  void _newChipAnimationListener(AnimationStatus status) {
    if (AnimationStatus.dismissed == status) {
      setState(() {
        _showAddNewTagWidget = true;
      });
    } else if (AnimationStatus.completed == status) {
      setState(() {
        _showAddNewTagWidget = false;
      });
    }
  }

  Widget _addNewTagChip(
      BuildContext context, bool withAddTag, bool withAddTagAsHero) {
    return Card(
      elevation: 0,
      color: Theme.of(context).primaryColor,
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32))),
      child: InkWell(
        onTap: _addNewTag,
        child: Padding(
          padding: EdgeInsets.all(2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.unmodifiable(() sync* {
              yield Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Text("ADD NEW TAG"),
              );
              if (withAddTag) {
                if (withAddTagAsHero) {
                  yield Hero(
                      tag: TagModalManifest.getNewChipAddIconHeroTag(),
                      child: Icon(Icons.add_circle_outline));
                } else {
                  yield Icon(Icons.add_circle_outline);
                }
              }
            }()),
          ),
        ),
      ),
    );
  }

  void _addNewTag() {
    Navigator.push(
        context,
        HeroModalRoute(
            settings: RouteSettings(
                name: "${TaleDetailPage.routeName}${AddNewTagModal.routeName}"),
            builder: (BuildContext context) {
              return AddNewTagModal(tale: widget.tale);
            }));
  }
}
