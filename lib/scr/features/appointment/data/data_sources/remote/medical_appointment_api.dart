import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/domain/models/patient_model.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class MedicalAppointmentApi {
  static const String _baseUrl = 'http://localhost:8080/api/v1';

  Future<String?> _getToken() async {
    return await JwtStorage.getToken();
  }

  Future<String?> _getUserId() async {
    return await JwtStorage.getUserId();
  }

  Future<ProfileModel?> getProfile(int profileId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/profile/profile/$profileId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return ProfileModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<PatientModel?> getPatient(int patientId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/medical-record/patient/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return PatientModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> createMedicalAppointment(Map<String, dynamic> appointmentData) async {
    final token = await _getToken();
    final userId = await _getUserId();
    appointmentData['userId'] = userId; // Add userId to the appointment data

    final response = await http.post(
      Uri.parse('$_baseUrl/medicalAppointment'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(appointmentData),
    );

    return response.statusCode == 201;
  }
}



