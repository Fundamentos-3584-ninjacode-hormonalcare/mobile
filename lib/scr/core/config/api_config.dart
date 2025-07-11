class ApiConfig {
  // Cambia esta URL según tu entorno de desarrollo
  // Para desarrollo local: 'http://localhost:8080'
  // Para otros desarrolladores: 'http://10.0.1.x:8080' (donde x es su IP)
  //static const String baseUrl = 'http://localhost:8080';
  static const String baseUrl = 'https://backend-production-e47e.up.railway.app';
  
  // Endpoints base
  static const String apiV1 = '$baseUrl/api/v1';
  
  // Endpoints específicos
  static const String authentication = '$apiV1/authentication';
  static const String profile = '$apiV1/profile';
  static const String patient = '$apiV1/patient';
  static const String doctor = '$apiV1/doctor';
  static const String medicalAppointment = '$apiV1/medicalAppointment';
  static const String medicalRecord = '$apiV1/medical-record';
  static const String notifications = '$apiV1/notifications';
  
  // Medical Record endpoints
  static const String medicalRecordPatient = '$medicalRecord/patient';
  static const String medicalRecordMedications = '$medicalRecord/medications';
  static const String medicalRecordPrescriptions = '$medicalRecord/medications/prescriptions';
  static const String medicalRecordTreatments = '$medicalRecord/treatments';
  static const String medicalRecordTreatmentsByRecord = '$medicalRecord/treatments/medicalRecordId';
  static const String medicalRecordMedicationTypes = '$medicalRecord/medications/medicationTypes';
} 