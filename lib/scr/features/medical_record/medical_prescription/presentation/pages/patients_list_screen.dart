import 'package:flutter/material.dart';
import '../../domain/models/patient_model.dart';
import '../widgets/patient_card.dart'; // Asegúrate de importar el archivo correcto

class PatientsListScreen extends StatelessWidget {
  final List<Patient> patients = [
    Patient(name: 'John Doe', condition: 'Condition A'),
    Patient(name: 'Jane Smith', condition: 'Condition B'),
    Patient(name: 'Alice Johnson', condition: 'Condition C'),
    Patient(name: 'Bob Brown', condition: 'Condition D'),
    Patient(name: 'Charlie Davis', condition: 'Condition E'),
    Patient(name: 'Diana Evans', condition: 'Condition F'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text('Patients'), centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ), 
        ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Dos columnas para la cuadrícula
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 0.75, // Relación de aspecto de los elementos
          ),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            return PatientCard(patient: patients[index]);
          },
        ),
      ),
    );
  }
}