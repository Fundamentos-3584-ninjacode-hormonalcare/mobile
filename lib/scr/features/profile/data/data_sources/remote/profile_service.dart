import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class ProfileService {
  final String baseUrl = 'https://hormonal-care-backend-production.up.railway.app/api/v1';

  Future<Map<String, dynamic>> fetchProfileDetails(int userId) async {
    final token = await JwtStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/profile/profile/userId/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile details');
    }
  }

  Future<Map<String, dynamic>> fetchDoctorProfessionalDetails(int profileId) async {
    final token = await JwtStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/doctor/doctor/profile/$profileId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load doctor professional details');
    }
  }
}