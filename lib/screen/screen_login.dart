import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:octopus_attendance_book/widget/widget_textfield.dart';
import 'package:octopus_attendance_book/widget/widget_wave.dart';
import 'package:simple_animations/simple_animations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xffe4fbff), end: Colors.blueAccent[700])),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xff3edbf0), end: Colors.blue[900])),
    ]);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            ControlledAnimation(
              playback: Playback.MIRROR,
              tween: tween,
              duration: tween.duration,
              builder: (context, animation) {
                return Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [animation["color1"], animation["color2"]])),
                );
              },
            ),
            // 날씨
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedWave(
                height: height * 0.7,
                speed: 1.0,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedWave(
                height: height * 0.55,
                speed: 0.5,
                offset: pi,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedWave(
                height: height * 0.5,
                speed: 0.7,
                offset: pi * 0.2,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding:
                    EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // like_button
                    LoginTextField(
                      hint: 'Email',
                      icon: Icons.account_box_rounded,
                      inputType: TextInputType.emailAddress,
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    LoginTextField(
                      hint: 'Password',
                      icon: Icons.https,
                      inputType: TextInputType.text,
                      hideText: true,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment(0.0, 0.8),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blueAccent[700],
                child: IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.done),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
