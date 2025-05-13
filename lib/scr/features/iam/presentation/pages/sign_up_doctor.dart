import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/doctor_signup_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/auth_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/shared/presentation/pages/home_screen.dart';

class SignUpDoctor extends StatefulWidget {
  @override
  _SignUpDoctorState createState() => _SignUpDoctorState();
}

class _SignUpDoctorState extends State<SignUpDoctor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _medicalLicenseNumberController =
      TextEditingController();
  final TextEditingController _subSpecialtyController = TextEditingController();
  String _image = '';
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // Format the date as YYYY-MM-DD
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print("=========== DOCTOR SIGNUP FLOW START ===========");

        // 1. Sign up the user first with ROLE_DOCTOR
        print(
            "Step 1: Creating authentication account with username: ${_usernameController.text}");
        final userResponse = await _authService.signUp(
            _usernameController.text, _passwordController.text, 'ROLE_DOCTOR');
        print("User registration successful: $userResponse");

        // 2. Sign in to get token and userId
        print("Step 2: Signing in to get token and userId");
        final token = await _authService.signIn(
            _usernameController.text, _passwordController.text);

        if (token != null) {
          print("Sign-in successful, token received");

          // 3. Get userId from storage after sign-in
          final userId = await JwtStorage.getUserId();
          print("User ID retrieved: $userId");

          if (userId != null) {
            // 4. Create doctor profile with image as null
            print("Step 3: Creating doctor profile");
            print("Parameters: firstName=${_firstNameController.text}, " +
                "lastName=${_lastNameController.text}, " +
                "gender=${_genderController.text}, " +
                "phoneNumber=${_phoneNumberController.text}, " +
                "birthday=${_birthdayController.text}, " +
                "userId=$userId, " +
                "professionalIdentificationNumber=${_medicalLicenseNumberController.text}, " +
                "subSpecialty=${_subSpecialtyController.text}, " +
                "image=null");

            final doctorResponse =
                await DoctorSignUpService.createDoctorProfile(
              _firstNameController.text,
              _lastNameController.text,
              _genderController.text,
              _phoneNumberController.text,
              _birthdayController.text,
              userId,
              int.parse(_medicalLicenseNumberController.text),
              _subSpecialtyController.text,
              null, // image parameter as null
            );

            print("Doctor profile created successfully: $doctorResponse");
            print("Doctor ID: ${doctorResponse['id']}");
            print("Doctor Record ID: ${doctorResponse['doctorRecordId']}");

            if (doctorResponse.containsKey('profileId')) {
              await JwtStorage.saveProfileId(doctorResponse['profileId']);
              print("Profile ID saved: ${doctorResponse['profileId']}");
            }

// Save the doctor ID
            if (doctorResponse.containsKey('id')) {
              await JwtStorage.saveDoctorId(doctorResponse['id']);
              print("Doctor ID saved: ${doctorResponse['id']}");
            }

            // Navigate to home on success
            print("Navigating to home screen");
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
            );
          } else {
            throw Exception("Could not retrieve user ID");
          }
        } else {
          throw Exception("Sign-in failed");
        }
      } catch (e) {
        print("ERROR in doctor signup flow: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        print("=========== DOCTOR SIGNUP FLOW END ===========");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor's Sign Up"),
        backgroundColor: Color(0xFF6A828D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image upload placeholder
                        GestureDetector(
                          onTap: () {
                            // Implement image picker here
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                _image.isNotEmpty ? NetworkImage(_image) : null,
                            child: _image.isEmpty
                                ? Icon(Icons.camera_alt, size: 50)
                                : null,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextField(_firstNameController, 'First Name'),
                        _buildTextField(_lastNameController, 'Last Name'),
                        _buildDropdownField(
                            _genderController, 'Gender', ['MALE', 'FEMALE']),
                        _buildDateField(_birthdayController, 'Birthday'),
                        _buildTextField(_phoneNumberController, 'Phone Number'),
                        _buildTextField(_usernameController, 'Username'),
                        _buildTextField(_passwordController, 'Password',
                            obscureText: true),
                        _buildTextField(_medicalLicenseNumberController,
                            'Medical License Number'),
                        _buildTextField(
                            _subSpecialtyController, 'SubSpecialty'),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submit,
                          child: Text('Sign Up'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ),
        readOnly: true,
        onTap: () => _selectDate(context),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(
      TextEditingController controller, String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        value: controller.text.isNotEmpty ? controller.text : null,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            controller.text = newValue!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }
}
