import 'package:application/router.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return MaterialApp.router(
        title: 'ZonéO',
        theme: ThemeData(
            fontFamily: 'Roboto-Bold'),
      );
  }
}
