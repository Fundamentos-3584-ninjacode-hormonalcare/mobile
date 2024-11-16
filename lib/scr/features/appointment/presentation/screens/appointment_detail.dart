import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/screens/edit_appointment.dart';

class AppointmentDetail extends StatefulWidget {
  final int appointmentId;

  const AppointmentDetail({Key? key, required this.appointmentId}) : super(key: key);

  @override
  _AppointmentDetailState createState() => _AppointmentDetailState();
}

class _AppointmentDetailState extends State<AppointmentDetail> {
  final MedicalAppointmentApi _appointmentService = MedicalAppointmentApi();
  Map<String, dynamic>? _appointmentDetails;
  Map<String, dynamic>? _patientDetails;

  @override
  void initState() {
    super.initState();
    _loadAppointmentDetails();
  }

  Future<void> _loadAppointmentDetails() async {
    try {
      final appointmentDetails = await _appointmentService.fetchAppointmentDetails(widget.appointmentId);
      final patientDetails = await _appointmentService.fetchPatientDetails(appointmentDetails['patientId']);
      setState(() {
        _appointmentDetails = appointmentDetails;
        _patientDetails = patientDetails;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointment details: $e')),
      );
    }
  }

  Future<void> _deleteAppointment() async {
    try {
      final success = await _appointmentService.deleteMedicalAppointment((widget.appointmentId).toString());
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment deleted successfully!')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete appointment')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete appointment: $e')),
      );
    }
  }

  String _formatDate(String date, String startTime, String endTime) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat dateFormatter = DateFormat('EEEE, d \'de\' MMM.', 'es_ES');
    final DateFormat timeFormatter = DateFormat('h:mm a', 'es_ES');
    final DateTime parsedStartTime = DateTime.parse('$date $startTime');
    final DateTime parsedEndTime = DateTime.parse('$date $endTime');
    return '${dateFormatter.format(parsedDate)} ${timeFormatter.format(parsedStartTime)} - ${timeFormatter.format(parsedEndTime)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_appointmentDetails == null || _patientDetails == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF6A828D),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAppointmentScreen(
                      appointmentDetails: _appointmentDetails!,
                      patientDetails: _patientDetails!,
                    ),
                  ),
                );

                if (result == true) {
                  Navigator.of(context).pop(true); // Return true to indicate success
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteAppointment,
            ),
          ],
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditAppointmentScreen(
                    appointmentDetails: _appointmentDetails!,
                    patientDetails: _patientDetails!,
                  ),
                ),
              );

              if (result == true) {
                Navigator.of(context).pop(true); // Return true to indicate success
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteAppointment,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFF40535B),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                width: MediaQuery.of(context).size.width * 0.8, // Adjust width to be 80% of screen width
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundImage: _patientDetails!['image'] != null
                          ? NetworkImage(_patientDetails!['image'])
                          : null,
                      radius: 20,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _patientDetails!['fullName'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(int.parse(_appointmentDetails!['color'].startsWith('0x') ? _appointmentDetails!['color'] : '0x${_appointmentDetails!['color']}')),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _appointmentDetails!['title'],
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                _formatDate(_appointmentDetails!['eventDate'], _appointmentDetails!['startTime'], _appointmentDetails!['endTime']),
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _appointmentDetails!['description']));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Meeting link copied to clipboard')),
                  );
                },
                icon: Icon(Icons.copy, color: Colors.blue),
                label: Text(
                  'Copy Meeting Link',
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
    );
  }
}