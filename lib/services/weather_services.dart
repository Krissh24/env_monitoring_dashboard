import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class WeatherServices {
  final apiKey =
      kIsWeb
          ? '84c162457b3959a93f5dde5869d1414f'
          : dotenv.env['OPENWEATHER_API_KEY'] ?? 'fallback';
  Future<Map<dynamic, dynamic>?> fetchAQI(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Failed to fetch AQI data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<Map<dynamic, dynamic>?> fetchWeather(
    BuildContext context,
    city,
  ) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var weatherData = json.decode(response.body);
        double lat = weatherData["coord"]["lat"];
        double lon = weatherData["coord"]["lon"];

        var aqiData = await fetchAQI(lat, lon);
        weatherData["aqi"] = aqiData?["list"][0]["main"]["aqi"];

        return weatherData;
      } else if (response.statusCode == 404) {
        showError(context, "City not found! Please enter a valid city name.");
      } else if (response.statusCode == 401) {
        showError(context, "Invalid API Key! Check your OpenWeather API key.");
      } else {
        showError(context, "Something went wrong! Please try again.");
      }
    } catch (e) {
      showError(context, "No Internet Connection! Please check your network.");
    }
    return null;
  }

  void showError(BuildContext context, message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
