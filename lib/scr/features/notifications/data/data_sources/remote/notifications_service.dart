import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/config/api_config.dart';

class NotificationService {

  Future<List<Map<String, dynamic>>> fetchDoctorAppointments(
      int doctorId) async {
    final token = await JwtStorage.getToken();
    final response = await http.get(
      Uri.parse(
          '${ApiConfig.medicalAppointment}/medicalAppointments/doctor/$doctorId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> appointments = json.decode(response.body);
      return appointments.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<Map<String, dynamic>> fetchPatientProfile(int patientId) async {
    final token = await JwtStorage.getToken();
    final patientResponse = await http.get(
      Uri.parse('${ApiConfig.patient}/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (patientResponse.statusCode == 200) {
      return json.decode(patientResponse.body);
    } else {
      throw Exception('Failed to load patient data');
    }
  }

  Future<void> deleteAppointment(int appointmentId) async {
    final token = await JwtStorage.getToken();
    final response = await http.delete(
      Uri.parse('${ApiConfig.medicalAppointment}/$appointmentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete appointment');
    }
  }
}
