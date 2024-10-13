class Prescription {
  final int id;
  final int? doctorId;
  final int? patientId;
  final String prescriptionDate;
  final String notes;

  Prescription({
    required this.id,
    this.doctorId,
    this.patientId,
    required this.prescriptionDate,
    required this.notes,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      doctorId: json['doctorId'],
      patientId: json['patientId'],
      prescriptionDate: json['prescriptionDate'],
      notes: json['notes'],
    );
  }
}