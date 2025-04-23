import 'package:bluebird/utils/services/firebase_storage_service.dart';
import 'package:flutter/material.dart';

class UploadFilesProvider extends ChangeNotifier {
  static bool loading = false;
  Future uploadImageFiles() async {
    setLoading(true);
    var response = await FirebaseStorageService().uploadVerificationDocuments();
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
