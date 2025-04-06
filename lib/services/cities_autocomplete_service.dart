import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CityAutocompleteService {
  final apiKey =
      kIsWeb
          ? '84c162457b3959a93f5dde5869d1414f'
          : dotenv.env['AUTOCOMPLETE_API_KEY'];

  Future<List<String>> fetchSuggestions(String query) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<String>((item) => item['name'].toString()).toList();
    } else {
      print('Failed to fetch suggestions');
      return [];
    }
  }
}
