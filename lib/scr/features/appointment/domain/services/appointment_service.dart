import 'dart:convert';
import 'package:http/http.dart' as http;

class AppointmentService {
  final String baseUrl = 'http://localhost:8080/api/v1/medicalAppointment';

  Future<bool> createAppointment(Map<String, dynamic> appointmentData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(appointmentData),
    );

    if (response.statusCode == 201) {
      return true; // Cita creada exitosamente
    } else {
      throw Exception('Error creating appointment');
    }
  }
}