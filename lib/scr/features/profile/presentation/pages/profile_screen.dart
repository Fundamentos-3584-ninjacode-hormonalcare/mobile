import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/profile_service.dart';
import '../../../../core/utils/usecases/jwt_storage.dart';
import '../widgets/profile_picture_widget.dart';
import '../widgets/profile_field_widget.dart';
import '../widgets/logout_button_widget.dart';
import '../widgets/save_cancel_buttons_widget.dart';
import '../widgets/edit_mode_widget.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      print("Loading doctor profile data...");

      // First try to get doctor ID from storage
      int? doctorId = await JwtStorage.getDoctorId();
      print("Doctor ID retrieved: $doctorId");

      if (doctorId != null) {
        // If we have doctor ID, use it directly to get doctor profile
        print("Using doctor ID to fetch profile: $doctorId");
        final data = await ProfileService().fetchDoctorProfileDetails(doctorId);
        print("Doctor profile data received: $data");

        setState(() {
          profileData = data;
        });
      } else {
        // If no doctor ID, get userId and fetch doctor by userId
        print('Doctor ID not found in storage, using userId instead');
        final userId = await JwtStorage.getUserId();
        print("User ID retrieved: $userId");

        if (userId != null) {
          // Use fetchProfileDetails which now calls /api/v1/doctor/by-user/{userId}
          final data = await ProfileService().fetchProfileDetails(userId);
          print("Doctor profile data received: $data");

          setState(() {
            profileData = data;
          });
        } else {
          throw Exception('No user ID found');
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> _pickAndUploadImageFromFile(File file) async {
    if (profileData == null) return;

    final profileId = profileData!['id'];
    final uri =
        Uri.parse('http://10.0.2.2:8080/api/v1/profile/$profileId/image');

    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer ${await JwtStorage.getToken()}'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType:
              MediaType.parse(lookupMimeType(file.path) ?? 'image/jpeg'),
        ),
      );

    final response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      print('Imagen subida exitosamente: $body');
      await _loadProfileData(); // Refrescar con nueva imagen
    } else {
      print('Fallo al subir imagen: ${response.statusCode}');
    }
  }

  // Future<void> _pickAndUploadImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null && profileData != null) {
  //     final file = File(pickedFile.path);
  //     final profileId = profileData!['id'];

  //     final uri =
  //         Uri.parse('http://10.0.2.2:8080/api/v1/profile/$profileId/image');
  //     final request = http.MultipartRequest('PUT', uri)
  //       ..headers['Authorization'] = 'Bearer ${await JwtStorage.getToken()}'
  //       ..files.add(
  //         await http.MultipartFile.fromPath(
  //           'file',
  //           file.path,
  //           contentType:
  //               MediaType.parse(lookupMimeType(file.path) ?? 'image/jpeg')!,
  //         ),
  //       );

  //     final response = await request.send();
  //     if (response.statusCode == 200) {
  //       final body = await response.stream.bytesToString();
  //       print('Imagen subida exitosamente: $body');
  //       await _loadProfileData(); // Refrescar con nueva imagen
  //     } else {
  //       print('Fallo al subir imagen: ${response.statusCode}');
  //     }
  //   }
  // }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (profileData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A828D),
        title: const Text('Account'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture + edit + logout
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: toggleEditMode,
                ),
                const SizedBox(width: 8.0),
                ProfilePictureWidget(
                  isEditing: isEditing,
                  toggleEditMode: toggleEditMode,
                  imageUrl: profileData!['image'],
                  onImageSelected: (file) => _pickAndUploadImageFromFile(file),
                ),
                const SizedBox(width: 8.0),
                const LogoutButtonWidget(),
              ],
            ),

            const SizedBox(height: 20.0),

            if (!isEditing) ...[
              ProfileFieldWidget(
                  label: "Full name", value: profileData!['fullName'] ?? ''),
              ProfileFieldWidget(
                  label: "Gender", value: profileData!['gender'] ?? ''),
              ProfileFieldWidget(
                  label: "Birthday", value: profileData!['birthday'] ?? ''),
              ProfileFieldWidget(
                  label: "Phone number",
                  value: profileData!['phoneNumber'] ?? ''),
              ProfileFieldWidget(
                  label: "Professional ID number",
                  value: profileData!['professionalIdentificationNumber']
                          ?.toString() ??
                      '---'),
              ProfileFieldWidget(
                  label: "Subspecialty",
                  value: profileData!['subSpecialty'] ?? '---'),
              ProfileFieldWidget(
                  label: "Doctor Record ID",
                  value: profileData!['doctorRecordId'] ?? '---'),
            ] else ...[
              EditModeWidget(
                profile: profileData!,
                onCancel: toggleEditMode,
                onSave: (updatedProfile) {
                  setState(() {
                    profileData = {...profileData!, ...updatedProfile};
                    isEditing = false;
                  });
                },
              ),
            ],

            const SizedBox(height: 20.0),

            if (isEditing)
              SaveCancelButtonsWidget(
                onCancel: toggleEditMode,
                onSave: () {
                  toggleEditMode();
                },
              ),
          ],
        ),
      ),
    );
  }
}
