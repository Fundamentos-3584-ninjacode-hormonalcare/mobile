import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/screens/add_appointment.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/screens/appointment_detail.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/patient_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/pages/video_call_page.dart';
//import 'package:trabajo_moviles_ninjacode/scr/features/appointment/domain/services/appointment_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

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
    print('initState: arrancando _fetchPatients() para doctorId=${widget
        .doctorId}');
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() {
      isLoading = true;
    });
    print('_fetchPatients: cargando pacientes...');

    try {
      final role = await JwtStorage.getRole();
      print('Rol obtenido: $role');
      if (role != 'ROLE_DOCTOR') {
        throw Exception('Only doctors can view patients');
      }

      print('Llamando a fetchAppointmentsForToday()');
      final appointments = await _appointmentApi.fetchAppointmentsForToday();
      print('fetchAppointmentsForToday devolvió ${appointments.length} citas');
      final List<Map<String, String>> fetchedPatients = [];

      for (var appointment in appointments) {
        print('— Procesando cita: $appointment');
        String imageUrl = '';
        try {
          final patientDetails = await _patientService.fetchPatientDetails(
              appointment['patientId']);
          print('fetchPatientDetails: $patientDetails');
          imageUrl = patientDetails['image'] ?? '';
        } catch (e) {
          print('error al traer detalles de paciente: $e');
        }
        fetchedPatients.add({
          'name': appointment['title'] ?? 'No name',
          'time': appointment['startTime'] ?? 'No start time',
          'endTime': appointment['endTime'] ?? 'No end time',
          'image': imageUrl,
          'eventDate': appointment['eventDate'] ?? 'No date',
          'patientId': appointment['patientId'].toString(),
          'title': appointment['title'] ?? 'No title',
          'description': appointment['description'] ?? 'No description',
          'color': appointment['color'] ?? '0xFF039BE5',
          'appointmentId': appointment['id'].toString(),
        });
      }

      print('Ordenando ${fetchedPatients.length} pacientes por hora');
      fetchedPatients.sort((a, b) {
        final aTime = a['time'] ?? '';
        final bTime = b['time'] ?? '';
        return aTime.compareTo(bTime);
      });
      print('Lista ordenada: $fetchedPatients');

      setState(() {
        patients = fetchedPatients;
        errorMessage = '';
        isLoading = false;
      });
      print('setState: pacientes cargados en pantalla (${patients.length})');
    } catch (e, stack) {
      print('Error en _fetchPatients: $e');
      print(stack);
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
        title: Text("Today's Meetings"),
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
            : patients.isEmpty
            ? Center(
          child: Text(
            'No tiene pacientes o Reuniones agendadas',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        )
            : ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final eventDate = tz.TZDateTime.from(
              DateTime.parse(patients[index]['eventDate']!),
              limaTimeZone,
            );
            final isPast = eventDate.isBefore(now);

            return Card(
              color: isPast ? Color(0xFFE8E4F3) : Color(0xFFF5F3FF),
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
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () {
                          // 1. Genera un enlace único de Jitsi usando el ID de la cita
                          final meetingLink = JitsiMeetingLinkGenerator.generateMeetingLink(
                            roomPrefix: patients[index]['appointmentId'],
                          );
                          // 2. Extrae el nombre de la sala (la última parte del path)
                          final uri = Uri.parse(meetingLink);
                          final roomName = uri.pathSegments.isNotEmpty
                              ? uri.pathSegments.last
                              : meetingLink;
                          // 3. Navega a tu pantalla de videollamada
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VideoCallPage(
                                roomName: roomName,
                                displayName: patients[index]['name']!,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFF6A828D),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.videocam, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                '${patients[index]['time']} - ${patients[index]['endTime']}',
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
                        radius: 12,
                        backgroundColor: Color(0xFF6A828D),
                        child: Center(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.info, color: Colors.white, size: 16),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppointmentDetail(
                                    appointmentId: int.parse(patients[index]['appointmentId']!),
                                  ),
                                ),
                              );
                              if (result == true) {
                                _fetchPatients();
                              }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final now = DateTime.now();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAppointmentScreen(selectedDate: now),
            ),
          );
          if (result == true) _fetchPatients();
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF6A828D),
      ),
    );
  }
}