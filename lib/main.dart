import 'package:flutter/material.dart';
import './scr/features/medical_record/medical_prescription/presentation/pages/medical_prescription_screen.dart';
import './scr/features/appointment/presentation/pages/appointment_screen.dart';
import './scr/features/appointment/presentation/pages/patients_list_screen.dart';
import './scr/features/notifications/presentation/pages/notification_screen.dart';
import './scr/features/profile/presentation/pages/profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Care App',
      theme: ThemeData(
        primaryColor: Color(0xFF6A828D),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static  List<Widget> _widgetOptions = <Widget>[
    HomePatientsScreen(),
    ProfileScreen(),
    AppointmentScreen(),
    MedicalRecordScreen(),
    NotificationsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF6A828D),
        unselectedItemColor: Color(0xFF40535B),
        onTap: _onItemTapped,
      ),
    );
  }
}
