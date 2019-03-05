import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tales_of_jcs/models/tale/tag.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';
import 'package:tales_of_jcs/services/tag/tag_service.dart';
import 'package:tales_of_jcs/tale_detail_page/add_new_tag_modal.dart';
import 'package:tales_of_jcs/tale_detail_page/tag_modal_manifest.dart';
import 'package:tales_of_jcs/tale_detail_page/tale_detail_page.dart';
import 'package:tales_of_jcs/utils/custom_widgets/custom_shimmer.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hero_modal_route.dart';
import 'package:tales_of_jcs/utils/custom_widgets/on_tap_tooltip.dart';
import 'package:tales_of_jcs/utils/primary_app_theme.dart';

class TagDetails extends StatefulWidget {
  TagDetails({Key key, @required this.tale}) : super(key: key);

  Tale tale;

  @override
  _TagDetailsState createState() => _TagDetailsState();
}

class _TagDetailsState extends State<TagDetails> {
  Random random;
  int min;
  int max;

  //View related
  StreamSubscription<DocumentSnapshot> _taleSnapshotSubscription;
  List<Tag> _tags;

  bool _showAddNewTagWidget = true;
  Animation<double> _newChipAnimation;

  List<String> _initShimmerChipStrings = [];

  List<String> _tagChipLikeProcessing = [];

  //Services
  final TagService _tagService = TagService.instance;

  @override
  void initState() {
    super.initState();

    random = Random(widget.tale.title.hashCode);
    min = 12;
    max = 26;

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

  Future<List<Tag>> updateTags(List<DocumentReference> tagsRef) async {
    return Future.wait(tagsRef.map((DocumentReference reference) async {
      DocumentSnapshot snapshot = await reference.get();
      if (snapshot.exists) {
        return Tag.fromSnapshot(snapshot);
      }
    })).then((List<Tag> tags) {
      Timer(Duration(seconds: 1), () async {
        if (mounted) {
          setState(() {
            _tags = List.from(tags);
          });
        }
      });

      return tags;
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
      tagChips =
          _tags.where((Tag tag) => tag?.reference != null).map((Tag tag) {
        return _tagToChip(tag);
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
            baseColor:
                PrimaryAppTheme.primaryColorSwatch(Theme.of(context).brightness)
                    .shade700,
            highlightColor:
                PrimaryAppTheme.primaryColorSwatch(Theme.of(context).brightness)
                    .shade300,
            child: Chip(
              label: Text(str),
            ));
      }
      yield _addNewTagHeroChip();
    }());
  }

  Widget _tagToChip(Tag tag) {
    if (_tagChipLikeProcessing.contains(tag.reference.documentID)) {
      return OnTapTooltip(
        message: "Updating...",
        onLongPress: null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Shimmer.fromColors(
            blendMode: BlendMode.dstATop,
            period: Duration(seconds: 1),
            baseColor:
                PrimaryAppTheme.primaryColorSwatch(Theme.of(context).brightness)
                    .shade700,
            highlightColor:
                PrimaryAppTheme.primaryColorSwatch(Theme.of(context).brightness)
                    .shade300,
            child: Container(
              margin: EdgeInsets.all(2),
              padding: EdgeInsets.fromLTRB(4, 2, 2, 2),
              decoration: BoxDecoration(
                color: PrimaryAppTheme.primaryColorSwatch(
                        Theme.of(context).brightness)
                    .shade700,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _tagChipContent(tag),
            ),
          ),
        ),
      );
    } else {
      return OnTapTooltip(
        message: "Long press to like a tag",
        onLongPress: () => _updateLikeForTag(tag),
        child: Chip(
            backgroundColor:
                PrimaryAppTheme.primaryColorSwatch(Theme.of(context).brightness)
                    .shade700,
            labelPadding: EdgeInsets.only(left: 2),
            label: _tagChipContent(tag)),
      );
    }
  }

  Widget _tagChipContent(Tag tag) {
    return Row(
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
    );
  }

  void _updateLikeForTag(Tag updateTag) async {
    setState(() {
      _tagChipLikeProcessing.add(updateTag.reference.documentID);
    });

    try {
      Future<Map<String, dynamic>> result = _tagService.updateLikeForTag(
          widget.tale.reference, updateTag.reference);

      //Create a future to allow the UI to at least show its animation
      Future<Map<String, dynamic>> prettyUIFuture =
          Future.delayed(Duration(seconds: 2), () => {"": ""});
      List<Map<String, dynamic>> hinderedFuture =
          await Future.wait<Map<String, dynamic>>([result, prettyUIFuture]);

      //Emulate the updateTag method, but without any DB calls since immediate
      // calls are not consistent with the DB (don't know why). Don't need a
      // setState immediately since setState will be called in the finally block
      if (_tags != null) {
        //Index 0 since result is provide first in Future.wait
        List<DocumentReference> newLikedByUsers =
            hinderedFuture[0]["likedByUsers"]?.cast<DocumentReference>();

        if (newLikedByUsers == null || newLikedByUsers.isEmpty) {
          _tags.remove(updateTag);
        } else {
          _tags
              .firstWhere((Tag tag) => tag.reference == updateTag.reference)
              .likedByUsers = newLikedByUsers;
        }
      }
    } catch (error) {
      print("Error: $error");
    } finally {
      setState(() {
        _tagChipLikeProcessing.remove(updateTag.reference.documentID);
      });
    }
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
      color: PrimaryAppTheme.primaryColorSwatch(Theme.of(context).brightness)
          .shade700,
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
                child: Text(
                  "ADD NEW TAG",
                  style: TextStyle(color: Colors.white),
                ),
              );
              if (withAddTag) {
                if (withAddTagAsHero) {
                  yield Hero(
                      tag: TagModalManifest.getNewChipAddIconHeroTag(),
                      child: Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                        ),
                      ));
                } else {
                  yield Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),
                  );
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
