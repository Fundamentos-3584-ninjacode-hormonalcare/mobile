import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa la librería intl para formatear fechas
import '../../../medical_prescription/domain/models/patient_model.dart';
import '../../domain/models/medication_model.dart';
import '../../domain/models/prescription_model.dart';
import '../../domain/models/treatment_model.dart';
import '../../domain/services/medicalrecord_service.dart';

class MedicalRecordScreen extends StatefulWidget {
  final String patientId;

  const MedicalRecordScreen({required this.patientId});

  @override
  _MedicalRecordScreenState createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late Future<Patient> _patientFuture;
  late Future<List<Medication>> _medicationsFuture;
  late Future<List<Prescription>> _prescriptionsFuture;
  late Future<List<Treatment>> _treatmentsFuture; // Añadir Future para tratamientos
  final int medicalRecordId = 10; // Definir el medicalRecordId aquí

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // 5 pestañas en el TabBar
    _tabController.addListener(_handleTabSelection); // Añadimos un listener para manejar el cambio de pestañas
    _patientFuture = MedicalRecordService().getPatientById(widget.patientId);
    _medicationsFuture = MedicalRecordService().getMedicationsByRecordId(medicalRecordId); // Usar el medicalRecordId
    _prescriptionsFuture = MedicalRecordService().getPrescriptions(); // Obtener todas las prescripciones
    _treatmentsFuture = MedicalRecordService().getTreatmentsByRecordId(medicalRecordId); // Obtener tratamientos
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection); // Eliminamos el listener cuando ya no se necesite
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Función para manejar el desplazamiento del TabBar cuando se cambia de pestaña
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      double tabPosition = _tabController.index.toDouble();
      _scrollController.animateTo(
        tabPosition * 120,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Función para mostrar el menú flotante
  void _showPatientInfo(Patient patient) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_getImageUrl(patient.profile?.image)),
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    child: patient.profile?.image == null || patient.profile!.image.isEmpty
                        ? Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  SizedBox(height: 15),
                  _buildInfoField('Full name', patient.profile?.fullName ?? 'Unknown'),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildInfoField('Gender', patient.profile?.gender ?? 'Unknown')),
                      SizedBox(width: 10),
                      Expanded(child: _buildInfoField('Birthday', _formatDate(patient.profile?.birthday))),
                    ],
                  ),
                  SizedBox(height: 10),
                  _buildInfoField('Phone number', patient.profile?.phoneNumber ?? 'Unknown'),
                  SizedBox(height: 10),
                  _buildInfoField('Type of blood', patient.typeOfBlood),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Función para construir los campos de información
  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Función para formatear la fecha
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'Unknown';
    final parsedDate = DateTime.parse(date);
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  int calculateAge(String? birthday) {
    if (birthday == null) return 0;
    final birthDate = DateTime.parse(birthday);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Widget _buildPatientHeader(Patient patient) {
    return GestureDetector(
      onTap: () => _showPatientInfo(patient),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF4B5A62),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(_getImageUrl(patient.profile?.image)),
                  backgroundColor: Colors.blueGrey[200],
                  child: patient.profile?.image == null || patient.profile!.image.isEmpty
                      ? Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.profile?.fullName ?? 'Unknown',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              'Age: ${calculateAge(patient.profile?.birthday)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.black,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          Tab(text: 'Patient History'),
          Tab(text: 'Diagnosis & Treatments'),
          Tab(text: 'Medical Tests'),
          Tab(text: 'External Reports'),
          Tab(text: 'Consultation History'),
        ],
      ),
    );
  }

  Widget _buildTabBarView(Patient patient) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPatientHistoryTab(patient),
          _buildDiagnosisAndTreatmentsTab(medicalRecordId), // Usar el medicalRecordId
          _buildMedicalTestsTab(),
          _buildExternalReportsTab(),
          Center(child: Text('Consultation History content')),
        ],
      ),
    );
  }

  Widget _buildPatientHistoryTab(Patient patient) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Personal history:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          patient.personalHistory,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
        Text(
          'Family history:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          patient.familyHistory,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDiagnosisAndTreatmentsTab(int medicalRecordId) {
  return FutureBuilder<List<Medication>>(
    future: MedicalRecordService().getMedicationsByRecordId(medicalRecordId),
    builder: (context, medicationSnapshot) {
      if (medicationSnapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (medicationSnapshot.hasError) {
        return Center(child: Text('Error: ${medicationSnapshot.error}'));
      } else if (!medicationSnapshot.hasData || medicationSnapshot.data!.isEmpty) {
        return Center(child: Text('No medications found'));
      } else {
        final medications = medicationSnapshot.data!;

        return FutureBuilder<List<Prescription>>(
          future: MedicalRecordService().getPrescriptions(),
          builder: (context, prescriptionSnapshot) {
            if (prescriptionSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (prescriptionSnapshot.hasError) {
              return Center(child: Text('Error: ${prescriptionSnapshot.error}'));
            } else if (!prescriptionSnapshot.hasData || prescriptionSnapshot.data!.isEmpty) {
              return Center(child: Text('No prescriptions found'));
            } else {
              final allPrescriptions = prescriptionSnapshot.data!;
              final prescriptionIds = medications.map((med) => med.prescriptionId).toSet();
              final prescriptions = allPrescriptions.where((prescription) => prescriptionIds.contains(prescription.id)).toList();

              return FutureBuilder<List<Treatment>>(
                future: MedicalRecordService().getTreatmentsByRecordId(medicalRecordId),
                builder: (context, treatmentSnapshot) {
                  if (treatmentSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (treatmentSnapshot.hasError) {
                    return Center(child: Text('Error: ${treatmentSnapshot.error}'));
                  } else if (!treatmentSnapshot.hasData || treatmentSnapshot.data!.isEmpty) {
                    return Center(child: Text('No treatments found'));
                  } else {
                    final treatments = treatmentSnapshot.data!;

                    return ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        // Diagnosis Section
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Diagnosis',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              ...prescriptions.map((prescription) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _formatDate(prescription.prescriptionDate),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      prescription.notes,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        

                        // Medication Section
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medication',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Medication',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Concentration',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Unit',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Frequency',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              ...medications.map((medication) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        medication.drugName,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        medication.quantity,
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        medication.concentration,
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        medication.frequency,
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        

                        // Treatment Section
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Treatment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              ...treatments.map((treatment) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      treatment.description,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            }
          },
        );
      }
    },
  );
}




  Widget _buildMedicalTestsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildTestItem('Fasting Glucose Test', '18/04/24'),
        _buildTestItem('OGTT', '18/04/24'),
        _buildTestItem('ACTH test', '18/04/24'),
      ],
    );
  }

  Widget _buildTestItem(String testName, String date) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            testName,
            style: TextStyle(fontSize: 16),
          ),
          Row(
            children: [
              Text(
                date,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(width: 10),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.download, size: 24, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExternalReportsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildReportItem('18/04/24'),
        _buildReportItem('18/04/24'),
        _buildReportItem('22/04/24'),
        _buildReportItem('18/04/24'),
      ],
    );
  }

  Widget _buildReportItem(String date) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: TextStyle(fontSize: 16),
          ),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.download, size: 24, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text('Medical record'),
      ),
      body: FutureBuilder<Patient>(
        future: _patientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          } else {
            final patient = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientHeader(patient),
                  SizedBox(height: 20),
                  _buildTabBar(),
                  SizedBox(height: 20),
                  _buildTabBarView(patient),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Función para obtener la URL de la imagen
  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }
    if (!imageUrl.startsWith('http')) {
      return 'https://$imageUrl';
    }
    return imageUrl;
  }
}