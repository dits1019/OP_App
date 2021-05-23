import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:octopus_attendance_book/widget/widget_textfield.dart';
import 'package:octopus_attendance_book/widget/widget_wave.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  dynamic parseWeatherData;

  LoginScreen({this.parseWeatherData});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var url;

  // 온도
  int temp;
  // 날씨
  String detail_weather;
  String iconData;
  // 도시이름
  String cityName;

  @override
  void initState() {
    super.initState();
    updateData(widget.parseWeatherData);
  }

  void updateData(dynamic weatherData) {
    cityName = weatherData['name'];
    temp = weatherData['main']['temp'].round();
    detail_weather = weatherData['weather'][0]['description'];
    iconData = weatherData['weather'][0]['icon'];
  }

  Future<void> urlRequest({@required String email, @required String pw}) async {
    String secretCode =
        DateFormat('yyyyMMdd').format(DateTime.now()).toString() + '박찬휘임준영장인성';

    var nowdate = utf8.encode(secretCode);
    var digest = sha512.convert(nowdate);

    url = Uri.parse('http://222.110.147.50:8000/addLog/$digest');
    print(url);

    const Map<String, String> _header = {'Content-Type': 'application/json'};
    final _body = jsonEncode({'email': email, 'pw': pw});

    try {
      final http.Response response = await http
          .post(url, headers: _header, body: _body)
          .timeout(Duration(seconds: 8),
              onTimeout: () async => new http.Response('false', 404));
      // final _result = json.decode(response.body);
      // final _result = jsonDecode(response.body);
      final _result = utf8.decode(response.bodyBytes);
      // print(_body);
      // print('성공');
      // showToast(jsonDecode(_result)['msg']);
      AlertController.show(
          '알림',
          jsonDecode(_result)['msg'],
          jsonDecode(_result)['result'] == 'success'
              ? TypeAlert.success
              : TypeAlert.error);
      return _result;
    } catch (e) {
      print(e);
      showToast('오류가 발생했습니다');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
  }

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
                alignment: Alignment(0.0, -0.9),
                child: Container(
                  width: width * 0.3,
                  height: height * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Image.network(
                          'https://openweathermap.org/img/w/$iconData.png',
                          fit: BoxFit.cover,
                          width: width * 0.27,
                          height: height * 0.1,
                        ),
                      ),
                      Text(
                        detail_weather,
                        style: TextStyle(fontFamily: 'Yangjin', fontSize: 30),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Text(
                        '${temp.toString()}°C',
                        style: TextStyle(
                            fontFamily: 'Yangjin',
                            fontSize: 25,
                            color: Color(0xfffb3640)),
                      ),
                    ],
                  ),
                )),
            Align(
              alignment: Alignment(0.0, 0.0),
              child: Padding(
                padding:
                    EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // like_button
                    LoginTextField(
                      controller: emailController,
                      hint: 'Email',
                      icon: Icons.account_box_rounded,
                      inputType: TextInputType.emailAddress,
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    LoginTextField(
                      controller: passwordController,
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
                radius: width * 0.08,
                backgroundColor: Colors.blueAccent[700],
                child: IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.done),
                  iconSize: width * 0.08,
                  onPressed: () {
                    if (emailController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      AlertController.show(
                          '알림', 'Email 혹은 Password를 입력해주세요', TypeAlert.error);
                    } else {
                      if (cityName == 'Banpobondong') {
                        urlRequest(
                            email: emailController.text.toString(),
                            pw: passwordController.text.toString());
                      } else {
                        // showToast('불일치');
                        AlertController.show(
                            '알림', '학교 주변에서 다시 앱을 실행해주세요.', TypeAlert.error);
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
