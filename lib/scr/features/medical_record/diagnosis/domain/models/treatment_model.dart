class Treatment {
  final String description;
  final int medicalRecordId;

  Treatment({required this.description, required this.medicalRecordId});

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      description: json['description'],
      medicalRecordId: json['medicalRecordId'],
    );
  }
}