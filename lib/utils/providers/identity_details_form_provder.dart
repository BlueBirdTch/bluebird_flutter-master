import 'dart:io';

import 'package:flutter/material.dart';

class IdentityFormProvider extends ChangeNotifier {
  static bool loading = false;
  static File? selfie;
  static File? aadharFront;
  static File? aadharBack;
  static File? panCard;
  static File? tradeLicense;
  static File? drivingLicenseFront;
  static File? drivingLicenseBack;
  static List<Map<String, dynamic>> rcCard = [];

  void setSelfie(String path) {
    selfie = File(path);
    notifyListeners();
  }

  void setAadharFront(String path) {
    aadharFront = File(path);
    notifyListeners();
  }

  void setAadharBack(String path) {
    aadharBack = File(path);
    notifyListeners();
  }

  void setPanCard(String path) {
    panCard = File(path);
    notifyListeners();
  }

  void settradeLicense(String path) {
    tradeLicense = File(path);
    notifyListeners();
  }

  void setdrivingLicenseFront(String path) {
    drivingLicenseFront = File(path);
    notifyListeners();
  }

  void setdrivingLicenseBack(String path) {
    drivingLicenseBack = File(path);
    notifyListeners();
  }

  void initRCCard(int len) {
    if (rcCard.isEmpty) {
      for (var i = 0; i < len; i++) {
        var keyName = "rca_card_${i + 1}";
        rcCard.add({
          keyName: {'front': '', 'back': ''}
        });
      }
      notifyListeners();
    }
  }

  void setrcCard(String path, bool front, int index) {
    rcCard[index][front ? 'front' : 'back'] = path;
    notifyListeners();
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  void deleteRCPath(bool front, int index) {
    rcCard[index][front ? 'front' : 'back'] = null;
    notifyListeners();
  }

  void clearAll() async {
    await selfie?.delete();
    await aadharFront?.delete();
    await aadharBack?.delete();
    await panCard?.delete();
    await tradeLicense?.delete();
    await drivingLicenseFront?.delete();
    await drivingLicenseBack?.delete();
    rcCard.clear();
  }
}
