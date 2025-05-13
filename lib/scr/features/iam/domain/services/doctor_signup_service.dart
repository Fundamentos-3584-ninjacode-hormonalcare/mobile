import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class DoctorSignUpService {
  static final String baseUrl = 'http://10.0.2.2:8080/api/v1';

  static Future<Map<String, dynamic>> createDoctorProfile(
    String firstName,
    String lastName,
    String gender,
    String phoneNumber,
    String birthday,
    int userId,
    int professionalIdentificationNumber,
    String subSpecialty,
    String? image, // This will remain null for now
  ) async {
    // Get token for authorization
    final token = await JwtStorage.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    print("Creating doctor profile with token: ${token.substring(0, 10)}...");

    // Build query parameters
    final queryParams = {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'birthday': birthday,
      'userId': userId.toString(),
      'professionalIdentificationNumber':
          professionalIdentificationNumber.toString(),
      'subSpecialty': subSpecialty,
    };

    print("Request URL params: $queryParams");

    // Create URI with query parameters
    final uri = Uri.parse('$baseUrl/doctor/doctor')
        .replace(queryParameters: queryParams);

    print("Full request URL: $uri");

    // Create a multipart request instead of a regular POST
    var request = http.MultipartRequest('POST', uri);

    // Add the authorization header with the token
    request.headers['Authorization'] = 'Bearer $token';

    // Add an empty file field as shown in your CURL example
    // This creates the multipart/form-data content type
    request.files.add(http.MultipartFile.fromString(
      'file',
      '', // Empty string as we don't have actual file content
      contentType: MediaType('application', 'octet-stream'),
    ));

    print("Sending multipart request with headers: ${request.headers}");

    // Send the request
    var streamedResponse = await request.send();
    var doctorResponse = await http.Response.fromStream(streamedResponse);

    print("Response status code: ${doctorResponse.statusCode}");
    print("Response body: ${doctorResponse.body}");

    if (doctorResponse.statusCode != 201) {
      throw Exception('Error creating doctor profile: ${doctorResponse.body}');
    }

    // Parse and return the response
    final doctorData = json.decode(doctorResponse.body);

    // Save doctor ID for future use
    if (doctorData != null && doctorData['id'] != null) {
      await JwtStorage.saveDoctorId(doctorData['id']);
      print("Doctor ID saved: ${doctorData['id']}");
    }

    return doctorData;
  }
}
