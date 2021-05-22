import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus_attendance_book/data/my_location.dart';
import 'package:octopus_attendance_book/data/network.dart';
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
    getLocation();
  }

  void getLocation() async {
    MyLocation myLocation = MyLocation();
    await myLocation.getMyCurrentLocation();
    latitude3 = myLocation.latitude2;
    longitude3 = myLocation.longitude2;
    // print('$latitude3, $longitude3');

    Network network = Network(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude3&lon=$longitude3&appid=$apikey&units=metric&lang=kr');

    var weatherData = await network.getJsonData();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) =>
              LoginScreen(parseWeatherData: weatherData)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
      body: Center(
        child: Container(
          child: Image.asset('images/logo.png'),
        ),
      ),
    );
  }
}
