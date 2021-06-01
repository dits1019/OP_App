import 'package:octopus_attendance_book/data/my_location.dart';
import 'package:octopus_attendance_book/data/network.dart';

Future<dynamic> getWeatherData() async {
  MyLocation myLocation = MyLocation();
  const apikey = '718fc9176c8b844ffce641eaafc01955';

  await myLocation.getMyCurrentLocation();
  double latitude3 = myLocation.latitude2;
  double longitude3 = myLocation.longitude2;

  Network weatherNetwork = Network(
      'https://api.openweathermap.org/data/2.5/weather?lat=$latitude3&lon=$longitude3&appid=$apikey&units=metric&lang=kr');

  var weatherData = await weatherNetwork.getJsonData();
  return weatherData;
}

Future<dynamic> getStudentsData() async {
  Network studentsNetwork = Network('http://222.110.147.50:8000/getStudent');

  var studentsData = await studentsNetwork.getJsonData();

  return studentsData;
}
