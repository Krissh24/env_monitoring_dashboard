import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final _apiKey = dotenv.env['GEMINI_API_KEY'];
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'models/gemini-1.5-pro-002',
      apiKey: _apiKey!,
    );
  }

  Future<String> getEcoImpact(String challengeSummary) async {
    final prompt =
        "A user completed this eco-challenge: $challengeSummary. "
        "Respond with a short, motivational, and friendly sentence about how this helps the environment.";

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "You did something amazing for the planet!";
    } catch (e) {
      print("Gemini API Error: $e");
      return "Great job! (We couldn’t fetch detailed impact info right now)";
    }
  }

  Future<String> getResponse(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "No response from Gemini.";
    } catch (e) {
      print("Gemini Error: $e");
      return "Something went wrong.";
    }
  }
}
