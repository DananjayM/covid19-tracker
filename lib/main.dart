import 'package:covid_api/app/services/api.dart';
import 'package:covid_api/app/services/api_service.dart';
import 'package:flutter/material.dart';

import 'Screens/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: Home(),
    );
  }
}
