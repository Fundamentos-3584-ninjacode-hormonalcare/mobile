import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/repositories/medical_appointment_repository.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/widgets/custom_buttons.dart';
import 'package:confetti/confetti.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AppointmentForm extends StatefulWidget {
  final int patientId;

  AppointmentForm({required this.patientId});

  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fromTimeController = TextEditingController();
  final TextEditingController _toTimeController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController();

  DateTime? _selectedDate;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

  final MedicalAppointmentRepository repository = MedicalAppointmentRepository(MedicalAppointmentApi());

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  void _clearFields() {
    _dateController.clear();
    _fromTimeController.clear();
    _toTimeController.clear();
    _linkController.clear();
    _titleController.clear();
    _selectedDate = null;
    _fromTime = null;
    _toTime = null;
  }

  Future<void> _createEvent() async {
    if (_formKey.currentState!.validate()) {
      final appointmentData = {
        'eventDate': _selectedDate!.toIso8601String().split('T')[0],
        'startTime': _fromTime!.format(context),
        'endTime': _toTime!.format(context),
        'title': _titleController.text,
        'description': _linkController.text,
        'doctorId': 1,
        'patientId': widget.patientId,
      };

      final success = await repository.createMedicalAppointment(appointmentData);
      if (success) {
        Navigator.pop(context);
        _confettiController.play();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medical appointment created successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create medical appointment.')));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller, bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          _fromTime = picked;
        } else {
          _toTime = picked;
        }
        controller.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final limaTimeZone = tz.getLocation('America/Lima');
    final now = tz.TZDateTime.now(limaTimeZone);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Field: Meeting Title
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'Title of the meeting',
              prefixIcon: Icon(Icons.title),
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            style: TextStyle(fontSize: 14),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the title of the meeting';
              }
              return null;
            },
          ),
          SizedBox(height: 12),

          // Field: Date
          TextFormField(
            controller: _dateController,
            decoration: InputDecoration(
              labelText: 'Date',
              hintText: 'Day',
              prefixIcon: Icon(Icons.calendar_today),
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            style: TextStyle(fontSize: 14),
            readOnly: true,
            onTap: () => _selectDate(context),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a date';
              }
              if (_selectedDate != null) {
                final selectedDateInLima = tz.TZDateTime.from(_selectedDate!, limaTimeZone);
                final nowInLima = tz.TZDateTime.now(limaTimeZone);
                if (selectedDateInLima.isBefore(nowInLima.subtract(Duration(days: 1)))) {
                  return 'The date cannot be in the past';
                }
              }
              return null;
            },
          ),
          SizedBox(height: 12),

          // Field: Time "From"
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _fromTimeController,
                  decoration: InputDecoration(
                    labelText: 'From',
                    hintText: 'Hour',
                    prefixIcon: Icon(Icons.access_time),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                  readOnly: true,
                  onTap: () => _selectTime(context, _fromTimeController, true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a start time';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12),

              // Field: Time "To"
              Expanded(
                child: TextFormField(
                  controller: _toTimeController,
                  decoration: InputDecoration(
                    labelText: 'To',
                    hintText: 'Hour',
                    prefixIcon: Icon(Icons.access_time),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                  readOnly: true,
                  onTap: () => _selectTime(context, _toTimeController, false),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an end time';
                    }
                    if (_fromTime != null && _toTime != null) {
                      final from = DateTime(0, 0, 0, _fromTime!.hour, _fromTime!.minute);
                      final to = DateTime(0, 0, 0, _toTime!.hour, _toTime!.minute);
                      if (to.isBefore(from)) {
                        return 'End time must be after start time';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Field: Meeting Link
          TextFormField(
            controller: _linkController,
            decoration: InputDecoration(
              labelText: 'Meeting Link',
              hintText: 'Link',
              prefixIcon: Icon(Icons.link),
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            style: TextStyle(fontSize: 14),
            keyboardType: TextInputType.url,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the meeting link';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Custom buttons (Clear and Create event)
          CustomButtons(
            onClear: _clearFields,
            onCreate: _createEvent,
          ),

          // Confetti animation
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ],
      ),
    );
  }
}