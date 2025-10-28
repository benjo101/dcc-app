// lib/services/food_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

/// Open Food Facts API (ingen nyckel behövs)
/// Stöd för staging (off:off) och svenska produkter.
class FoodApi {
  String get _env => (dotenv.env['OPENFOODFACTS_ENV'] ?? 'prod').toLowerCase();
  bool get _isStaging => _env == 'staging' || _env == 'dev';

  String? get _country {
    final v = dotenv.env['OFF_COUNTRY']?.trim();
    if (v == null || v.isEmpty) return null;
    return v;
  }

  String get _baseHost => _isStaging
      ? 'https://world.openfoodfacts.net'
      : 'https://world.openfoodfacts.org';

  Map<String, String> get _headers {
    if (_isStaging) {
      final auth = base64Encode(utf8.encode('off:off'));
      return {
        HttpHeaders.authorizationHeader: 'Basic $auth',
        HttpHeaders.acceptHeader: 'application/json',
      };
    }
    return {HttpHeaders.acceptHeader: 'application/json'};
  }

  /// 🔹 Fulltext-sökning med v1-endpoint (fungerar med delord som "estre")
  Future<List<FoodItem>> searchFoods(String query, {int pageSize = 25}) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final params = <String, String>{
      'search_terms': q,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': '$pageSize',
      'fields': [
        'product_name',
        'brands',
        'nutriments',
        'image_front_small_url',
        'image_front_url',
        'serving_size',
        'countries_tags'
      ].join(','),
      'nocache': '1',
    };

    // Filtrera till Sverige om OFF_COUNTRY=sweden
    if (_country != null && _country!.isNotEmpty) {
      params.addAll({
        'tagtype_0': 'countries',
        'tag_contains_0': 'contains',
        'tag_0': _country!,
      });
    }

    final uri =
        Uri.parse('$_baseHost/cgi/search.pl').replace(queryParameters: params);

    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('OpenFoodFacts error ${res.statusCode}: ${res.body}');
    }

    final data = json.decode(res.body) as Map<String, dynamic>;
    final products = (data['products'] as List?) ?? const [];

    final out = <FoodItem>[];
    for (final raw in products) {
      if (raw is Map<String, dynamic>) {
        try {
          out.add(FoodItem.fromOpenFoodFactsProduct(raw));
        } catch (_) {
          // hoppa över trasiga poster
        }
      }
    }
    return out;
  }

  /// 🔹 Autocomplete för varumärken (t.ex. "estre" → "Estrella")
  Future<List<String>> suggestBrands(String term, {int limit = 10}) async {
    final q = term.trim();
    if (q.isEmpty) return [];

    final lc = (dotenv.env['OFF_LANGUAGE'] ?? 'sv').toLowerCase();
    final uri = Uri.parse('$_baseHost/cgi/suggest.pl').replace(queryParameters: {
      'tagtype': 'brands',
      'term': q,
      'lc': lc,
    });

    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) {
      return [];
    }

    final data = json.decode(res.body);
    if (data is List) {
      final out = data
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (out.length > limit) return out.sublist(0, limit);
      return out;
    }
    return [];
  }
}
