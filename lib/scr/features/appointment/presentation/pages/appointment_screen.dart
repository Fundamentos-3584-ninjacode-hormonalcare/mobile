import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final List<Meeting> _meetings = <Meeting>[];
  final MedicalAppointmentApi _appointmentService = MedicalAppointmentApi();
  List<Map<String, dynamic>> _patients = [];
  int? _selectedPatientId;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _loadPatients();
  }

  Future<void> _loadAppointments() async {
    try {
      final appointments = await _appointmentService.fetchAllAppointments();
      setState(() {
        _meetings.clear();
        for (var appointment in appointments) {
          final DateTime startTime = DateTime.parse('${appointment['eventDate']}T${appointment['startTime']}:00');
          final DateTime endTime = DateTime.parse('${appointment['eventDate']}T${appointment['endTime']}:00');
          _meetings.add(Meeting(
            appointment['title'],
            startTime,
            endTime,
            Colors.blue,
            false,
            appointment['description'],
          ));
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointments: $e')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D), // Color de la AppBar
        title: Text('Medical Appointments'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
              width: constraints.maxWidth * 0.9, // Ajusta el ancho según tus necesidades
              height: constraints.maxHeight * 0.8,// Ajusta la altura según tus necesidades
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SfCalendar(
                view: CalendarView.week,
                dataSource: MeetingDataSource(_meetings),
                onTap: _calendarTapped,
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

  void _calendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell ||
        details.targetElement == CalendarElement.appointment) {
      _showAddEventDialog(details.date!, details.appointments);
    }
  }

  void _showAddEventDialog(DateTime date, List<dynamic>? appointments) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController startTimeController = TextEditingController();
    final TextEditingController endTimeController = TextEditingController();

    // Precargar las horas seleccionadas
    final DateTime startTime = date;
    final DateTime endTime = date.add(Duration(hours: 1));
    startTimeController.text = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    endTimeController.text = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(labelText: 'Start Time (HH:MM)'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [TimeTextInputFormatter()],
                ),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(labelText: 'End Time (HH:MM)'),
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
                  decoration: const InputDecoration(labelText: 'Choose a Patient'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final String title = titleController.text;
                final String description = descriptionController.text;
                final DateTime startTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  int.parse(startTimeController.text.split(':')[0]),
                  int.parse(startTimeController.text.split(':')[1]),
                );
                final DateTime endTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  int.parse(endTimeController.text.split(':')[0]),
                  int.parse(endTimeController.text.split(':')[1]),
                );

                if (_selectedPatientId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please choose a patient')),
                  );
                  return;
                }

                final appointmentData = {
                  'eventDate': date.toIso8601String().split('T')[0],
                  'startTime': startTimeController.text, // Formato HH:MM
                  'endTime': endTimeController.text, // Formato HH:MM
                  'title': title,
                  'description': description,
                  'doctorId': await _appointmentService.getDoctorId(),
                  'patientId': _selectedPatientId,
                };

                try {
                  final success = await _appointmentService.createMedicalAppointment(appointmentData);
                  if (success) {
                    setState(() {
                      _meetings.add(Meeting(title, startTime, endTime, Colors.blue, false, description));
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Appointment created successfully!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create appointment: $e')),
                  );
                }

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String getNotes(int index) {
    return appointments![index].description;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay, this.description);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String description;
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