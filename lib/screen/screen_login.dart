import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:octopus_attendance_book/data/network.dart';
import 'package:octopus_attendance_book/method/get_data.dart';
import 'package:octopus_attendance_book/method/show_toast.dart';
import 'package:octopus_attendance_book/widget/widget_textfield.dart';
import 'package:octopus_attendance_book/widget/widget_wave.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  dynamic parseWeatherData;
  dynamic parseStudents;

  LoginScreen({this.parseWeatherData, this.parseStudents});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    var weatherData = await getWeatherData();
    updateData(weatherData);

    _refreshController.refreshCompleted();
  }

  // 온도
  int temp;
  // 날씨
  String detail_weather;
  String iconData;
  // 도시이름
  String cityName;
  // phone Number
  var phone;

  // 온라인 수업 확인
  bool online_flag;
  // 계정에 핸드폰 번호와 비밀번호가 있는 지 확인하고 없을 경우 추가
  String phoneisNull;
  String pwisNull;
  // 핸드폰 번호와 비밀번호가 있는 지 체크
  String pwphisNull;

  // 자동 완성을 위한 리스트
  List<String> studentsList = [];

  // 캐싱을 위한 선언
  String _email = '';
  String _pw = '';
  var _pwCrypto;
  SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    // 날씨 데이터 가져오기
    updateData(widget.parseWeatherData);
    // 학생 데이터 가져오기
    getStudents(widget.parseStudents);
    // 권한 확인
    MobileNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        getPhoneNumber();
      }
    });
    getPhoneNumber();
    _loadCaching();
  }

  // 날씨 데이터를 가져와서 변수 안에 넣기
  void updateData(dynamic weatherData) {
    cityName = weatherData['name'];
    temp = weatherData['main']['temp'].round();
    detail_weather = weatherData['weather'][0]['description'];
    iconData = weatherData['weather'][0]['icon'];
  }

  // 학생 데이터를 학생 리스트에 넣기
  void getStudents(dynamic studentsData) {
    studentsData.forEach((student) => studentsList.add(student['email']));
  }

  // 온라인 수업인지 체크
  Future<void> checkOnline({@required String email}) async {
    var url = Uri.parse('http://222.110.147.50:8000/checkOnline');

    const Map<String, String> _header = {'Content-Type': 'application/json'};

    final _body = jsonEncode({'email': email});

    try {
      final http.Response response = await http
          .post(url, headers: _header, body: _body)
          .timeout(Duration(seconds: 8),
              onTimeout: () async => new http.Response('false', 404));

      final _result = response.body;
      online_flag = await jsonDecode(_result)['online_flag'];
      phoneisNull = jsonDecode(_result)['phone'];
      pwisNull = jsonDecode(_result)['pw'];

      if (phoneisNull == '' || pwisNull == '') {
        pwphisNull = 'True';

        CoolAlert.show(
            context: context,
            type: CoolAlertType.confirm,
            title: '',
            text: '사용자 계정에 현재 패스워드와 \n핸드폰 번호를 등록하시겠습니까?',
            confirmBtnText: '확인',
            onConfirmBtnTap: () {
              if (online_flag) {
                urlRequest(
                    email: emailController.text.toString(),
                    pw: passwordController.text.toString());
              } else {
                if (cityName == 'Banpobondong' || cityName == 'Yongsan') {
                  urlRequest(
                      email: emailController.text.toString(),
                      pw: passwordController.text.toString());
                } else {
                  AlertController.show(
                      '알림', '학교에서 다시 앱을 실행해주세요.', TypeAlert.error);
                }
              }
              Navigator.pop(context);
              return _result;
            },
            cancelBtnText: '취소',
            onCancelBtnTap: () {
              Navigator.pop(context);
              return false;
            });
      } else {
        pwphisNull = 'False';
      }
      return _result;
    } catch (e) {
      print(e);
    }
  }

  // 데이터를 서버로 보내기
  Future<void> urlRequest({@required String email, @required String pw}) async {
    String secretCode =
        DateFormat('yyyyMMdd').format(DateTime.now()).toString() + '박찬휘임준영장인성';

    var nowdate = utf8.encode(secretCode);
    var digest = sha512.convert(nowdate);
    var url = Uri.parse('http://222.110.147.50:8000/addLog/$digest');
    print(url);
    const Map<String, String> _header = {'Content-Type': 'application/json'};
    final _body = jsonEncode({
      'email': email,
      'pw': pw,
      'phone': phone,
      'isNull': pwphisNull
    }); // phone
    try {
      final http.Response response = await http
          .post(url, headers: _header, body: _body)
          .timeout(Duration(seconds: 8),
              onTimeout: () async => new http.Response('false', 404));

      final _result = utf8.decode(response.bodyBytes);

      if (jsonDecode(_result)['result'] == 'already') {
        AlertController.show(
            '알림',
            '${jsonDecode(_result)['msg']}\n이미 ${jsonDecode(_result)['time']}에 출석했습니다',
            TypeAlert.warning);
      } else {
        AlertController.show(
            '알림',
            jsonDecode(_result)['msg'],
            jsonDecode(_result)['result'] == 'success'
                ? TypeAlert.success
                : TypeAlert.error);
      }
      return _result;
    } catch (e) {
      print(e);
      showToast('오류가 발생했습니다');
    }
  }

  // 핸드폰 번호 가져오기
  Future<void> getPhoneNumber() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    try {
      phone = await MobileNumber.mobileNumber;
      phone = phone.toString().substring(2, 13);
    } catch (e) {
      print(e);
    }
  }

  // 캐시에 있는 데이터를 불러옴
  _loadCaching() async {
    // 캐시에 저장되어있는 값을 불러옴
    _prefs = await SharedPreferences.getInstance();
    // 캐시에 저장된 값을 반영하여 현재 상태 설정
    setState(() {
      // null일 경우 공백으로
      // 키값으로 가져오기
      _email = (_prefs.getString('email') ?? '');
      _pw = (_prefs.getString('pw') ?? '');
      emailController.text = _email;
      passwordController.text = _pw;
      print('저장된 이메일 : $_email');
      print('저장된 비밀번호 : $_pw');
    });
  }

  // 캐시에 데이터를 넣어줌
  _uploadCaching() {
    _pwCrypto = utf8.encode(passwordController.text.toString());
    _email = emailController.text.toString();
    _pw = passwordController.text.toString();
    // 키와 값을 캐시에 넣어줌
    _prefs.setString('email', _email);
    _prefs.setString('pw', _pwCrypto);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    // color1과 color2라는 이름으로 두 개의 트랙을 정의
    // 미러링된 애니메이션 사용
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xffe4fbff), end: Colors.blueAccent[700])),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xff3edbf0), end: Colors.blue[900])),
    ]);

    return SafeArea(
      child: Scaffold(
        body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropMaterialHeader(backgroundColor: Colors.black),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: Stack(
            children: [
              // 배경 애니메이션
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
                      colors: [animation["color1"], animation["color2"]],
                    )),
                  );
                },
              ),

              // 아래쪽으로 파도 붙이기
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
                    width: width * 0.4,
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
                        AutoSizeText(
                          detail_weather,
                          maxLines: 2,
                          minFontSize: 27,
                          maxFontSize: 30,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        Text(
                          '${temp.toString()}°C',
                          style:
                              TextStyle(fontSize: 25, color: Color(0xfffb3640)),
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
                      // 자동완성이 되는 email 입력칸
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(width * 0.01),
                        ),
                        child: AutoCompleteTextField(
                          suggestions: studentsList,
                          itemFilter: (item, query) {
                            return item
                                .toLowerCase()
                                .startsWith(query.toLowerCase());
                          },
                          itemSorter: (a, b) {
                            return a.compareTo(b);
                          },
                          itemSubmitted: (item) {
                            emailController.text = item;
                          },
                          itemBuilder: (context, item) {
                            return Container(
                              padding: EdgeInsets.all(width * 0.05),
                              child: Row(
                                children: [Text(item)],
                              ),
                            );
                          },
                          clearOnSubmit: false,
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          style: TextStyle(fontSize: 17),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(fontSize: 17),
                            hintText: 'Email',
                            suffixIcon: Icon(
                              Icons.account_box_rounded,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(width * 0.03),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      // 비밀번호 입력칸
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
              // 체크 버튼
              Align(
                alignment: Alignment(0.0, 0.8),
                child: CircleAvatar(
                  radius: width * 0.08,
                  backgroundColor: Colors.blueAccent[700],
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.done),
                    iconSize: width * 0.08,
                    onPressed: () async {
                      // TextField가 비어있는지 확인
                      if (emailController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        AlertController.show(
                            '알림', 'Email 혹은 Password를 입력해주세요', TypeAlert.error);
                      } else {
                        await checkOnline(
                            email: emailController.text.toString());
                        // 비밀번호와 핸드폰 번호가 학생에게 있는지 확인
                        if (pwphisNull == 'False') {
                          // 온라인 수업인지 확인
                          if (online_flag) {
                            urlRequest(
                                email: emailController.text.toString(),
                                pw: passwordController.text.toString());
                          } else {
                            if (cityName == 'Yongsan' ||
                                cityName == 'Banpobondong') {
                              urlRequest(
                                  email: emailController.text.toString(),
                                  pw: passwordController.text.toString());
                            } else {
                              AlertController.show(
                                  '알림', '학교에서 다시 앱을 실행해주세요.', TypeAlert.error);
                            }
                          }
                        }
                      }
                      _uploadCaching();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
