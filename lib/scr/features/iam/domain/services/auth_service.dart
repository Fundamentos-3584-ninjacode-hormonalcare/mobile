import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class AuthService {
  final String baseUrl = 'https://hormonal-care-backend-production.up.railway.app/api/v1/authentication';

  Future<Map<String, dynamic>> signUp(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sign-up'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'roles': ['ROLE_USER']
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); // Maneja la respuesta de registro.
    } else {
      throw Exception('Error in registration');
    }
  }

  Future<String?> signIn(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sign-in'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['token'];
      await JwtStorage.saveToken(token);
      return token;
    } else {
      throw Exception('Error in sign-in');
    }
  }

  Future<void> logout() async {
    await JwtStorage.removeToken();
  }
}
