import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/medical_prescription/domain/models/patient_model.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/medical_prescription/data/data_sources/local/patient_data_source.dart';

class GetPatientsUseCase {
  final PatientsDataSource dataSource = PatientsDataSource();

  List<Patient> execute() {
    return dataSource.getPatients();
  }
}
