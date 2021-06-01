import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus_attendance_book/method/get_data.dart';
import 'package:octopus_attendance_book/screen/screen_login.dart';

const apikey = '718fc9176c8b844ffce641eaafc01955';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double latitude3;
  double longitude3;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    var weatherData = await getWeatherData();
    var studentsData = await getStudentsData();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => LoginScreen(
                parseWeatherData: weatherData,
                parseStudents: studentsData,
              )),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
      body: Center(
        child: Container(
          child: Image.asset('images/intro'),
        ),
      ),
    );
  }
}
