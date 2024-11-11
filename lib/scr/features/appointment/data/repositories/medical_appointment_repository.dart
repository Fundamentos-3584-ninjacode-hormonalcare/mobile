import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';

class MedicalAppointmentRepository {
  final MedicalAppointmentApi api;

  MedicalAppointmentRepository(this.api);

    Future<bool> createMedicalAppointment(Map<String, dynamic> appointmentData) async {
    final response = await api.createMedicalAppointment(appointmentData);
    // Asumiendo que el `response` tiene un campo `success` que indica el éxito
    return response['success'] == true;
  }

    Future<List<Map<String, dynamic>>> fetchAppointmentsForToday(int doctorId ) async {
    return await api.fetchAppointmentsForToday(doctorId);

  }
}