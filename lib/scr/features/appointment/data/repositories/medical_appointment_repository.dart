import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/domain/models/patient_model.dart';


class MedicalAppointmentRepository {
  final MedicalAppointmentApi api;

  MedicalAppointmentRepository(this.api);

  Future<int?> getPatientIdByPhoneNumber(String phoneNumber) async {
    for (int i = 1; i <= 7; i++) {
      final patient = await api.getPatient(i);
      if (patient != null) {
        final profile = await api.getProfile(patient.profileId);
        if (profile != null && profile.phoneNumber == phoneNumber) {
          return i;
        }
      }
    }
    return null;
  }

  Future<bool> createMedicalAppointment(Map<String, dynamic> appointmentData) {
    return api.createMedicalAppointment(appointmentData);
  }
}