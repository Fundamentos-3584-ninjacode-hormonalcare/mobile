import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/diagnosis/presentation/pages/consultation_screen.dart';

class HomePatientsScreen extends StatelessWidget {
  final List<Map<String, String>> patients = [
    {'name': 'Ana María López', 'time': '12:30 P.M.'},
    {'name': 'Mario Fernández', 'time': '13:30 P.M.'},
    {'name': 'Jair Loaiza', 'time': '14:30 P.M.'},
    {'name': 'Esteban Pizarro', 'time': '15:30 P.M.'},
    {'name': 'Rodrigo Irigoyen', 'time': '16:30 P.M.'},
    {'name': 'Gabriel Santos', 'time': '17:30 P.M.'},
  ];

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          return Card(
            color: Color(0xFFE0E0E0),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
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
                    backgroundColor: Color(0xFF6A828D),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              title: Text(
                patients[index]['name']!,
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF40535B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      patients[index]['time']!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}