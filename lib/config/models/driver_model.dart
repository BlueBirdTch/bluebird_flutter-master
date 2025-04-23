class DriverModel {
  final String createdAt;
  final bool signUpCompleted;
  final bool documentsVerified;
  final bool documentsSubmitted;
  final bool detailsSubmitted;
  final bool identitySubmitted;
  final String fullName;
  final String phone;
  final String dateOfBirth;
  final List<String> roles;
  final String fcmTokens;
  final List<String> pastJobs;
  final String verificationDocuments;
  final bool onJob;
  DriverModel({
    required this.createdAt,
    required this.signUpCompleted,
    required this.documentsVerified,
    required this.documentsSubmitted,
    required this.detailsSubmitted,
    required this.identitySubmitted,
    required this.fullName,
    required this.phone,
    required this.dateOfBirth,
    required this.roles,
    required this.fcmTokens,
    required this.pastJobs,
    required this.verificationDocuments,
    required this.onJob,
  });
  //Write a factory type return function for DriverModel.fromJson with all the required feilds being fetched from json[field]
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      createdAt: json['createdAt'],
      signUpCompleted: json['signUpCompleted'],
      documentsVerified: json['documentsVerified'],
      documentsSubmitted: json['documentsSubmitted'],
      detailsSubmitted: json['detailsSubmitted'],
      identitySubmitted: json['identitySubmitted'],
      fullName: json['fullName'],
      phone: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'],
      roles: List<String>.from(json['roles']),
      fcmTokens: json['fcmTokens'],
      pastJobs: List<String>.from(json['pastJobs']),
      verificationDocuments: json['verificationDocuments'],
      onJob: json['onJob'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['signUpCompleted'] = signUpCompleted;
    data['documentsVerified'] = documentsVerified;
    data['documentsSubmitted'] = documentsSubmitted;
    data['detailsSubmitted'] = detailsSubmitted;
    data['identitySubmitted'] = identitySubmitted;
    data['fullName'] = fullName;
    data['phoneNumber'] = phone;
    data['dateOfBirth'] = dateOfBirth;
    data['roles'] = roles;
    data['fcmTokens'] = fcmTokens;
    data['pastJobs'] = pastJobs;
    data['verificationDocuments'] = verificationDocuments;
    data['onJob'] = onJob;
    return data;
  }
}
