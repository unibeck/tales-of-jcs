import 'package:flutter/material.dart';
import 'package:tales_of_jcs/models/tale/tale.dart';

import 'package:tales_of_jcs/services/tale/tale_service.dart';
import 'package:tales_of_jcs/utils/custom_widgets/HeroAppBar.dart';

class TaleDetailPage extends StatefulWidget {
  TaleDetailPage({Key key, this.tale}) : super(key: key);

  final Tale tale;

  @override
  _TaleDetailPageState createState() => _TaleDetailPageState();
}

class _TaleDetailPageState extends State<TaleDetailPage> {
  //View related

  //Services
  final TaleService _taleService = TaleService.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeroAppBar(
        title: Text("${widget.tale.title}",
            style: Theme.of(context).textTheme.title.copyWith(color: Colors.white)),
        appBarTag: "${widget.tale.reference.documentID}_background",
        appBarTitleTag: "${widget.tale.reference.documentID}_title",
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(color: Theme.of(context).primaryColorDark),
        ],
      ),
    );
  }
}

class TaleDetailPageRoute<T> extends MaterialPageRoute<T> {
  TaleDetailPageRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.isInitialRoute) return child;

    return FadeTransition(opacity: animation, child: child);
  }
}
