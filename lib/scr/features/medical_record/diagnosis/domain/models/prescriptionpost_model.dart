class PrescriptionPost {
  int doctorId;
  int patientId;
  String prescriptionDate;
  String notes;

  PrescriptionPost({
    this.doctorId = 0,
    this.patientId = 0,
    required this.prescriptionDate,
    required this.notes,
  });

  factory PrescriptionPost.fromJson(Map<String, dynamic> json) {
    return PrescriptionPost(
      doctorId: json['doctorId'] ?? 0,
      patientId: json['patientId'] ?? 0,
      prescriptionDate: json['prescriptionDate'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'prescriptionDate': prescriptionDate,
      'notes': notes,
    };
  }
}