import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/shared/presentation/widgets/custom_widgets.dart';  // Importamos los widgets personalizados

class AppointmentForm extends StatefulWidget {
  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  void _clearFields() {
    _dateController.clear();
    _timeController.clear();
    _linkController.clear();
    _emailController.clear();
    _titleController.clear();
  }

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      // Acción para crear evento
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF40535B),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            dialogBackgroundColor: Color(0xFFAEBBC3), // Color verde claro
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 200, 200, 200), // Fondo gris claro
                        labelText: 'Day',
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            dialogBackgroundColor: Color(0xFFAEBBC3), // Color verde claro
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _timeController.text = pickedTime.format(context);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 200, 200, 200), // Fondo gris claro
                        labelText: 'Hour',
                        prefixIcon: Icon(Icons.access_time, color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Meeting',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF40535B),
            ),
          ),
          TextFormField(
            controller: _linkController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(255, 200, 200, 200), // Fondo gris claro
              labelText: 'Link',
              prefixIcon: Icon(Icons.language, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a link';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          Text(
            'Contact',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF40535B),
            ),
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(255, 200, 200, 200), // Fondo gris claro
              labelText: 'Patient\'s email',
              prefixIcon: Icon(Icons.email, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          Text(
            'Title',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF40535B),
            ),
          ),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(255, 200, 200, 200), // Fondo gris claro
              labelText: 'Title of the meeting',
              prefixIcon: Icon(Icons.title, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _clearFields,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFAEBBC3), // Botón "Clear" con color gris
                  ),
                  child: Text('Clear', style: TextStyle(color: Colors.black)),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _createEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF40535B), // Botón "Create event" con el color principal
                  ),
                  child: Text('Create event', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}