import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
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
      int userId = await JwtStorage.getUserId();
      final data = await ProfileService().fetchProfileByUserId(userId);
      setState(() {
        profileData = data;
      });
    } catch (e) {
      print('Error loading profile: $e');
    }
  }
  Future<void> _pickAndUploadImageFromFile(File file) async {
    if (profileData == null) return;

    final profileId = profileData!['id'];
    final uri = Uri.parse('http://10.0.2.2/api/v1/profile/$profileId/image');

    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer ${await JwtStorage.getToken()}'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType.parse(lookupMimeType(file.path) ?? 'image/jpeg')!,
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


  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && profileData != null) {
      final file = File(pickedFile.path);
      final profileId = profileData!['id'];

      final uri = Uri.parse('http://10.0.2.2:8080/api/v1/profile/$profileId/image');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer ${await JwtStorage.getToken()}'
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: MediaType.parse(lookupMimeType(file.path) ?? 'image/jpeg')!,
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
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (profileData == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text('Account'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture + edit + logout
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.black),
                  onPressed: toggleEditMode,
                ),
                SizedBox(width: 8.0),
                ProfilePictureWidget(
                  isEditing: isEditing,
                  toggleEditMode: toggleEditMode,
                  imageUrl: profileData!['image'],
                  onImageSelected: (file) => _pickAndUploadImageFromFile(file),
                ),
                SizedBox(width: 8.0),
                LogoutButtonWidget(),
              ],
            ),

            SizedBox(height: 20.0),

            if (!isEditing) ...[
              ProfileFieldWidget(label: "First name", value: profileData!['firstName'] ?? ''),
              ProfileFieldWidget(label: "Last name", value: profileData!['lastName'] ?? ''),
              ProfileFieldWidget(label: "Gender", value: profileData!['gender'] ?? ''),
              ProfileFieldWidget(label: "Birthday", value: profileData!['birthday'] ?? ''),
              ProfileFieldWidget(label: "Phone number", value: profileData!['phoneNumber'] ?? ''),
              ProfileFieldWidget(label: "Email", value: profileData!['user']?['email'] ?? ''),
              ProfileFieldWidget(label: "Medical license number", value: profileData!['licenseNumber'] ?? '---'),
              ProfileFieldWidget(label: "Subspecialty", value: profileData!['subspecialty'] ?? '---'),
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

            SizedBox(height: 20.0),

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
