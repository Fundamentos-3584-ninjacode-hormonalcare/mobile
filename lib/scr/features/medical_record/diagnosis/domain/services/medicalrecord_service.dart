import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/config/api_config.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import '../../../medical_prescription/domain/models/patient_model.dart';
import '../../domain/models/medication_model.dart';
import '../../domain/models/prescription_model.dart';
import '../../domain/models/treatment_model.dart'; // Importa el modelo de tratamiento
import '../../domain/models/medicationpost_model.dart'; // Importa el modelo de MedicationPost
import '../../domain/models/prescriptionpost_model.dart';
import '../../domain/models/medicaltype_model.dart';

class MedicalRecordService {
  //final String baseUrl = 'http://localhost:8080/api/v1/patient/record';
  //final String medicationsUrl = 'http://localhost:8080/api/v1/medical-record/medications';
  //final String prescriptionsUrl = 'http://localhost:8080/api/v1/medical-record/medications/prescriptions';
  //final String treatmentsUrl = 'http://localhost:8080/api/v1/medical-record/treatments/medicalRecordId'; // URL base para tratamientos
  //final String treatmentspostUrl = 'http://localhost:8080/api/v1/medical-record/treatments'; // URL base para tratamientos
  //final String medicaltypesUrl = 'http://localhost:8080/api/v1/medical-record/medications/medicationTypes';

  Future<Map<String, String>> _makeHeaders() async {
    final token = await JwtStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Patient> getPatientById(String patientId) async {
    final headers = await _makeHeaders();
    // patientId is the same as medical record id
    final response = await http.get(Uri.parse('${ApiConfig.patient}/$patientId'), headers: headers);
    if (response.statusCode == 200) {
      final patientData = json.decode(response.body);
      return Patient.fromJson(patientData);
    } else {
      throw Exception('Error fetching patient with id $patientId');
    }
  }

  Future<List<Medication>> getMedicationsByRecordId(int medicalRecordId) async {
    final headers = await _makeHeaders();
    final response = await http.get(Uri.parse(ApiConfig.medicalRecordMedications), headers: headers);
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

  Future<List<Prescription>> getPrescriptionsByRecordId(int medicalRecordId) async {
    final headers = await _makeHeaders();
    final response = await http.get(Uri.parse(ApiConfig.medicalRecordPrescriptions), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> prescriptionsJson = json.decode(response.body);
      return prescriptionsJson
          .map((json) => Prescription.fromJson(json))
          .where((prescription) => prescription.medicalRecordId == medicalRecordId)
          .toList();
    } else {
      print('Error fetching prescriptions: ${response.body}');
      throw Exception('Error fetching prescriptions');
    }
  }

  Future<List<Treatment>> getTreatmentsByRecordId(int medicalRecordId) async {
    final headers = await _makeHeaders();
    final response = await http.get(Uri.parse('${ApiConfig.medicalRecordTreatmentsByRecord}/$medicalRecordId'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> treatmentsJson = json.decode(response.body);
      return treatmentsJson.map((json) => Treatment.fromJson(json)).toList();
    } else {
      print('Error fetching treatments: ${response.body}');
      throw Exception('Error fetching treatments');
    }
    
  }

  Future<http.Response> addMedication(MedicationPost medicationPost) async {
    final headers = await _makeHeaders();
    final response = await http.post(
      Uri.parse(ApiConfig.medicalRecordMedications),
      headers: headers,
      body: json.encode(medicationPost.toJson()),
    );

    return response;
  }

  Future<http.Response> addPrescription(PrescriptionPost prescriptionPost) async {
    final headers = await _makeHeaders();
    final response = await http.post(
      Uri.parse(ApiConfig.medicalRecordPrescriptions),
      headers: headers,
      body: json.encode(prescriptionPost.toJson()),
    );

    return response;
  }
  
  Future<http.Response> addTreatment(Treatment treatment) async {
    final headers = await _makeHeaders();
    //print('Tokenzzz: $token'); // Agrega este log para verificar el token

    final response = await http.post(
      Uri.parse(ApiConfig.medicalRecordTreatments),
      headers: headers,
      body: json.encode(treatment.toJson()),
    );

    return response;
  }

  Future<List<MedicalType>> fetchMedicalTypes() async {
    final headers = await _makeHeaders();
    final response = await http.get(Uri.parse(ApiConfig.medicalRecordMedicationTypes), headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => MedicalType.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load medical types');
    }
  }
}

