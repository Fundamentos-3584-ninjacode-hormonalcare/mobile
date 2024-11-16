import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';

class AddAppointmentScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AddAppointmentScreen({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final MedicalAppointmentApi _appointmentService = MedicalAppointmentApi();
  List<Map<String, dynamic>> _patients = [];
  int? _selectedPatientId;
  Color _selectedColor = Color(0xFF039BE5); // Default color

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Rojo Tomate', 'color': Color(0xFFD50000)},
    {'name': 'Rosa Chicle', 'color': Color(0xFFE67C73)},
    {'name': 'Mandarina', 'color': Color(0xFFF4511E)},
    {'name': 'Amarillo Huevo', 'color': Color(0xFFF6BF26)},
    {'name': 'Verde Esmeralda', 'color': Color(0xFF33B679)},
    {'name': 'Verde Musgo', 'color': Color(0xFF0B8043)},
    {'name': 'Azul Turquesa', 'color': Color(0xFF039BE5)},
    {'name': 'Azul Arándano', 'color': Color(0xFF3F51B5)},
    {'name': 'Lavanda', 'color': Color(0xFF7986CB)},
    {'name': 'Morado Intenso', 'color': Color(0xFF8E24AA)},
    {'name': 'Grafito', 'color': Color(0xFF616161)},
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _startTimeController.text = '${widget.selectedDate.hour.toString().padLeft(2, '0')}:${widget.selectedDate.minute.toString().padLeft(2, '0')}';
    _endTimeController.text = '${widget.selectedDate.add(Duration(hours: 1)).hour.toString().padLeft(2, '0')}:${widget.selectedDate.add(Duration(hours: 1)).minute.toString().padLeft(2, '0')}';
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _appointmentService.fetchPatients();
      setState(() {
        _patients = patients;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load patients: $e')),
      );
    }
  }

  Future<void> _createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      final success = await _appointmentService.createMedicalAppointment(appointmentData);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment created successfully!')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create appointment')),
        );
      }
    } catch (e) {
      print('Error creating appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Appointment'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _startTimeController,
                decoration: InputDecoration(labelText: 'Start Time (HH:MM)'),
                keyboardType: TextInputType.number,
                inputFormatters: [TimeTextInputFormatter()],
              ),
              TextField(
                controller: _endTimeController,
                decoration: InputDecoration(labelText: 'End Time (HH:MM)'),
                keyboardType: TextInputType.number,
                inputFormatters: [TimeTextInputFormatter()],
              ),
              DropdownButtonFormField<int>(
                value: _selectedPatientId,
                items: _patients.map((patient) {
                  return DropdownMenuItem<int>(
                    value: patient['patientId'],
                    child: Text(patient['fullName']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPatientId = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Choose a Patient'),
              ),
              DropdownButtonFormField<Color>(
                value: _selectedColor,
                items: _colors.map((color) {
                  return DropdownMenuItem<Color>(
                    value: color['color'],
                    child: Text(color['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedColor = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Choose a Color'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final String title = _titleController.text;
                  final String description = _descriptionController.text;
                  final DateTime startTime = DateTime(
                    widget.selectedDate.year,
                    widget.selectedDate.month,
                    widget.selectedDate.day,
                    int.parse(_startTimeController.text.split(':')[0]),
                    int.parse(_startTimeController.text.split(':')[1]),
                  );
                  final DateTime endTime = DateTime(
                    widget.selectedDate.year,
                    widget.selectedDate.month,
                    widget.selectedDate.day,
                    int.parse(_endTimeController.text.split(':')[0]),
                    int.parse(_endTimeController.text.split(':')[1]),
                  );

                  if (_selectedPatientId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please choose a patient')),
                    );
                    return;
                  }

                  final appointmentData = {
                    'eventDate': widget.selectedDate.toIso8601String().split('T')[0],
                    'startTime': _startTimeController.text, // Formato HH:MM
                    'endTime': _endTimeController.text, // Formato HH:MM
                    'title': title,
                    'description': description,
                    'doctorId': await _appointmentService.getDoctorId(),
                    'patientId': _selectedPatientId,
                    'color': _selectedColor.value.toRadixString(16), // Save color as hex string
                  };

                  await _createAppointment(appointmentData);
                },
                child: Text('Add Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length == 4 && !text.contains(':')) {
      final formattedText = '${text.substring(0, 2)}:${text.substring(2)}';
      return newValue.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
    return newValue;
  }
}