import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:octopus_attendance_book/screen/screen_loading.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
        title: 'OP_App',
        debugShowCheckedModeBanner: false,
        builder: (context, child) => Stack(
              children: [child, DropdownAlert()],
            ),
        theme: ThemeData(
            primaryColor: const Color(0xffe4fbff), fontFamily: 'Yangjin'),
        home: LoadingScreen());
  }
}
