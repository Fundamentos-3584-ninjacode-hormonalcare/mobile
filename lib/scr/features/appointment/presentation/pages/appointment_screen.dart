import 'package:flutter/material.dart';
import '../widgets/appointment_form.dart'; // Importamos el formulario

class AppointmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF40535B), // Color de la AppBar
        title: Text('Medical Appointments'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppointmentForm(), // El formulario que contiene los campos
      ),
    );
  }
}
