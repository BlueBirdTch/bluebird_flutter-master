// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable

import 'package:bluebird/config/models/driver_model.dart';
import 'package:bluebird/config/models/transporter_model.dart';
import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/screens/profile/address_page.dart';
import 'package:bluebird/screens/profile/documents.dart';
import 'package:bluebird/screens/profile/vehicles_page.dart';
import 'package:bluebird/utils/providers/authentication_data_provider.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/widgets/popups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);
  var userProfile;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    userProfile =
        AuthenticationDataProvider().getRole() == 'driver' ? AuthenticationDataProvider.fireUserDataDriver as DriverModel : AuthenticationDataProvider.fireUserTransporter as TransporterModel;
    return Scaffold(
      appBar: _appBar(context),
      backgroundColor: AppColors.fullWhite,
      body: SizedBox(
        height: height,
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _profileHeader(width, height),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                primary: true,
                padding: const EdgeInsets.symmetric(horizontal: 26),
                physics: const BouncingScrollPhysics(),
                children: [
                  const Divider(height: 2, color: AppColors.colorGrey),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubmittedDocumentsPage(role: AuthenticationDataProvider().getRole()))),
                    child: const SizedBox(
                      height: 54,
                      child: InkWell(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.description, size: 32, color: AppColors.baseColor),
                            SizedBox(width: 23),
                            Text('Submitted Documents', style: AppTextStyles.fontBlue20),
                            Spacer(),
                            Icon(Icons.chevron_right_rounded, color: AppColors.baseColor, size: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AuthenticationDataProvider().getRole() == 'driver' ? const Divider(height: 2, color: AppColors.colorGrey) : Container(),
                  AuthenticationDataProvider().getRole() == 'driver'
                      ? GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehiclesPage())),
                          child: const SizedBox(
                            height: 54,
                            child: InkWell(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.local_shipping, size: 32, color: AppColors.baseColor),
                                  SizedBox(width: 23),
                                  Text('Your Vehicles', style: AppTextStyles.fontBlue20),
                                  Spacer(),
                                  Icon(Icons.chevron_right_rounded, color: AppColors.baseColor, size: 30),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  const Divider(height: 2, color: AppColors.colorGrey),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddressPage())),
                    child: const SizedBox(
                      height: 54,
                      child: InkWell(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.place, size: 32, color: AppColors.baseColor),
                            SizedBox(width: 23),
                            Text('Saved Addresses', style: AppTextStyles.fontBlue20),
                            Spacer(),
                            Icon(Icons.chevron_right_rounded, color: AppColors.baseColor, size: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 2, color: AppColors.colorGrey),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return Padding(padding: MediaQuery.of(context).viewInsets, child: const ConfirmLogout());
                        },
                      );
                    },
                    child: SizedBox(
                      height: 54,
                      child: InkWell(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset('assets/images/signout.png', width: 32),
                            const SizedBox(width: 23),
                            const Text('Sign Out', style: AppTextStyles.fontBlue20),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.baseColor, size: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _profileHeader(double width, double height) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      width: width,
      height: height * 0.15,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('documents').where('uid', isEqualTo: AuthenticationService().getCurrentuserUID()).get(),
            builder: (context, snapshot) {
              if (snapshot.data != null && snapshot.data!.size > 0) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(height * 0.10),
                  child: Container(
                    width: height * 0.12,
                    height: height * 0.12,
                    color: AppColors.moonGrey,
                    child: Image.network(snapshot.data!.docs[0]['selfie'][0], width: height * 0.10, height: height * 0.10),
                  ),
                );
              } else {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(height * 0.10),
                  child: Container(
                    width: height * 0.12,
                    height: height * 0.12,
                    color: AppColors.moonGrey,
                    child: Icon(Icons.person, color: AppColors.baseColor, size: height * 0.09),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(userProfile.fullName,
                    style: AppTextStyles.fontBoldBlue20.copyWith(overflow: TextOverflow.visible, color: userProfile.documentsVerified ? AppColors.baseColor : AppColors.errorRed)),
                Text(userProfile.phone, style: AppTextStyles.fontBoldBlue16.copyWith(overflow: TextOverflow.visible)),
                Text(AuthenticationDataProvider().getRole() == 'driver' ? 'Truck Owner' : 'Transporter', style: AppTextStyles.fontBlue16.copyWith(overflow: TextOverflow.visible)),
                Text("Joined on: ${userProfile.createdAt.substring(0, 10)}", style: AppTextStyles.fontBlue16.copyWith(overflow: TextOverflow.visible)),
                !userProfile.documentsVerified ? Text('Pending Verification', style: AppTextStyles.fontBlack14.copyWith(fontSize: 12, color: AppColors.errorRed)) : Container()
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.fullWhite,
      elevation: 0,
      title: const Text('Profile', style: AppTextStyles.fontBoldBlue20),
      centerTitle: true,
      actions: [
        TextButton(
          child: const Text('Back', style: AppTextStyles.fontBlack16),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}
