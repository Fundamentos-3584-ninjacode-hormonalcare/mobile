import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/presentation/pages/sign_in.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/auth_service.dart';
import '../widgets/profile_picture_widget.dart';
import '../widgets/profile_field_widget.dart';
import '../widgets/logout_button_widget.dart';
import '../widgets/save_cancel_buttons_widget.dart';
import '../widgets/edit_mode_widget.dart';

class DoctorProfileScreen extends StatefulWidget {
  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool isEditing = false;
  Future<Map<String, dynamic>>? _profileDetails;
  Future<Map<String, dynamic>>? _doctorProfessionalDetails;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadProfileDetails();
  }

  Future<void> _loadProfileDetails() async {
    final userId = await JwtStorage.getUserId();
    final profileId = await JwtStorage.getProfileId();

    if (userId != null && profileId != null) {
      setState(() {
        _profileDetails = ProfileService().fetchProfileDetails(userId);
        _doctorProfessionalDetails = ProfileService().fetchDoctorProfessionalDetails(profileId);
      });
    } else {
      // Maneja el caso en que no se encuentran los IDs
      print('User ID or Profile ID not found');
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
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text('Doctor Profile'),
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
            // Profile picture, edit button, and logout button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: const Color.fromARGB(255, 0, 0, 0)),
                  onPressed: toggleEditMode,
                ),
                SizedBox(width: 8.0), // Reduce the space between the edit button and the profile picture
                ProfilePictureWidget(isEditing: isEditing, toggleEditMode: toggleEditMode),
                SizedBox(width: 8.0), // Reduce the space between the profile picture and the logout button
                IconButton(
                  icon: Icon(Icons.logout, color: const Color.fromARGB(255, 0, 0, 0)),
                  onPressed: _showLogoutDialog,
                ),
              ],
            ),

            SizedBox(height: 20.0),

            // Display fields or editable fields based on edit mode
            if (!isEditing) ...[
              FutureBuilder<Map<String, dynamic>>(
                future: _profileDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data found'));
                  } else {
                    final profile = snapshot.data!;
                    return Column(
                      children: [
                        ProfileFieldWidget(label: "Full Name", value: profile['fullName'] ?? ''),
                        ProfileFieldWidget(label: "Gender", value: profile['gender'] ?? ''),
                        ProfileFieldWidget(label: "Phone Number", value: profile['phoneNumber'] ?? ''),
                        ProfileFieldWidget(label: "Birthday", value: profile['birthday'] ?? ''),
                        // Add more fields as needed
                      ],
                    );
                  }
                },
              ),
              FutureBuilder<Map<String, dynamic>>(
                future: _doctorProfessionalDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data found'));
                  } else {
                    final professionalDetails = snapshot.data!;
                    return Column(
                      children: [
                        ProfileFieldWidget(label: "Professional ID", value: professionalDetails['professionalIdentificationNumber']?.toString() ?? ''),
                        ProfileFieldWidget(label: "Subspecialty", value: professionalDetails['subSpecialty'] ?? ''),
                        // Add more fields as needed
                      ],
                    );
                  }
                },
              ),
            ] else ...[
              EditModeWidget(),
            ],

            SizedBox(height: 20.0),

            // Save and Cancel buttons in edit mode
            if (isEditing) SaveCancelButtonsWidget(onCancel: toggleEditMode, onSave: () {
              // Save functionality
              toggleEditMode();
            }),
          ],
        ),
      ),
    );
  }
}