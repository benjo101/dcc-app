// lib/services/food_api.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

class FoodApi {
  final String baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  String get _apiKey {
    final key = dotenv.env['USDA_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('USDA_API_KEY saknas i .env');
    }
    return key;
  }

  /// Sök livsmedel. Returnerar en lista av FoodItem (från v1/foods/search).
  Future<List<FoodItem>> searchFoods(String query, {int pageSize = 25}) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.parse('$baseUrl/foods/search').replace(queryParameters: {
      'api_key': _apiKey,
      'query': query,
      'pageSize': '$pageSize',
      // Du kan även lägga till: 'dataType': 'Branded,Survey (FNDDS),SR Legacy'
    });

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Sökning misslyckades (${res.statusCode}): ${res.body}');
    }

    final map = json.decode(res.body) as Map<String, dynamic>;
    final foods = (map['foods'] as List?) ?? [];
    return foods
        .where((e) => e is Map<String, dynamic> && e['fdcId'] != null)
        .map<FoodItem>(
            (e) => FoodItem.fromFoodDataCentralSearchJson(e as Map<String, dynamic>))
        .toList();
  }
}
