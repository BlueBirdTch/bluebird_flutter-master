import 'package:bluebird/api/firestore_api.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisterUserProvider extends ChangeNotifier {
  static bool loading = false;
  Future<bool> createUserDoc(String role) async {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm');
    var time = formatter.format(now);
    setLoading(true);
    Object data = role == 'driver'
        ? {
            'createdAt': time,
            'signUpCompleted': true,
            'documentsVerified': false,
            'documentsSubmitted': false,
            'detailsSubmitted': false,
            'identitySubmitted': false,
            'fullName': '',
            'phoneNumber': AuthenticationInfoProvider.phoneNumber,
            'dateOfBirth': '',
            'roles': [role],
            'fcmTokens': '',
            'activeJobs': [],
            'pastJobs': [],
            'verificationDocuments': '',
            'onJob': false,
          }
        : {
            'createdAt': time,
            'signUpCompleted': true,
            'documentsVerified': false,
            'documentsSubmitted': false,
            'detailsSubmitted': false,
            'identitySubmitted': false,
            'fullName': '',
            'phoneNumber': AuthenticationInfoProvider.phoneNumber,
            'dateOfBirth': '',
            'roles': [role],
            'fcmTokens': '',
            'activeJobs': [],
            'pastJobs': [],
            'verificationDocuments': '',
          };
    bool response = await FirestoreAPIService().createUser(data);
    if (response) {
      setLoading(false);
      return true;
    } else {
      setLoading(false);
      return false;
    }
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }
}
