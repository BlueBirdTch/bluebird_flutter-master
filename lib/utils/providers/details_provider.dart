import 'package:bluebird/api/firestore_api.dart';
import 'package:flutter/material.dart';

class DetailsAddProvider with ChangeNotifier {
  static bool loading = false;
  FirestoreAPIService api = FirestoreAPIService();
  Future postDetails(Map<String, dynamic> data) async {
    setLoading(true);
    notifyListeners();
    var response = await api.postDetailsForm(data);
    if (response) {
      setLoading(false);
      notifyListeners();
      return true;
    } else {
      setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void setLoading(bool value) {
    loading = value;
  }
}
