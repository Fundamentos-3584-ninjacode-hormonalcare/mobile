import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import '../patient_model.dart';
import '../profile_model.dart';

class PatientsListService {
  final String baseUrl = 'http://localhost:8080/api/v1/medical-record/patient';
  final String profileBaseUrl = 'http://localhost:8080/api/v1/profile/profile';

  Future<List<Patient>> getPatients() async {
    final token = await JwtStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    List<Patient> patients = [];
    for (int id = 1; id <= 2; id++) {
      final response = await http.get(Uri.parse('$baseUrl/$id'), headers: headers);
      if (response.statusCode == 200) {
        final patientData = json.decode(response.body);
        final profileId = patientData['profileId'];
        
        final profileResponse = await http.get(Uri.parse('$profileBaseUrl/$profileId'), headers: headers);
        if (profileResponse.statusCode == 200) {
          final profileData = json.decode(profileResponse.body);
          final patient = Patient.fromJson(patientData);
          patient.profile = Profile.fromJson(profileData);
          patients.add(patient);
        } else {
          throw Exception('Error fetching profile with id $profileId');
        }
      } else {
        throw Exception('Error fetching patient with id $id');
      }
    }
    return patients;
  }
}
