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
    _titleController.text = widget.appointmentDetails['title'] ?? '';
    _descriptionController.text = widget.appointmentDetails['description'] ?? '';
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
              child: Text(patient['fullName']),
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
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color(0xFF6A828D),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateAppointment,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Centrado en el eje X
              children: [
                SizedBox(height: 1), // Reducir el espaciado inicial para acercar los elementos al header
                GestureDetector(
                  onTap: () => _selectPatient(context),
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF40535B),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Center(
                      child: Text(
                        _patients.isNotEmpty
                            ? _patients.firstWhere((patient) => patient['patientId'] == _selectedPatientId, orElse: () => {'fullName': 'Unknown'})['fullName'] ?? 'Unknown'
                            : 'Unknown',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Text(
                      DateFormat('EEE, d \'of\' MMMM \'yyyy').format(_selectedDate),
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: GestureDetector(
                    onTap: () => _selectTime(context, true),
                    child: Text(
                      _formatTimeOfDay(_startTime),
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: GestureDetector(
                    onTap: () => _selectTime(context, false),
                    child: Text(
                      _formatTimeOfDay(_endTime),
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: GestureDetector(
                    onTap: () => _selectColor(context),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedColor,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          _colors.isNotEmpty
                              ? _colors.firstWhere((color) => color['color'] == _selectedColor, orElse: () => {'name': 'Unknown'})['name'] ?? 'Unknown'
                              : 'Unknown',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Aquí puedes agregar la lógica para generar un nuevo link
                    },
                    icon: Icon(Icons.refresh, color: Colors.blue),
                    label: Text(
                      'Generate New Link',
                      style: TextStyle(color: Colors.blue),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}