import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/diagnosis/presentation/pages/consultation_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/widgets/appointment_form.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/patient_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HomePatientsScreen extends StatefulWidget {
  final int doctorId;

  HomePatientsScreen({required this.doctorId});

  @override
  _HomePatientsScreenState createState() => _HomePatientsScreenState();
}

class _HomePatientsScreenState extends State<HomePatientsScreen> {
  final MedicalAppointmentApi _appointmentApi = MedicalAppointmentApi();
  final PatientService _patientService = PatientService();
  final ProfileService _profileService = ProfileService();

  List<Map<String, String>> patients = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final appointments = await _appointmentApi.fetchAppointmentsForToday(widget.doctorId);
      final List<Map<String, String>> fetchedPatients = [];
      final limaTimeZone = tz.getLocation('America/Lima');

      for (var appointment in appointments) {
        final patientDetails = await _patientService.fetchPatientDetails(appointment['patientId']);
        final profileDetails = await _profileService.fetchProfileDetails(patientDetails['profileId']);
        fetchedPatients.add({
          'name': profileDetails['fullName'],
          'time': appointment['startTime'],
          'image': profileDetails['image'], // Assuming 'image' is the key for the profile image URL
          'eventDate': appointment['eventDate'],
          'patientId': appointment['patientId'].toString(),
        });
      }

      // Ordenar las citas por hora
      fetchedPatients.sort((a, b) {
        final aTime = tz.TZDateTime.from(DateTime.parse(a['eventDate']!), limaTimeZone);
        final bTime = tz.TZDateTime.from(DateTime.parse(b['eventDate']!), limaTimeZone);
        return aTime.compareTo(bTime);
      });

      setState(() {
        patients = fetchedPatients;
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching patients: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final limaTimeZone = tz.getLocation('America/Lima');
    final now = tz.TZDateTime.now(limaTimeZone);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text("Today's Patients"),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPatients,
        child: errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final eventDate = tz.TZDateTime.from(DateTime.parse(patients[index]['eventDate']!), limaTimeZone);
                  final isPast = eventDate.isBefore(now);

                  return Card(
                    color: isPast ? Color(0xFFB0BEC5) : Color(0xFFE0E0E0), // Oscurecer las citas pasadas
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Stack(
                      children: [
                        ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ConsultationScreen()),
                                  );
                                },
                                child: Icon(Icons.insert_drive_file, color: Color(0xFF40535B)),
                              ),
                              SizedBox(width: 8), // Espacio entre los iconos
                              CircleAvatar(
                                backgroundImage: NetworkImage(patients[index]['image']!),
                                backgroundColor: Color(0xFF6A828D),
                              ),
                            ],
                          ),
                          title: Text(
                            patients[index]['name']!,
                            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                          trailing: Padding(
                            padding: EdgeInsets.only(right: 16), // Move the container to the left
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4), // Adjusted padding
                              decoration: BoxDecoration(
                                color: Color(0xFF40535B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.videocam, color: Colors.white),
                                  SizedBox(width: 4), // Adjusted spacing
                                  Text(
                                    patients[index]['time']!,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 0,
                          bottom: 0,
                          child: Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 12, // Half the size of the original
                              backgroundColor: Color(0xFF40535B),
                              child: Center(
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.add, color: Colors.white, size: 16),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Add Medical Appointment'),
                                          titleTextStyle: TextStyle(color: Color(0xFF40535B), fontWeight: FontWeight.bold),
                                          content: AppointmentForm(patientId: int.parse(patients[index]['patientId']!)),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}