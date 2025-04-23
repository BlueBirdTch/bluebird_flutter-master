// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/widgets/snackbars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirebaseStorageService {
  Future<bool> uploadVerificationDocuments() async {
    try {
      var role = AuthenticationDataProvider().getRole();
      var uid = AuthenticationService().getCurrentuserUID();
      var docId;
      List<Map<String, dynamic>> rcas = [];
      for (var i = 0; i < IdentityFormProvider.rcCard.length; i++) {
        var keyName = "rca_card_${i + 1}";
        rcas.add({
          keyName: {'front': '', 'back': ''}
        });
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).get().then((value) => docId = value['verificationDocuments']);
      String? selfie = await uploadImagetoFirebaseCloud('${uid}_selfie.${IdentityFormProvider.selfie?.path.split('.').last}', IdentityFormProvider.selfie!);
      String? aadharFront = await uploadImagetoFirebaseCloud('${uid}_aadhar_front.${IdentityFormProvider.aadharFront?.path.split('.').last}', IdentityFormProvider.aadharFront!);
      String? aadharBack = await uploadImagetoFirebaseCloud('${uid}_aadhar_back.${IdentityFormProvider.aadharBack?.path.split('.').last}', IdentityFormProvider.aadharBack!);
      String? panCard = await uploadImagetoFirebaseCloud('${uid}_pan_card.${IdentityFormProvider.panCard?.path.split('.').last}', IdentityFormProvider.panCard!);
      if (role == 'driver') {
        String? drivingLicenseFront =
            await uploadImagetoFirebaseCloud('${uid}_driving_license_front.${IdentityFormProvider.drivingLicenseFront?.path.split('.').last}', IdentityFormProvider.drivingLicenseFront!);
        String? drivingLicenseBack =
            await uploadImagetoFirebaseCloud('${uid}_driving_license_back.${IdentityFormProvider.drivingLicenseBack?.path.split('.').last}', IdentityFormProvider.drivingLicenseBack!);
        for (var i = 0; i < IdentityFormProvider.rcCard.length; i++) {
          rcas[i]['front'] = await uploadImagetoFirebaseCloud('${uid}_rca_${i + 1}_front', File(IdentityFormProvider.rcCard[i]['front']));
          rcas[i]['back'] = await uploadImagetoFirebaseCloud('${uid}_rca_${i + 1}_back', File(IdentityFormProvider.rcCard[i]['back']));
        }
        await FirebaseFirestore.instance.collection('documents').doc(docId).update({
          "selfie": FieldValue.arrayUnion([selfie]),
          "aadhar": FieldValue.arrayUnion([aadharFront, aadharBack]),
          "pan_card": FieldValue.arrayUnion([panCard]),
          "driving_license": FieldValue.arrayUnion([drivingLicenseFront, drivingLicenseBack]),
          "rca": rcas,
        });
        await FirebaseFirestore.instance.collection('users').doc(uid).update({"documentsSubmitted": true});
        return true;
      } else if (role == 'transporter') {
        String? tradeLicense = await uploadImagetoFirebaseCloud('${uid}_trade_license.${IdentityFormProvider.tradeLicense?.path.split('.').last}', IdentityFormProvider.tradeLicense!);
        await FirebaseFirestore.instance.collection('documents').doc(docId).update({
          "selfie": FieldValue.arrayUnion([selfie]),
          "aadhar": FieldValue.arrayUnion([aadharFront, aadharBack]),
          "pan_card": FieldValue.arrayUnion([panCard]),
          "trade_license": FieldValue.arrayUnion([tradeLicense]),
        });
        await FirebaseFirestore.instance.collection('users').doc(uid).update({"documentsSubmitted": true});
        return true;
      } else {
        return false;
      }
    } catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('A Server issue has occurred') as SnackBar);
      return false;
    }
  }

  Future<String?> uploadImagetoFirebaseCloud(String fileName, File imageFile) async {
    try {
      await firebase_storage.FirebaseStorage.instance.ref('user_documents/$fileName').putFile(imageFile);
      String url = await firebase_storage.FirebaseStorage.instance.ref('user_documents/$fileName').getDownloadURL();
      return url;
    } catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('File $fileName could not be uploaded') as SnackBar);
    }
    return null;
  }
}
