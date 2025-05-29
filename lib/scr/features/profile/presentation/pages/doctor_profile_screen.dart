import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/auth_service.dart';
import '../widgets/profile_picture_widget.dart';
import '../widgets/profile_field_widget.dart';
import '../widgets/edit_mode_doctor_widget.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/presentation/pages/sign_in.dart';

class DoctorProfileScreen extends StatefulWidget {
  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool isEditing = false;
  Future<Map<String, dynamic>>? _doctorProfileDetails;
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  int? _doctorId;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfileDetails();
  }

  Future<void> _loadDoctorProfileDetails() async {
    final profileId = await JwtStorage.getProfileId();

    if (profileId != null) {
      final profileDetails = await _profileService.fetchProfileDetails(profileId);
      final doctorProfessionalDetails = await _profileService.fetchDoctorProfessionalDetails(profileId);

      final combinedDetails = {
        ...profileDetails,
        ...doctorProfessionalDetails,
      };

      setState(() {
        _doctorProfileDetails = Future.value(combinedDetails);
        _doctorId = doctorProfessionalDetails['id'];
      });
    } else {
      print('Profile ID not found');
    }
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(child: Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            TextButton(child: Text('Yes'), onPressed: () {
              Navigator.of(context).pop();
              _logout();
            }),
          ],
        );
      },
    );
  }

  Future<void> _saveDoctorProfileDetails(Map<String, dynamic> updatedDoctorProfile) async {
    if (_doctorId != null) {
      try {
        final profileId = await JwtStorage.getProfileId();

        // 1. Verificar si hay una imagen nueva
        if (_selectedImageFile != null) {
          final uri = Uri.parse('http://10.0.2.2:8080/api/v1/profile/$profileId/image');

          final request = http.MultipartRequest('PUT', uri)
            ..headers['Authorization'] = 'Bearer ${await JwtStorage.getToken()}'
            ..files.add(await http.MultipartFile.fromPath(
              'file',
              _selectedImageFile!.path,
              contentType: MediaType.parse(lookupMimeType(_selectedImageFile!.path) ?? 'image/jpeg')!,
            ));

          final response = await request.send();
          if (response.statusCode == 200) {
            final body = await response.stream.bytesToString();
            print('Imagen de perfil subida exitosamente: $body');
            updatedDoctorProfile['image'] = jsonDecode(body)['image'];
          } else {
            print('Error al subir imagen: ${response.statusCode}');
          }
        } else {
          // 2. Si no hay nueva imagen, conservar la actual
          final currentDetails = await _doctorProfileDetails;
          final currentImage = currentDetails?['image'];

          if (currentImage != null) {
            updatedDoctorProfile['image'] = currentImage;
          }
        }

        // 3. Actualizar el perfil
        await _profileService.updateDoctorProfile(_doctorId!, updatedDoctorProfile);
        print('Doctor profile updated successfully');

        toggleEditMode();
        await _loadDoctorProfileDetails();

        setState(() {
          _selectedImageFile = null;
        });
      } catch (e) {
        print('Error updating doctor profile: $e');
      }
    } else {
      print('Doctor ID not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text('Doctor Profile'),
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: Icon(Icons.edit, color: Colors.black), onPressed: toggleEditMode),
                SizedBox(width: 8.0),
                FutureBuilder<Map<String, dynamic>>(
                  future: _doctorProfileDetails,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
                    if (snapshot.hasError) return Icon(Icons.error);
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return Icon(Icons.person);
                    String? rawImage = snapshot.data!['image'] as String?;
                    String? imageUrl;

                    try {
                      // Intenta parsear el JSON anidado, si es válido
                      final parsed = jsonDecode(rawImage!);
                      imageUrl = parsed['image'];
                    } catch (_) {
                      // Si no se puede parsear, asume que es una URL directa
                      imageUrl = rawImage;
                    }

                    return ProfilePictureWidget(
                      isEditing: isEditing,
                      toggleEditMode: toggleEditMode,
                      imageUrl: imageUrl,
                      onImageSelected: (file) => setState(() => _selectedImageFile = file),
                    );
                  },
                ),
                SizedBox(width: 8.0),
                IconButton(icon: Icon(Icons.logout, color: Colors.black), onPressed: _showLogoutDialog),
              ],
            ),
            SizedBox(height: 20.0),
            if (!isEditing)
              FutureBuilder<Map<String, dynamic>>(
                future: _doctorProfileDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('No data found'));
                  final doctorProfile = snapshot.data!;
                  final fullName = doctorProfile['fullName'] ?? '';
                  final nameParts = fullName.split(' ');
                  final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
                  final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
                  return Column(
                    children: [
                      ProfileFieldWidget(label: "First Name", value: firstName),
                      ProfileFieldWidget(label: "Last Name", value: lastName),
                      ProfileFieldWidget(label: "Gender", value: doctorProfile['gender'] ?? ''),
                      ProfileFieldWidget(label: "Phone Number", value: doctorProfile['phoneNumber'] ?? ''),
                      ProfileFieldWidget(
                        label: "Birthday",
                        value: doctorProfile['birthday'] != null
                            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(doctorProfile['birthday']))
                            : '',
                      ),
                      ProfileFieldWidget(label: "Professional ID Number", value: doctorProfile['professionalIdentificationNumber']?.toString() ?? ''),
                      ProfileFieldWidget(label: "SubSpecialty", value: doctorProfile['subSpecialty'] ?? ''),
                    ],
                  );
                },
              )
            else
              FutureBuilder<Map<String, dynamic>>(
                future: _doctorProfileDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('No data found'));
                  return EditModeDoctorWidget(
                    doctorProfile: snapshot.data!,
                    onCancel: toggleEditMode,
                    onSave: _saveDoctorProfileDetails,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
