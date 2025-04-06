import 'package:flutter/material.dart';

class AQIScreen extends StatelessWidget {
  const AQIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int aqi = ModalRoute.of(context)?.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(title: Text('AQI Measure Details Page')),
      body: Center(
        child: Text('Current AQI: $aqi', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
