import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';

class MyLocation {
  double latitude2;
  double longitude2;

  Future<void> getMyCurrentLocation() async {
    try {
      //위치의 정확도 정도
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude2 = position.latitude;
      longitude2 = position.longitude;
      print('lat : $latitude2, lon : $longitude2');
    } catch (e) {
      print(e.toString());
    }
  }
}
