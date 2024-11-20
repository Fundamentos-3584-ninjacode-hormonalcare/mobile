import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/notifications/data/data_sources/remote/notifications_service.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  final int doctorId;

  NotificationScreen({required this.doctorId});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      List<Map<String, dynamic>> appointments = await _notificationService.fetchDoctorAppointments(widget.doctorId);
      DateTime now = DateTime.now();
      DateTime nowPlus30 = now.add(Duration(minutes: 30));

      setState(() {
        _appointments = appointments.where((appointment) {
          DateTime eventDate = DateFormat('yyyy-MM-dd').parse(appointment['eventDate']);
          TimeOfDay startTime = TimeOfDay(
            hour: int.parse(appointment['startTime'].split(':')[0]),
            minute: int.parse(appointment['startTime'].split(':')[1]),
          );
          DateTime appointmentStart = DateTime(eventDate.year, eventDate.month, eventDate.day, startTime.hour, startTime.minute);
          return appointmentStart.isAfter(now) && appointmentStart.isBefore(nowPlus30);
        }).toList();
      });
    } catch (e) {
      // Manejo de errores
    }
  }

  Future<void> _deleteAppointment(int appointmentId) async {
    try {
      await _notificationService.deleteAppointment(appointmentId);
      _fetchAppointments();
    } catch (e) {
      // Manejo de errores
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return Card(
            child: ListTile(
              title: Text(appointment['title']),
              subtitle: Text('${appointment['eventDate']} ${appointment['startTime']} - ${appointment['endTime']}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteAppointment(appointment['id']),
              ),
            ),
          );
        },
      ),
    );
  }
}
