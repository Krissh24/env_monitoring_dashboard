import 'package:flutter/material.dart';
import '../services/weather_services.dart';
import '../services/cities_autocomplete_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  final WeatherServices weatherServices = WeatherServices();
  final CityAutocompleteService cityService = CityAutocompleteService();

  final TextEditingController cityController = TextEditingController();

  String? temperature;
  String? description;
  String? humidity;
  String? windSpeed;
  String? pressure;
  String? aqi;

  String? weatherCondition = 'default';

  void getWeather() async {
    var weatherData = await weatherServices.fetchWeather(
      context,
      cityController.text,
    );
    if (weatherData != null) {
      setState(() {
        temperature = "${weatherData['main']['temp']}°C";
        description = weatherData['weather'][0]['description'];
        humidity = "${weatherData['main']['humidity']}%";
        windSpeed = "${weatherData['wind']['speed']}m/s";
        pressure = "${weatherData['main']['pressure']}hPa";
        aqi = "${weatherData['aqi']}";
        weatherCondition = _getCondition(description ?? '');
      });
    }
  }

  String _getCondition(String desc) {
    final lower = desc.toLowerCase();
    if (lower.contains('rain')) return 'rainy';
    if (lower.contains('cloud')) return 'cloudy';
    if (lower.contains('sun') || lower.contains('clear')) return 'sunny';
    return 'default';
  }

  AssetImage _getBackgroundImage() {
    switch (weatherCondition) {
      case 'sunny':
        return const AssetImage('assets/backgrounds/sunny.jpg');
      case 'rainy':
        return const AssetImage('assets/backgrounds/rainy.jpg');
      case 'cloudy':
        return const AssetImage('assets/backgrounds/cloudy.jpg');
      default:
        return const AssetImage('assets/backgrounds/default.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _getBackgroundImage(),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "🌍 Live Weather",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      final results = await cityService.fetchSuggestions(
                        textEditingValue.text,
                      );
                      return results;
                    },
                    onSelected: (String selection) {
                      cityController.text = selection;
                    },
                    fieldViewBuilder: (
                      context,
                      controller,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Enter Your City",
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSubmitted: (_) => getWeather(),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: getWeather,
                    icon: Icon(Icons.wb_sunny),
                    label: Text("Get Live Weather Now!"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      textStyle: TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (temperature != null)
                    _infoCard("🌡 Temperature", temperature!),
                  if (description != null)
                    _infoCard("🌤 Weather", description!),
                  if (humidity != null) _infoCard("💧 Humidity", humidity!),
                  if (windSpeed != null) _infoCard("🌬 Wind Speed", windSpeed!),
                  if (pressure != null) _infoCard("📊 Pressure", pressure!),
                  if (aqi != null)
                    _infoCard(
                      "🌫 Air Quality Index",
                      aqi!,
                      color: getAQIColor(int.tryParse(aqi ?? '0')),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value, {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          "$label: $value",
          style: TextStyle(
            fontSize: 18,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color getAQIColor(int? aqi) {
    if (aqi == 1) return Colors.green;
    if (aqi == 2) return Colors.yellow;
    if (aqi == 3) return Colors.orange;
    if (aqi == 4) return Colors.red;
    return Colors.purple;
  }
}
