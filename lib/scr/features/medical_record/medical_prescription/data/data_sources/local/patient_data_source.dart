import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/medical_prescription/domain/models/patient_model.dart';

class PatientsDataSource {
  List<Patient> getPatients() {
    return [
      Patient(name: 'Ana María López', condition: 'Hypothyroidism'),
      Patient(name: 'Carlos Alberto Ramírez', condition: 'Diabetes type 2'),
      Patient(name: 'Sofía Gabriela Mendoza', condition: 'Polycystic Ovary Syndrome'),
      Patient(name: 'Diego Fernando Acosta', condition: 'Cushing\'s Disease'),
      // Agrega más pacientes
    ];
  }
}
