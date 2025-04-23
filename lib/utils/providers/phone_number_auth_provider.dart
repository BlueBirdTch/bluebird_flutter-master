import 'package:bluebird/api/firestore_api.dart';
import 'package:flutter/material.dart';

class PhoneNumberAuth extends ChangeNotifier {
  static bool loading = false;
  FirestoreAPIService api = FirestoreAPIService();
  Future<String> checkPhoneNumber(String phoneNumber) async {
    setLoading(true);
    var response = await api.findUser('+91$phoneNumber');
    if (response == true) {
      setLoading(false);
      return 'login';
    } else {
      setLoading(false);
      return 'register';
    }
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }
}
