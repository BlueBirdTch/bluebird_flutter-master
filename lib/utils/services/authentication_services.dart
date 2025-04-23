import 'package:bluebird/config/routes.dart';
import 'package:bluebird/widgets/snackbars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? userLoggedIn() {
    User? currentLoggedInUser;
    try {
      currentLoggedInUser = _firebaseAuth.currentUser;
      if (currentLoggedInUser == null) {
        return AppRoutes.phoneNumberPage;
      } else {
        return AppRoutes.authChecker;
      }
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar(error.code.replaceAll('-', ' ')) as SnackBar);
    }
    return null;
  }

  String getCurrentuserUID() {
    return _firebaseAuth.currentUser!.uid;
  }

  Future<bool> authenticateCredential(AuthCredential credential) async {
    try {
      await _firebaseAuth.signInWithCredential(credential);
      return true;
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar(error.code.replaceAll('-', ' ')) as SnackBar);
    }
    return false;
  }

  Future<void> setNotificationToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).set({'fcmTokens': token}, SetOptions(merge: true));
  }

  Future<void> removeNotificationToken() async {
    await FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).set({'fcmTokens': ''}, SetOptions(merge: true));
  }

  Future<void> signOutUser() async {
    await removeNotificationToken();
    _firebaseAuth.signOut();
  }

  User? getUser() {
    return _firebaseAuth.currentUser;
  }
}
