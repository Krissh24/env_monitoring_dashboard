import 'package:flutter/material.dart';

class EnvironmentalData extends ChangeNotifier {
  int temperature = 25;

  int get Temperature => temperature;

  void updateTemperature(int newTemp) {
    temperature = newTemp;
    notifyListeners();
  }
}
