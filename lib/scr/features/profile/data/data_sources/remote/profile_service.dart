import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class ProfileService {
  final String baseUrl = 'http://localhost:8080/api/v1/profile/profile';

  Future<Map<String, dynamic>> fetchProfileDetails(int profileId) async {
    final token = await JwtStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$profileId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile details');
    }
  }

  static ProfileService fromJson(Map<String, dynamic> json) {
    // Implement the fromJson method based on your JSON structure
    return ProfileService();
  }
}