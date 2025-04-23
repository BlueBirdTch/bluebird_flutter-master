import 'package:bluebird/api/firestore_api.dart';
import 'package:flutter/material.dart';

class IdentityProvider extends ChangeNotifier {
  static bool loading = false;
  FirestoreAPIService api = FirestoreAPIService();

  Future postIdentityDetails(Map<String, dynamic> data) async {
    setLoading(true);
    var response = await api.postIdentityForm(data);
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
