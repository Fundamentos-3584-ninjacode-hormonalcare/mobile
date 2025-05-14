import 'package:flutter/material.dart';
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
      // Usa el userId real obtenido de tu sesión o storage
      int userId = await JwtStorage.getUserId();
      final data = await ProfileService().fetchProfileByUserId(userId);
      setState(() {
        profileData = data;
      });
    } catch (e) {
      print('Error loading profile: $e');
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
                LogoutButtonWidget(),
              ],
            ),

            SizedBox(height: 20.0),
            
            // Display fields or editable fields based on edit mode
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
                  // Aquí podrías hacer un PUT al backend, por ahora simplemente guarda localmente:
                  setState(() {
                    profileData = {...profileData!, ...updatedProfile};
                    isEditing = false;
                  });
                },
              ),
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