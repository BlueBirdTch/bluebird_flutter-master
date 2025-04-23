// ignore_for_file: body_might_complete_normally_catch_error

import 'package:bluebird/utils/providers/authentication_data_provider.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirestoreAPIService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<bool> createUser(data) async {
    CollectionReference users = _firestore.collection('users');
    try {
      await users.doc(AuthenticationService().getCurrentuserUID()).set(data);
      return true;
    } catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('Error! Please try again') as SnackBar);
      return false;
    }
  }

  Future<bool> findUser(String phoneNumber) async {
    CollectionReference users = _firestore.collection('users');
    var response = await users.where('phoneNumber', isEqualTo: phoneNumber).get().catchError(
      (error) {
        ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('Error! Please try again') as SnackBar);
      },
    );
    if (response.size > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<Object?> getUserData() async {
    CollectionReference users = _firestore.collection('users');
    try {
      var response = await users.doc(AuthenticationService().getCurrentuserUID()).get();
      return response.data();
    } catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('Error! Please try again') as SnackBar);
      return null;
    }
  }

  Future<bool> postDetailsForm(Map<String, dynamic> data) async {
    var uid = AuthenticationService().getCurrentuserUID();
    CollectionReference users = _firestore.collection('users');
    try {
      await users.doc(uid).collection('addresses').add({
        'address_line': data['address_line'],
        'landmark': data['landmark'],
        'city_state': data['city_state'],
        'pincode': data['pincode'],
      });
      var docs = await users.doc(uid).collection('addresses').get();
      await users.doc(uid).update({
        "detailsSubmitted": true,
        "addresses": FieldValue.arrayUnion([docs.docs[0].id]),
        "fullName": data['fullName'],
        "dateOfBirth": data['dateOfBirth'],
      });
      return true;
    } catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('Error! Please try again') as SnackBar);
      return false;
    }
  }

  Future<bool> postIdentityForm(Map<String, dynamic> data) async {
    var uid = AuthenticationService().getCurrentuserUID();
    CollectionReference users = _firestore.collection('users');
    CollectionReference documents = _firestore.collection('documents');
    try {
      await documents.add(
        {
          "uid": uid,
          "verified": false,
          "details": data["details"],
        },
      );
      var docId = await documents.where("uid", isEqualTo: uid).get();
      if (AuthenticationDataProvider().getRole() == 'transporter') {
        await users.doc(uid).update({'verificationDocuments': docId.docs.first.id, 'identitySubmitted': true});
      } else {
        await users.doc(uid).update({
          'verificationDocuments': docId.docs.first.id,
          'identitySubmitted': true,
        });
        for (var vehicle in data['details']['vehicleData']) {
          await users.doc(uid).collection('vehicles').add(vehicle);
        }
      }
      return true;
    } catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('Error! Please try again') as SnackBar);
      return false;
    }
  }

  Future<bool> createTrip(Object data) async {
    CollectionReference trips = _firestore.collection('trips');
    try {
      await trips.add(data).then((value) {
        trips.doc(value.id).update({
          'trip_id': value.id,
        });
      });
      return true;
    } catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('Error! Please try again') as SnackBar);
      return false;
    }
  }

  Future<bool> joinTrip(String tripId, Map<String, dynamic> data, int loading, int unloading) async {
    var uid = AuthenticationService().getCurrentuserUID();
    CollectionReference trips = _firestore.collection('trips');
    try {
      await trips.doc(tripId).collection('assignee').doc(uid).set({
        'fullName': AuthenticationDataProvider.fireUserDataDriver!.fullName,
        'phoneNumber': AuthenticationDataProvider.fireUserDataDriver!.phone,
        'loading': loading,
        'unloading': unloading,
        'vehicleDetails': data['vehicleData']
      });
      await trips.doc(tripId).update({
        'status': 'ASSIGNED',
        'loadingDate': loading,
        'unloadingDate': unloading,
      });
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('active').doc(tripId).set(data);
      return true;
    } catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('Error! Please try again') as SnackBar);
      return false;
    }
  }

  Future<bool> deleteTrip(String tripId) async {
    CollectionReference trips = _firestore.collection('trips');
    try {
      await trips.doc(tripId).delete();
      return true;
    } catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('Error! Please try again') as SnackBar);
      return false;
    }
  }

  Future<bool> editTrip(String tripdId, Map<String, dynamic> data) async {
    CollectionReference trips = _firestore.collection('trips');
    try {
      await trips.doc(tripdId).update(data);
      return true;
    } catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('Error! Please try again') as SnackBar);
      return false;
    }
  }

  Future<bool> cancelTripDriver(String tripId) async {
    var uid = AuthenticationService().getCurrentuserUID();
    CollectionReference trips = _firestore.collection('trips');
    CollectionReference users = _firestore.collection('users');
    try {
      await trips.doc(tripId).update({"status": "CANCEL_TRIP_START"});
      await users.doc(uid).collection('active').doc(tripId).update({"status": "CANCEL_TRIP_START"});
      return true;
    } catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('Error! Please try again') as SnackBar);
      return false;
    }
  }

  Future<bool> cancelTripTransoprter(String tripId, String reason) async {
    String driverId = '';
    CollectionReference trips = _firestore.collection('trips');
    CollectionReference users = _firestore.collection('users');
    try {
      await trips.doc(tripId).update({"status": "CANCEL_TRIP_START", "reason": reason});
      await trips.doc(tripId).collection('assignee').get().then((value) => driverId = value.docs[0].id);
      await users.doc(driverId).collection('active').doc(tripId).update({"status": "CANCEL_TRIP_START", 'reason': reason});
      return true;
    } catch (error) {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('Error! Please try again') as SnackBar);
      return false;
    }
  }
}
