class PatientModel {
  final int profileId;

  PatientModel({required this.profileId});

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(profileId: json['profileId']);
  }
}

class ProfileModel {
  final String phoneNumber;

  ProfileModel({required this.phoneNumber});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(phoneNumber: json['phoneNumber']);
  }
}