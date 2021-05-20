import 'package:flutter/material.dart';
import 'package:octopus_attendance_book/screen/screen_loading.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoadingScreen());
  }
}
