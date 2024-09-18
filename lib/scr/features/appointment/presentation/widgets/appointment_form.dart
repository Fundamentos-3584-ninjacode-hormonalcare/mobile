import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/shared/presentation/widgets/custom_widgets.dart';  // Importamos los widgets personalizados

class AppointmentForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
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
            Expanded(child: CustomDateField()),
            SizedBox(width: 16),
            Expanded(child: CustomHourField()),
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
          CustomTextField(label: 'Link', icon: Icons.language),
          SizedBox(height: 16),
          Text(
            'Contact',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF40535B),
            ),
          ),
          CustomTextField(label: 'Patient\'s email', icon: Icons.email),
          SizedBox(height: 16),
          Text(
            'Title',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF40535B),
            ),
          ),
          CustomTextField(label: 'Title of the meeting', icon: Icons.title),
          SizedBox(height: 24),
        Row(
               children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Acción para limpiar campos
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFAEBBC3), // Botón "Clear" con color gris
            ),
            child: Text('Clear', style: TextStyle(color: Colors.black)),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Acción para crear evento
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF40535B), // Botón "Create event" con el color principal
            ),
            child: Text('Create event', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
        ),
      ],
    );
  }
}
