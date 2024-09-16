import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text('Perfil'),
      ),
      body: Center(
        child: Text('Pantalla de perfil'),
      ),
    );
  }
}
