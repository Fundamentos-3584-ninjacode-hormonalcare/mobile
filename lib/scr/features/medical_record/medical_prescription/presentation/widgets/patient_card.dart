import 'package:flutter/material.dart';
import '../../domain/models/patient_model.dart';
import '../../../diagnosis/presentation/pages/medicalrecord_screen.dart'; // Importa la pantalla de historial médico

class PatientCard extends StatelessWidget {
  final Patient patient;

  const PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFAEBBC3), // Fondo de cada tarjeta de paciente
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 50.0, color: Color(0xFF40535B)), // Ícono de paciente
              SizedBox(height: 10.0),
              Text(
                patient.profile?.fullName ?? 'Unknown', // Mostrar el nombre completo del perfil
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0), // Botón de historial médico
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicalRecordScreen(patientId: patient.patientRecordId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF40535B), // Color gris oscuro del botón
                  foregroundColor: Colors.white, // Texto del botón en blanco
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Text('Medical record'),
              ),
              SizedBox(height: 5.0),
            ],
          ),
        ),
      ),
    );
  }
}