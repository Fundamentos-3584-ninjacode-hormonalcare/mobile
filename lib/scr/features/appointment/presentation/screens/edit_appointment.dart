import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importar el paquete services
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:intl/intl.dart';

class EditAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentDetails;
  final Map<String, dynamic> patientDetails;

  const EditAppointmentScreen({Key? key, required this.appointmentDetails, required this.patientDetails}) : super(key: key);

  @override
  _EditAppointmentScreenState createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final MedicalAppointmentApi _appointmentService = MedicalAppointmentApi();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  Color _selectedColor = Color(0xFF039BE5); // Default color
  int? _selectedPatientId;
  List<Map<String, dynamic>> _patients = [];

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
    _titleController.text = widget.appointmentDetails['title'];
    _descriptionController.text = widget.appointmentDetails['description'];
    _selectedDate = DateTime.parse(widget.appointmentDetails['eventDate']);
    _startTime = TimeOfDay.fromDateTime(DateTime.parse('${widget.appointmentDetails['eventDate']} ${widget.appointmentDetails['startTime']}'));
    _endTime = TimeOfDay.fromDateTime(DateTime.parse('${widget.appointmentDetails['eventDate']} ${widget.appointmentDetails['endTime']}'));
    _selectedColor = Color(int.parse(widget.appointmentDetails['color'].startsWith('0x') ? widget.appointmentDetails['color'] : '0x${widget.appointmentDetails['color']}'));
    _selectedPatientId = widget.appointmentDetails['patientId'];
    _loadPatients();
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

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat('HH:mm'); // 24-hour format
    return format.format(dt);
  }

  Future<void> _updateAppointment() async {
    try {
      final updatedAppointmentData = {
        'eventDate': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'startTime': _formatTimeOfDay(_startTime),
        'endTime': _formatTimeOfDay(_endTime),
        'title': _titleController.text,
        'description': _descriptionController.text,
        'doctorId': widget.appointmentDetails['doctorId'],
        'patientId': _selectedPatientId,
        'color': _selectedColor.value.toRadixString(16),
      };

      final success = await _appointmentService.updateMedicalAppointment(
        widget.appointmentDetails['id'].toString(),
        updatedAppointmentData['eventDate'],
        updatedAppointmentData['startTime'],
        updatedAppointmentData['endTime'],
        updatedAppointmentData['title'],
        updatedAppointmentData['description'],
        updatedAppointmentData['doctorId'],
        updatedAppointmentData['patientId']!,
        updatedAppointmentData['color'],
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment updated successfully!')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update appointment')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update appointment: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null)
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
  }

  void _selectColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Choose a Color'),
          children: _colors.map((color) {
            return SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedColor = color['color'];
                });
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color['color'],
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(color['name']),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _selectPatient(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Choose a Patient'),
          children: _patients.map((patient) {
            return SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedPatientId = patient['patientId'];
                });
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: patient['image'] != null ? NetworkImage(patient['image']) : null,
                    backgroundColor: Color(0xFF40535B),
                    radius: 16,
                  ),
                  SizedBox(width: 8),
                  Text(patient['fullName']),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: _updateAppointment,
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 18),
              ),
              Divider(),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _descriptionController.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Meeting link copied to clipboard')),
                  );
                },
                child: Text(
                  _descriptionController.text,
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ),
              Divider(),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Text(
                  DateFormat('EEE, d \'de\' MMMM \'del\' yyyy', 'es_ES').format(_selectedDate),
                  style: TextStyle(fontSize: 18),
                ),
              ),
              GestureDetector(
                onTap: () => _selectTime(context, true),
                child: Text(
                  _startTime.format(context),
                  style: TextStyle(fontSize: 18),
                ),
              ),
              GestureDetector(
                onTap: () => _selectTime(context, false),
                child: Text(
                  _endTime.format(context),
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Divider(),
              GestureDetector(
                onTap: () => _selectPatient(context),
                child: Text(
                  _patients.firstWhere((patient) => patient['patientId'] == _selectedPatientId)['fullName'],
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Divider(),
              GestureDetector(
                onTap: () => _selectColor(context),
                child: Text(
                  _colors.firstWhere((color) => color['color'] == _selectedColor)['name'],
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}