import 'dart:convert';

import 'package:bluebird/api/firestore_api.dart';
import 'package:bluebird/config/models/driver_model.dart';
import 'package:bluebird/config/models/transporter_model.dart';
import 'package:flutter/material.dart';

class AuthenticationDataProvider extends ChangeNotifier {
  static DriverModel? fireUserDataDriver;
  static TransporterModel? fireUserTransporter;
  static String role = '';
  final FirestoreAPIService _api = FirestoreAPIService();
  Future getUserDocument() async {
    var response = await _api.getUserData();
    if (response != null) {
      if (response.toString().contains('roles')) {
        if (jsonDecode(jsonEncode(response))['roles'][0] == 'driver') {
          setRole('driver');
          fireUserDataDriver = DriverModel.fromJson(jsonDecode(jsonEncode(response)));
          return true;
        } else if (jsonDecode(jsonEncode(response))['roles'][0] == 'transporter') {
          setRole('transporter');
          fireUserTransporter = TransporterModel.fromJson(jsonDecode(jsonEncode(response)));
          return true;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  void setRole(String value) {
    role = value;
    notifyListeners();
  }

  String getRole() {
    return role;
  }
}
