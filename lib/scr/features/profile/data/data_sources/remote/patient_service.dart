import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/config/api_config.dart';

class PatientService {

  Future<Map<String, dynamic>> fetchPatientDetails(int patientId) async {
    final token = await JwtStorage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.patient}/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load patient details');
    }
  }

  static PatientService fromJson(Map<String, dynamic> json) {
    return PatientService();
  }
}
