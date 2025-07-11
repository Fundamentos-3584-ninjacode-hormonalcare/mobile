import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/patient_model.dart';
import '../widgets/patient_card.dart';
import '../../domain/models/services/patients_list_service.dart';

class PatientsListScreen extends StatefulWidget {
  final int doctorId;
  const PatientsListScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  _PatientsListScreenState createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  late final PatientsListService _patientsListService;
  late Future<List<Patient>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    _patientsListService = PatientsListService(client: http.Client());
    _loadPatients();
  }

  void _loadPatients() {
    print('Cargando pacientes para doctorId=${widget.doctorId}');
    _patientsFuture = _patientsListService.getPatients(widget.doctorId);
    _patientsFuture.then(
          (list) => print('Pacientes recibidos: ${list.length}'),
      onError: (e) => print('Error al cargar pacientes: $e'),
    );
  }

  Future<void> _onRefresh() async {
    _loadPatients();
    // Esperamos a la nueva lista antes de completar el refresh
    await _patientsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A828D),
        title: const Text('Pacientes'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<Patient>>(
          future: _patientsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No se encontraron pacientes'));
            }
            final patients = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 0.75,
              ),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                return PatientCard(patient: patients[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
