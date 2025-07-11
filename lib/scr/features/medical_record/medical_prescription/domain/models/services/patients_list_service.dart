import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/config/api_config.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/auth_service.dart';
import '../patient_model.dart';

class PatientsListService {
  final http.Client client;

  PatientsListService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Patient>> getPatients(int doctorId) async {
    final token = await JwtStorage.getToken();
    final uri = Uri.parse('${ApiConfig.patient}/doctor/$doctorId');
    // Logs para depuración
    print('GET $uri');

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('${response.statusCode}: ${response.body}');

    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        throw Exception(
          'No hay pacientes registrados para este doctor',
        );
      }
      throw Exception(
        'Error fetching patients for doctor id $doctorId (HTTP ${response.statusCode})',
      );
    }

    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((e) => Patient.fromJson(e)).toList();
  }
}
