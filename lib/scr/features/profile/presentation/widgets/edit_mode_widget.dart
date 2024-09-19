import 'package:flutter/material.dart';

class EditModeWidget extends StatelessWidget {
  const EditModeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildEditableField("First name", "Pedro"),
        _buildEditableField("Last name", "Sánchez"),
        _buildEditableField("Gender", "Male"),
        _buildEditableField("Birthday", "07/09/1980"),
        _buildEditableField("Phone number", "+51 987 123 567"),
        _buildEditableField("Email", "pedrosanchez@gmail.com"),
        _buildEditableField("Medical license number", "229 234 2"),
        _buildEditableField("Subspecialty", "Diabetes"),
      ],
    );
  }

  Widget _buildEditableField(String label, String initialValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        controller: TextEditingController(text: initialValue),
      ),
    );
  }
}
