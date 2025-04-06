import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: 'AIzaSyDO9wi97MBfM5lDQTlIAFXRMfgCmUwseVQ',
  );

  final prompt = 'How does planting trees help the environment?';

  try {
    final response = await model.generateContent([Content.text(prompt)]);
    print('✅ Gemini response: ${response.text}');
  } catch (e) {
    print('❌ Gemini API Error: $e');
  }
}
