import 'package:flutter/material.dart';

class AppointmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text('Citas Médicas'),
      ),
      body: Center(
        child: Text('Pantalla de Citas'),
      ),
    );
  }
}
