import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/screens/home_page/home_page.dart';
import 'package:bluebird/screens/trips/trip_details.dart';
import 'package:bluebird/utils/providers/authentication_data_provider.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeepLinkPage extends StatefulWidget {
  const DeepLinkPage({Key? key, required this.tripId}) : super(key: key);
  final String tripId;

  @override
  State<DeepLinkPage> createState() => _DeepLinkPageState();
}

class _DeepLinkPageState extends State<DeepLinkPage> {
  @override
  void initState() {
    super.initState();
  }

  void getTripDetails(String tripId) async {
    var document = await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    if (document.exists) {
      Get.to(TripDetails(document: document, transporter: AuthenticationDataProvider().getRole() == 'transporter' ? true : false));
    } else {
      Get.to(const Homepage());
      AppSnackbars().showerrorSnackbar("The requested trip could not be found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.to(const Homepage());
        return true;
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.baseColor,
          ),
        ),
      ),
    );
  }
}
