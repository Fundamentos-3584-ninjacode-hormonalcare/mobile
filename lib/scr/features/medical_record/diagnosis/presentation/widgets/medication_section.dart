import 'package:flutter/material.dart';

class MedicationSection extends StatelessWidget {
  final List<Map<String, String>> medications;
  final Function(Map<String, String>) onAddMedication;

  const MedicationSection({
    required this.medications,
    required this.onAddMedication,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medication',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF40535B),
          ),
        ),
        const SizedBox(height: 10),
        ...medications.map((medication) => _buildMedicationItem(medication)),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF40535B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            _showAddMedicationDialog(context);
          },
          child: const Text(
            'Add Medication',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationItem(Map<String, String> medication) {
    return Card(
      color: const Color(0xFFEDECEC),
      child: ListTile(
        title: Text(
          'Medication: ${medication["name"]}',
          style: const TextStyle(
            color: Color(0xFF40535B),
          ),
        ),
        subtitle: Text(
          'Concentration: ${medication["concentration"]}, Unit: ${medication["unit"]}, Frequency: ${medication["frequency"]}',
          style: const TextStyle(
            color: Color(0xFF40535B),
          ),
        ),
      ),
    );
  }

  void _showAddMedicationDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController concentrationController = TextEditingController();
    TextEditingController unitController = TextEditingController();
    TextEditingController frequencyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Medication'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Medication Name'),
              ),
              TextField(
                controller: concentrationController,
                decoration: const InputDecoration(hintText: 'Concentration'),
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(hintText: 'Unit'),
              ),
              TextField(
                controller: frequencyController,
                decoration: const InputDecoration(hintText: 'Frequency'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                onAddMedication({
                  "name": nameController.text,
                  "concentration": concentrationController.text,
                  "unit": unitController.text,
                  "frequency": frequencyController.text,
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}