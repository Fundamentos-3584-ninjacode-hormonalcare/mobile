import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFF0F0F0), // Fondo gris claro
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class CustomDateField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Código para mostrar el selector de fecha
        showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFF0F0F0), // Fondo gris claro
            labelText: 'Day',
            prefixIcon: Icon(Icons.calendar_today, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomHourField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Código para mostrar el selector de hora
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xEDECEC), // Fondo gris claro
            labelText: 'Hour',
            prefixIcon: Icon(Icons.access_time, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
