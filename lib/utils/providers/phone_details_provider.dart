import 'package:flutter/material.dart';

class AuthenticationInfoProvider extends ChangeNotifier {
  static String phoneNumber = '';
  static String type = '';
  void setPhoneNumber(String phone) {
    phoneNumber = phone;
    notifyListeners();
  }

  void setLoginType(String login) {
    type = login;
    notifyListeners();
  }
}
