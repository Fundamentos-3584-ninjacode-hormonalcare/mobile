import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/diagnosis/presentation/widgets/edit_modal.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/diagnosis/presentation/widgets/user_info_section.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/diagnosis/presentation/widgets/editable_field.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/diagnosis/presentation/widgets/medication_section.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/diagnosis/presentation/widgets/lab_test_section.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({Key? key}) : super(key: key);

  @override
  _ConsultationScreenState createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  List<Map<String, String>> medications = [];
  List<Map<String, dynamic>> labTests = [];
  String diagnosis = "";
  String treatment = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A828D),
        title: const Text('Consultation'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserInfoSection(),
            const SizedBox(height: 20),
            const Text(
              'Diagnosis',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF40535B),
              ),
            ),
            const SizedBox(height: 10),
            EditableField(
              label: 'Diagnosis',
              value: diagnosis,
              onSave: (newValue) {
                setState(() {
                  diagnosis = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Treatment',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF40535B),
              ),
            ),
            const SizedBox(height: 10),
            EditableField(
              label: 'Treatment',
              value: treatment,
              onSave: (newValue) {
                setState(() {
                  treatment = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            MedicationSection(
              medications: medications,
              onAddMedication: (medication) {
                setState(() {
                  medications.add(medication);
                });
              },
            ),
            const SizedBox(height: 20),
            LabTestSection(
              labTests: labTests,
              onAddLabTest: (labTest) {
                setState(() {
                  labTests.add(labTest);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}