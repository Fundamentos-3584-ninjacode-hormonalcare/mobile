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

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              ProfileFieldWidget(label: "First name", value: "Pedro"),
              ProfileFieldWidget(label: "Last name", value: "Sánchez"),
              ProfileFieldWidget(label: "Gender", value: "Male"),
              ProfileFieldWidget(label: "Birthday", value: "07/09/1980"),
              ProfileFieldWidget(label: "Phone number", value: "+51 987 123 567"),
              ProfileFieldWidget(label: "Email", value: "pedrosanchez@gmail.com"),
              ProfileFieldWidget(label: "Medical license number", value: "229 234 2"),
              ProfileFieldWidget(label: "Subspecialty", value: "Diabetes"),
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