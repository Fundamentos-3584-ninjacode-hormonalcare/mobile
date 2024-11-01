import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class AuthService {
  final String baseUrl = 'http://localhost:8080/api/v1';

  Future<Map<String, dynamic>> signUp(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/authentication/sign-up'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'roles': ['ROLE_USER']
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); 
    } else {
      throw Exception('Error in registration');
    }
  }

  Future<String?> signIn(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/authentication/sign-in'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['token'];
      final userId = responseData['id']; // Ensure userId is a string
      final role = responseData['role'];

      // Add logging to diagnose the issue
      print('Response Data: $responseData');
      print('Token: $token');
      print('User ID: $userId');
      print('Role: $role');

      if (token != null && userId != null && role != null) {
        await JwtStorage.saveToken(token);
        await JwtStorage.saveUserId(userId);
        await JwtStorage.saveRole(role);

        // Fetch and save the profile ID
        await fetchAndSaveProfileId(userId, token);

        return token;
      } else {
        throw Exception('Token, User ID, or Role is null');
      }
    } else {
      throw Exception('Error in sign-in');
    }
  }

  Future<void> fetchAndSaveProfileId(int userId, String token) async {
    final profileResponse = await http.get(
      Uri.parse('$baseUrl/profile/profile/userId/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (profileResponse.statusCode == 200) {
      final profileData = json.decode(profileResponse.body);
      final profileId = profileData['id'];

      // Add logging to diagnose the issue
      print('Profile Data: $profileData');
      print('Profile ID: $profileId');

      if (profileId != null) {
        await JwtStorage.saveProfileId(profileId);
      } else {
        throw Exception('Profile ID is null');
      }
    } else {
      throw Exception('Error fetching profile ID');
    }
  }

  Future<int?> getUserId() async {
    return await JwtStorage.getUserId();
  }

  Future<String?> getRole() async {
    return await JwtStorage.getRole();
  }

  Future<void> logout() async {
    await JwtStorage.clearAll();
  }
}