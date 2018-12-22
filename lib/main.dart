import 'package:flutter/material.dart';

import 'package:tales_of_jcs/home_page/HomePage.dart';
import 'package:tales_of_jcs/utils/PrimaryAppColor.dart';

void main() {
  runApp(TalesOfJCSApp());
}


class TalesOfJCSApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tales of JCS',
      theme: ThemeData(
        primarySwatch: PrimaryAppColor.primary,
      ),
      home: HomePage(title: 'Tales'),
    );
  }
}
