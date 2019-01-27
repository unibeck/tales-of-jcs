import 'package:flutter/material.dart';

import 'package:tales_of_jcs/services/tale/tale_service.dart';

class TaleDetailPage extends StatefulWidget {
  TaleDetailPage({Key key, this.title}) : super(key: key);

  final String title;

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
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Text("Test"),
    );
  }
}
