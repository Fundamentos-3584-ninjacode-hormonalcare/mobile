import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/pages/patients_list_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/medical_prescription/presentation/pages/patients_list_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/medical_prescription/presentation/pages/medical_prescription_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/pages/appointment_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/notifications/presentation/pages/notification_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/presentation/pages/doctor_profile_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/presentation/pages/patient_profile_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? role;

  static List<Widget> _widgetOptions = <Widget>[
    HomePatientsScreen(doctorId: 1,),
    PatientsListScreen(),
    AppointmentScreen(),
    NotificationsScreen(),
    DoctorProfileScreen(), // Placeholder, will be replaced dynamically
  ];

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final storedRole = await JwtStorage.getRole();
    setState(() {
      role = storedRole;
      _widgetOptions[4] = role == 'ROLE_DOCTOR' ? DoctorProfileScreen() : PatientProfileScreen();
    });
  }

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
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_2),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
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