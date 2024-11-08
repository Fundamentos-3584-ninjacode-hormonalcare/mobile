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
  Color _selectedColor = Color(0xFF039BE5); // Default color
  CalendarView _calendarView = CalendarView.week; // Default calendar view
  late MeetingDataSource calendarDataSource; // Añadido aquí

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
    _loadAppointments();
    _loadPatients();
    calendarDataSource = MeetingDataSource(_meetings); 
  }

 Future<void> _loadAppointments() async {
  try {
    final appointments = await _appointmentService.fetchAllAppointments();
    final List<Meeting> loadedMeetings = appointments.map<Meeting>((appointment) {
      final startTime = DateTime.parse('${appointment['eventDate']}T${appointment['startTime']}:00');
      final endTime = DateTime.parse('${appointment['eventDate']}T${appointment['endTime']}:00');
      final colorValue = appointment['color'] ?? '0xFF039BE5';
      final color = Color(int.parse(colorValue.startsWith('0x') ? colorValue : '0x$colorValue'));

      return Meeting(
        appointment['title'],
        startTime,
        endTime,
        color,
        false,
        appointment['description'],
        appointment['id'].toString(),
      );
    }).toList();

    setState(() {
      _meetings.clear();
      _meetings.addAll(loadedMeetings);
      calendarDataSource = MeetingDataSource(_meetings); // Refresca calendarDataSource
    });
  } 
  catch (e) {
    print('Error loading appointments: $e');
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

  
  Future<void> _updateAppointment(Meeting meeting) async {
    try {
      print('Updating appointment with ID: ${meeting.id}');
      print('Start time: ${meeting.from.toIso8601String().split('T')[0]} ${meeting.from.hour.toString().padLeft(2, '0')}:${meeting.from.minute.toString().padLeft(2, '0')}');
      print('End time: ${meeting.to.hour.toString().padLeft(2, '0')}:${meeting.to.minute.toString().padLeft(2, '0')}');
      print('Event name: ${meeting.eventName}');
      print('Description: ${meeting.description}');
      print('Doctor ID: ${await _appointmentService.getDoctorId()}');
      print('Patient ID: $_selectedPatientId');
      print('Color: ${meeting.background.value.toRadixString(16)}');

      final success = await _appointmentService.updateMedicalAppointment(
        meeting.id, 
        meeting.from.toIso8601String().split('T')[0],
        '${meeting.from.hour.toString().padLeft(2, '0')}:${meeting.from.minute.toString().padLeft(2, '0')}',
        '${meeting.to.hour.toString().padLeft(2, '0')}:${meeting.to.minute.toString().padLeft(2, '0')}',
        meeting.eventName,
        meeting.description,
        await _appointmentService.getDoctorId(),
        _selectedPatientId!,
        meeting.background.value.toRadixString(16),
      );

      if (success) {
        await _loadAppointments();  

        setState(() {}); 

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update appointment')),
        );
      }
    } catch (e) {
    print('Error updating appointment: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update appointment: $e')),
    );
  }
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    try {
      final success = await _appointmentService.deleteMedicalAppointment(appointmentId);
      if (success) {
        await _loadAppointments(); 

        setState(() {}); 

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete appointment')),
        );
      }
    } catch (e) {
      print('Error deleting appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D), 
        title: Text('Medical Appointments'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          DropdownButton<CalendarView>(
            value: _calendarView,
            onChanged: (CalendarView? newValue) {
              setState(() {
                _calendarView = newValue!;
              });
            },
            items: CalendarView.values.map((CalendarView view) {
              return DropdownMenuItem<CalendarView>(
                value: view,
                child: Text(view.toString().split('.').last),
              );
            }).toList(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                width: constraints.maxWidth, 
                height: constraints.maxHeight, 
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SfCalendar(
                  view: _calendarView,
                  dataSource: calendarDataSource, // Cambiado aquí para usar calendarDataSource
                  onTap: _calendarTapped,
                  onDragEnd: (AppointmentDragEndDetails details) {
                    if (details.appointment != null) {
                      final Meeting meeting = details.appointment as Meeting;
                      _updateAppointment(meeting);
                    }
                  },
                  onAppointmentResizeEnd: (AppointmentResizeEndDetails details) {
                    if (details.appointment != null) {
                      final Meeting meeting = details.appointment as Meeting;
                      _updateAppointment(meeting);
                    }
                  },
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
    if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
      final Meeting meeting = details.appointments!.first as Meeting;
      _showEventDetailsDialog(meeting);
    } else if (details.targetElement == CalendarElement.calendarCell) {
      _showAddEventDialog(details.date!, details.appointments);
    }
  }
  
    void _showEventDetailsDialog(Meeting meeting) {
    final TextEditingController titleController = TextEditingController(text: meeting.eventName);
    final TextEditingController descriptionController = TextEditingController(text: meeting.description);
    final TextEditingController startTimeController = TextEditingController(
      text: '${meeting.from.hour.toString().padLeft(2, '0')}:${meeting.from.minute.toString().padLeft(2, '0')}',
    );
    final TextEditingController endTimeController = TextEditingController(
      text: '${meeting.to.hour.toString().padLeft(2, '0')}:${meeting.to.minute.toString().padLeft(2, '0')}',
    );
  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Event Details'),
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
                  decoration: const InputDecoration(labelText: 'Choose a Color'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final String title = titleController.text;
                final String description = descriptionController.text;
                final DateTime startTime = DateTime(
                  meeting.from.year,
                  meeting.from.month,
                  meeting.from.day,
                  int.parse(startTimeController.text.split(':')[0]),
                  int.parse(startTimeController.text.split(':')[1]),
                );
                final DateTime endTime = DateTime(
                  meeting.to.year,
                  meeting.to.month,
                  meeting.to.day,
                  int.parse(endTimeController.text.split(':')[0]),
                  int.parse(endTimeController.text.split(':')[1]),
                );
  
                if (_selectedPatientId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please choose a patient')),
                  );
                  return;
                }
  
                final updatedMeeting = Meeting(
                  title,
                  startTime,
                  endTime,
                  _selectedColor,
                  meeting.isAllDay,
                  description,
                  meeting.id,
                );
  
                await _updateAppointment(updatedMeeting);
  
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteAppointment(meeting.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEventDialog(DateTime date, List<dynamic>? appointments) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController startTimeController = TextEditingController();
    final TextEditingController endTimeController = TextEditingController();

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
                  decoration: const InputDecoration(labelText: 'Choose a Color'),
                ),
              ],
            ),
          ),
          actions: [
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
                  'color': _selectedColor.value.toRadixString(16), // Save color as hex string
                };

                try {
                  final success = await _appointmentService.createMedicalAppointment(appointmentData);
                  if (success == true) {
                    await _loadAppointments(); 
                    setState(() {
                      calendarDataSource = MeetingDataSource(_meetings);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Appointment created successfully!')),
                    );
                  }
                } catch (e) {
                  print('Error creating appointment: $e');
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
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay, this.description, this.id);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String description;
  String id; // Assuming 'id' is the unique identifier for the appointment
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