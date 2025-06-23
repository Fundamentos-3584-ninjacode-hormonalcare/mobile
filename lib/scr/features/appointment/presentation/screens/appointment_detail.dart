import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/screens/edit_appointment.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/pages/video_call_page.dart';

class AppointmentDetail extends StatefulWidget {
  final int appointmentId;

  const AppointmentDetail({Key? key, required this.appointmentId})
      : super(key: key);

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
      final appointmentDetails = await _appointmentService
          .fetchAppointmentDetails(widget.appointmentId);
      final patientDetails = await _appointmentService
          .fetchPatientDetails(appointmentDetails['patientId']);
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
      final success = await _appointmentService
          .deleteMedicalAppointment((widget.appointmentId).toString());
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment deleted successfully!')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete appointment')),
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
          backgroundColor: const Color(0xFF6A828D),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Appointment Detail',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Appointment Detail',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF40535B),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                width: MediaQuery.of(context).size.width *
                    0.8, // Adjust width to be 80% of screen width
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
                    const SizedBox(width: 8),
                    Text(
                      _patientDetails!['fullName'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(int.parse(
                          _appointmentDetails!['color'].startsWith('0x')
                              ? _appointmentDetails!['color']
                              : '0x${_appointmentDetails!['color']}')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _appointmentDetails!['title'],
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                _formatDate(
                    _appointmentDetails!['eventDate'],
                    _appointmentDetails!['startTime'],
                    _appointmentDetails!['endTime']),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text: _appointmentDetails!['description']));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Meeting link copied to clipboard')),
                        );
                      },
                      icon: const Icon(Icons.copy, color: Colors.blue),
                      label: const Text(
                        'Copy Link',
                        style: TextStyle(color: Colors.blue),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final roomId =
                            "cita_${_appointmentDetails!['id']}"; // o cualquier ID único
                        final displayName = _patientDetails!['fullName'];

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoCallPage(
                              roomName: roomId,
                              displayName: displayName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.video_call, color: Colors.blue),
                      label: const Text(
                        'Iniciar Videollamada',
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
            const Spacer(), // Pushes the buttons to the bottom
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _deleteAppointment,
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text('Delete',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18)), // Aumenta el tamaño del texto
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16), // Aumenta el padding vertical
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Espacio entre los botones
                  Expanded(
                    child: ElevatedButton.icon(
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
                          Navigator.of(context)
                              .pop(true); // Return true to indicate success
                        }
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Edit',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18)), // Aumenta el tamaño del texto
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF40535B),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16), // Aumenta el padding vertical
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
