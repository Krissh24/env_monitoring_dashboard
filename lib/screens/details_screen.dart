import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String details = ModalRoute.of(context)?.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(title: Text('Details Screen')),
      body: Center(
        child: Text(
          'Current details of Climate: $details',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
