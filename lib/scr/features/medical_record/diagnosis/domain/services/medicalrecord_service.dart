import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import '../../../medical_prescription/domain/models/patient_model.dart';
import '../../../medical_prescription/domain/models/profile_model.dart';
import '../../domain/models/medication_model.dart';
import '../../domain/models/prescription_model.dart';
import '../../domain/models/treatment_model.dart'; // Importa el modelo de tratamiento

class MedicalRecordService {
  final String baseUrl = 'https://hormonal-care-backend-production.up.railway.app/api/v1/medical-record/patient/record';
  final String profileBaseUrl = 'https://hormonal-care-backend-production.up.railway.app/api/v1/profile/profile';
  final String medicationsUrl = 'https://hormonal-care-backend-production.up.railway.app/api/v1/medical-record/medications';
  final String prescriptionsUrl = 'https://hormonal-care-backend-production.up.railway.app/api/v1/medical-record/medications/prescriptions';
  final String treatmentsUrl = 'https://hormonal-care-backend-production.up.railway.app/api/v1/medical-record/treatments/medicalRecordId'; // URL base para tratamientos

  Future<Patient> getPatientById(String patientId) async {
    final token = await JwtStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse('$baseUrl/$patientId'), headers: headers);
    if (response.statusCode == 200) {
      final patientData = json.decode(response.body);
      final profileId = patientData['profileId'];

      final profileResponse = await http.get(Uri.parse('$profileBaseUrl/$profileId'), headers: headers);
      if (profileResponse.statusCode == 200) {
        final profileData = json.decode(profileResponse.body);
        final patient = Patient.fromJson(patientData);
        patient.profile = Profile.fromJson(profileData);

        return patient;
      } else {
        throw Exception('Error fetching profile with id $profileId');
      }
    } else {
      throw Exception('Error fetching patient with id $patientId');
    }
  }

  Future<List<Medication>> getMedicationsByRecordId(int medicalRecordId) async {
    final token = await JwtStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(medicationsUrl), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> medicationsJson = json.decode(response.body);
      return medicationsJson
          .map((json) => Medication.fromJson(json))
          .where((medication) => medication.medicalRecordId == medicalRecordId)
          .toList();
    } else {
      print('Error fetching medications: ${response.body}');
      throw Exception('Error fetching medications');
    }
  }

  Future<List<Prescription>> getPrescriptions() async {
    final token = await JwtStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(prescriptionsUrl), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> prescriptionsJson = json.decode(response.body);
      return prescriptionsJson.map((json) => Prescription.fromJson(json)).toList();
    } else {
      print('Error fetching prescriptions: ${response.body}');
      throw Exception('Error fetching prescriptions');
    }
  }

  Future<List<Treatment>> getTreatmentsByRecordId(int medicalRecordId) async {
    final token = await JwtStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse('$treatmentsUrl/$medicalRecordId'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> treatmentsJson = json.decode(response.body);
      return treatmentsJson.map((json) => Treatment.fromJson(json)).toList();
    } else {
      print('Error fetching treatments: ${response.body}');
      throw Exception('Error fetching treatments');
    }
  }
}