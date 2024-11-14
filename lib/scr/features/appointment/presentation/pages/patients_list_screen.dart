//patients list screen 
import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/widgets/appointment_form.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/patient_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/widgets/info_appointment.dart'; // Importa el widget InfoAppointment
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = await JwtStorage.getUserId();
      final role = await JwtStorage.getRole();

      if (role != 'ROLE_DOCTOR') {
        throw Exception('Only doctors can view patients');
      }

      final appointments = await _appointmentApi.fetchAppointmentsForToday();
      final List<Map<String, String>> fetchedPatients = [];
      final limaTimeZone = tz.getLocation('America/Lima');

      for (var appointment in appointments) {
        final patientDetails = await _patientService.fetchPatientDetails(appointment['patientId']);
        final profileDetails = await _profileService.fetchProfileDetails(patientDetails['profileId']);
        fetchedPatients.add({
          'name': profileDetails['fullName'],
          'time': appointment['startTime'],
          'endTime': appointment['endTime'],
          'image': profileDetails['image'], // Assuming 'image' is the key for the profile image URL
          'eventDate': appointment['eventDate'],
          'patientId': appointment['patientId'].toString(),
          'title': appointment['title'],
          'description': appointment['description'],
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
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching patients: $e';
        isLoading = false;
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
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
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
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(patients[index]['image']!),
                                backgroundColor: Color(0xFF6A828D),
                              ),
                              title: Text(
                                patients[index]['name']!,
                                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                              trailing: Padding(
                                padding: EdgeInsets.only(right: 16), // Move the container to the left
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return InfoAppointment(
                                          patientName: patients[index]['name']!,
                                          appointmentTime: patients[index]['time']!,
                                          endTime: patients[index]['endTime']!,
                                          appointmentDate: patients[index]['eventDate']!,
                                          title: patients[index]['title']!,
                                          description: patients[index]['description']!,
                                        );
                                      },
                                    );
                                  },
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
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Container(
                                                width: MediaQuery.of(context).size.width * 0.8, // Ajusta el valor según sea necesario
                                                constraints: BoxConstraints(
                                                  maxHeight: MediaQuery.of(context).size.height * 0.6, // Ajusta el valor según sea necesario
                                                ),
                                                child: SingleChildScrollView(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Add Medical Appointment',
                                                          style: TextStyle(
                                                            color: Color(0xFF40535B),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16),
                                                        AppointmentForm(patientId: int.parse(patients[index]['patientId']!)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
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