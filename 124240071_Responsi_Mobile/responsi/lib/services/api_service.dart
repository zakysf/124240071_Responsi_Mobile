import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://kitsu.io/api/edge/anime';

  static Future<List<dynamic>> getAnimeList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/?page[limit]=20&page[offset]=0'),
      headers: {'Accept': 'application/vnd.api+json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load anime list');
    }
  }

  static Future<Map<String, dynamic>> getAnimeDetail(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Accept': 'application/vnd.api+json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load anime detail');
    }
  }
}
