import 'package:bluebird/api/firestore_api.dart';
import 'package:flutter/material.dart';

class TripProvider extends ChangeNotifier {
  static bool loading = false;
  String cargo = '', type = '';
  Future createTrip(Object data) async {
    setLoading(true);
    bool response = await FirestoreAPIService().createTrip(data);
    if (response) {
      setLoading(false);
      return true;
    } else {
      setLoading(false);
      return false;
    }
  }

  Future joinTrip(String tripId, Map<String, dynamic> data, int loading, int unloading) async {
    setLoading(true);
    bool response = await FirestoreAPIService().joinTrip(tripId, data, loading, unloading);
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
