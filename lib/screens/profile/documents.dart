// ignore_for_file: unused_field, unused_local_variable, use_build_context_synchronously

import 'dart:io';

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/screens/camera_popup/camera_popup_retake.dart';
import 'package:bluebird/utils/providers/identity_details_form_provder.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/utils/services/firebase_storage_service.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubmittedDocumentsPage extends StatefulWidget {
  const SubmittedDocumentsPage({Key? key, required this.role}) : super(key: key);
  final String role;

  @override
  State<SubmittedDocumentsPage> createState() => _SubmittedDocumentsPageState();
}

class _SubmittedDocumentsPageState extends State<SubmittedDocumentsPage> {
  final bool _aadharFront = false;
  final bool _aadharBack = false;
  final bool _drivingLicenseFront = false;
  final bool _drivingLicenseBack = false;
  final bool _pancard = false;
  final bool _tradeLicense = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
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
            Expanded(
              child: widget.role == 'driver' ? _driverList() : _transporterList(),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.fullWhite,
      elevation: 0,
      title: const Text('Documents', style: AppTextStyles.fontBoldBlue20),
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

  Widget _driverList() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('documents').where("uid", isEqualTo: AuthenticationService().getCurrentuserUID()).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView(
            shrinkWrap: true,
            primary: true,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 24),
              _selfieImage(snapshot),
              const SizedBox(height: 24),
              const Divider(color: AppColors.baseColor, height: 1.0, thickness: 0.6),
              const SizedBox(height: 24),
              _aadharDocs(snapshot),
              const SizedBox(height: 24),
              const Divider(color: AppColors.baseColor, height: 1.0, thickness: 0.6),
              const SizedBox(height: 24),
              _drivingLicenseDocs(snapshot),
              const SizedBox(height: 24),
              const Divider(color: AppColors.baseColor, height: 1.0, thickness: 0.6),
              const SizedBox(height: 24),
              _panCardDocs(snapshot),
              const SizedBox(height: 24),
              const Divider(color: AppColors.baseColor, height: 1.0, thickness: 0.6),
              const SizedBox(height: 24),
              _rcaDocs(snapshot),
              const SizedBox(height: 24),
              const Divider(color: AppColors.baseColor, height: 1.0, thickness: 0.6),
              const SizedBox(height: 24),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator(color: AppColors.baseColor));
        }
      },
    );
  }

  Widget _transporterList() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('documents').where("uid", isEqualTo: AuthenticationService().getCurrentuserUID()).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView(
            shrinkWrap: true,
            primary: true,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 24),
              _selfieImage(snapshot),
              const SizedBox(height: 24),
              const Divider(color: AppColors.baseColor, height: 1.0, thickness: 0.6),
              const SizedBox(height: 24),
              _aadharDocs(snapshot),
              const SizedBox(height: 24),
              const Divider(color: AppColors.baseColor, height: 1.0, thickness: 0.6),
              const SizedBox(height: 24),
              _panCardDocs(snapshot),
              const SizedBox(height: 24),
              const Divider(color: AppColors.baseColor, height: 1.0, thickness: 0.6),
              const SizedBox(height: 24),
              _tradeLicenseDocs(snapshot),
              const SizedBox(height: 24),
              const Divider(color: AppColors.baseColor, height: 1.0, thickness: 0.6),
              const SizedBox(height: 24),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator(color: AppColors.baseColor));
        }
      },
    );
  }

  Padding _aadharDocs(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text("Aadhar Documents", style: AppTextStyles.fontBoldBlue20),
          subtitle: snapshot.data!.docs[0]['details']['aadhar']['verified'] == false
              ? RichText(
                  text: TextSpan(children: [
                    TextSpan(text: "Documents Unverified\n", style: AppTextStyles.fontBlack16.copyWith(color: AppColors.errorRed)),
                    TextSpan(text: "Tap on image to retake photo", style: AppTextStyles.fontBlack14.copyWith(color: AppColors.errorRed))
                  ]),
                )
              : const Text("Documents Verified", style: AppTextStyles.fontBoldBlue14),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.baseColor)),
                        child: snapshot.data!.docs[0]['aadhar'][0].toString().isEmpty ? Container() : Image.network(snapshot.data!.docs[0]['aadhar'][0], fit: BoxFit.cover),
                      ),
                    ),
                    const Text("Front", style: AppTextStyles.fontBlue14),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.baseColor)),
                        child: Image.network(snapshot.data!.docs[0]['aadhar'][1], fit: BoxFit.cover),
                      ),
                    ),
                    const Text("Back", style: AppTextStyles.fontBlue14),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            snapshot.data!.docs[0]['details']['aadhar']['verified'] == false
                ? AppButtonWhite(
                    text: "Re-Upload",
                    clickAction: () async {
                      await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return const CamerPopUpRetake(type: 'Aadhar Front');
                          });
                      await confirmRetake('Aadhar Front', 0, 'front');
                      await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return const CamerPopUpRetake(type: 'Aadhar Back');
                          });
                      await confirmRetake('Aadhar Back', 0, 'front');
                    })
                : Container()
          ],
        ),
      ),
    );
  }

  Padding _drivingLicenseDocs(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text("Driving License", style: AppTextStyles.fontBoldBlue20),
          subtitle: snapshot.data!.docs[0]['details']['driving_license']['verified'] == false
              ? RichText(
                  text: TextSpan(children: [
                    TextSpan(text: "Documents Unverified\n", style: AppTextStyles.fontBlack16.copyWith(color: AppColors.errorRed)),
                    TextSpan(text: "Tap on image to retake photo", style: AppTextStyles.fontBlack14.copyWith(color: AppColors.errorRed))
                  ]),
                )
              : const Text("Documents Verified", style: AppTextStyles.fontBoldBlue14),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.baseColor)),
                        child: snapshot.data!.docs[0]['driving_license'][0].toString().isEmpty ? Container() : Image.network(snapshot.data!.docs[0]['driving_license'][0], fit: BoxFit.cover),
                      ),
                    ),
                    const Text("Front", style: AppTextStyles.fontBlue14),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.baseColor)),
                        child: Image.network(snapshot.data!.docs[0]['driving_license'][1], fit: BoxFit.cover),
                      ),
                    ),
                    const Text("Back", style: AppTextStyles.fontBlue14),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            snapshot.data!.docs[0]['details']['driving_license']['verified'] == false
                ? AppButtonWhite(
                    text: "Re-Upload",
                    clickAction: () async {
                      await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return const CamerPopUpRetake(type: 'Driving License Front');
                          });
                      await confirmRetake('Driving License Front', 0, 'front');
                      await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return const CamerPopUpRetake(type: 'Driving License Back');
                          });
                      await confirmRetake('Driving License Back', 0, 'front');
                    })
                : Container()
          ],
        ),
      ),
    );
  }

  Padding _panCardDocs(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text("PAN Card", style: AppTextStyles.fontBoldBlue20),
          subtitle: snapshot.data!.docs[0]['details']['pan']['verified'] == false
              ? RichText(
                  text: TextSpan(children: [
                    TextSpan(text: "Documents Unverified\n", style: AppTextStyles.fontBlack16.copyWith(color: AppColors.errorRed)),
                    TextSpan(text: "Tap on image to retake photo", style: AppTextStyles.fontBlack14.copyWith(color: AppColors.errorRed))
                  ]),
                )
              : const Text("Documents Verified", style: AppTextStyles.fontBoldBlue14),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.baseColor)),
                    child: snapshot.data!.docs[0]['pan_card'][0].toString().isEmpty ? Container() : Image.network(snapshot.data!.docs[0]['pan_card'][0], fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            snapshot.data!.docs[0]['details']['pan']['verified'] == false
                ? AppButtonWhite(
                    text: "Re-Upload",
                    clickAction: () async {
                      await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return const CamerPopUpRetake(type: 'PAN Card');
                          });
                      await confirmRetake('PAN Card', 0, 'front');
                    })
                : Container()
          ],
        ),
      ),
    );
  }

  Padding _tradeLicenseDocs(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text("Trade Licesnse", style: AppTextStyles.fontBoldBlue20),
          subtitle: snapshot.data!.docs[0]['details']['trade_license']['verified'] == false
              ? RichText(
                  text: TextSpan(children: [
                    TextSpan(text: "Documents Unverified\n", style: AppTextStyles.fontBlack16.copyWith(color: AppColors.errorRed)),
                    TextSpan(text: "Tap on image to retake photo", style: AppTextStyles.fontBlack14.copyWith(color: AppColors.errorRed))
                  ]),
                )
              : const Text("Documents Verified", style: AppTextStyles.fontBoldBlue14),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.baseColor)),
                    child: snapshot.data!.docs[0]['trade_license'][0].toString().isEmpty ? Container() : Image.network(snapshot.data!.docs[0]['trade_license'][0], fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            snapshot.data!.docs[0]['details']['trade_license']['verified'] == false
                ? AppButtonWhite(
                    text: "Re-Upload",
                    clickAction: () async {
                      await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return const CamerPopUpRetake(type: 'Trade License');
                          });
                      await confirmRetake('Trade License', 0, 'front');
                    })
                : Container()
          ],
        ),
      ),
    );
  }

  Padding _selfieImage(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text("Selfie", style: AppTextStyles.fontBoldBlue20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.baseColor)),
                      child: snapshot.data!.docs[0]['selfie'][0].toString().isEmpty ? Container() : Image.network(snapshot.data!.docs[0]['selfie'][0], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppButtonWhite(
                text: "Re-Upload",
                clickAction: () async {
                  await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return const CamerPopUpRetake(type: 'Selfie');
                      });
                  File? selfieReupload = IdentityFormProvider.selfie;
                  confirmRetake('Selfie', 0, 'front');
                })
          ],
        ),
      ),
    );
  }

  Padding _rcaDocs(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text("RCA Documents", style: AppTextStyles.fontBoldBlue20),
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 120,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                primary: false,
                scrollDirection: Axis.horizontal,
                children: List.generate(
                  snapshot.data!.docs[0]['rca'].length,
                  (index) => SizedBox(
                    height: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.baseColor)),
                                  child:
                                      snapshot.data!.docs[0]['rca'][index]['front'].toString().isEmpty ? Container() : Image.network(snapshot.data!.docs[0]['rca'][index]['front'], fit: BoxFit.cover),
                                ),
                              ),
                              Text("Front ${index + 1}", style: AppTextStyles.fontBlue14),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.baseColor)),
                                  child: snapshot.data!.docs[0]['rca'][index]['back'].toString().isEmpty ? Container() : Image.network(snapshot.data!.docs[0]['rca'][index]['back'], fit: BoxFit.cover),
                                ),
                              ),
                              Text("Back ${index + 1}", style: AppTextStyles.fontBlue14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AppButtonWhite(
                text: "Re-Upload",
                clickAction: () async {
                  IdentityFormProvider.rcCard = [];
                  num limit = snapshot.data!.docs[0]['rca'].length;
                  for (int i = 0; i < limit; i++) {
                    IdentityFormProvider.rcCard.add({'front': '', 'back': ''});
                  }
                  for (int i = 0; i < limit; i++) {
                    await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return CamerPopUpRetake(type: 'RC Papers', index: i, front: true);
                        });
                    await confirmRetake('RC Papers', i, 'front');
                    await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return CamerPopUpRetake(type: 'RC Papers', index: i, front: false);
                        });
                    await confirmRetake('RC Papers', i, 'back');
                  }
                })
          ],
        ),
      ),
    );
  }

  Future<void> confirmRetake(String type, int index, String direction) async {
    await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            height: MediaQuery.of(context).size.height * 0.65,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: AppColors.fullWhite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text('Do you want to re-upload this image?', style: AppTextStyles.fontBoldBlue20),
                const SizedBox(height: 36),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(
                      type == 'Selfie'
                          ? IdentityFormProvider.selfie as File
                          : type == 'Aadhar Front'
                              ? IdentityFormProvider.aadharFront as File
                              : type == 'Aadhar Back'
                                  ? IdentityFormProvider.aadharBack as File
                                  : type == 'PAN Card'
                                      ? IdentityFormProvider.panCard as File
                                      : type == 'Driving License Front'
                                          ? IdentityFormProvider.drivingLicenseFront as File
                                          : type == 'Driving License Back'
                                              ? IdentityFormProvider.drivingLicenseBack as File
                                              : type == 'RC Papers'
                                                  ? File(IdentityFormProvider.rcCard[index][direction].toString())
                                                  : type == 'Trade License'
                                                      ? IdentityFormProvider.tradeLicense as File
                                                      : File as File,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Spacer(),
                AppButton(
                    text: 'Confirm',
                    clickAction: () async {
                      var fileName = AuthenticationService().getCurrentuserUID();
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const Center(child: CircularProgressIndicator(color: AppColors.baseColor));
                          });
                      switch (type) {
                        case 'Selfie':
                          fileName = '${fileName}_selfie.jpg';
                          await FirebaseStorageService().uploadImagetoFirebaseCloud(fileName, IdentityFormProvider.selfie as File);
                          break;
                        case 'Aadhar Front':
                          fileName = '${fileName}_aadhar_front.jpg';
                          await FirebaseStorageService().uploadImagetoFirebaseCloud(fileName, IdentityFormProvider.aadharFront as File);
                          break;
                        case 'Aadhar Back':
                          fileName = '${fileName}_aadhar_back.jpg';
                          await FirebaseStorageService().uploadImagetoFirebaseCloud(fileName, IdentityFormProvider.aadharBack as File);
                          break;
                        case 'PAN Card':
                          fileName = '${fileName}_pan_card.jpg';
                          await FirebaseStorageService().uploadImagetoFirebaseCloud(fileName, IdentityFormProvider.panCard as File);
                          break;
                        case 'Driving License Front':
                          fileName = '${fileName}_driving_license_front.jpg';
                          await FirebaseStorageService().uploadImagetoFirebaseCloud(fileName, IdentityFormProvider.drivingLicenseFront as File);
                          break;
                        case 'Driving License Back':
                          fileName = '${fileName}_driving_license_back.jpg';
                          await FirebaseStorageService().uploadImagetoFirebaseCloud(fileName, IdentityFormProvider.drivingLicenseBack as File);
                          break;
                        case 'RC Papers':
                          fileName = '${fileName}_rca_${index + 1}_$direction';
                          await FirebaseStorageService().uploadImagetoFirebaseCloud(fileName, File(IdentityFormProvider.rcCard[index][direction].toString()));
                          break;
                        case 'Trade Licesnse':
                          fileName = '${fileName}_trade_license.jpg';
                          await FirebaseStorageService().uploadImagetoFirebaseCloud(fileName, IdentityFormProvider.tradeLicense as File);
                          break;
                        default:
                          break;
                      }
                      PaintingBinding.instance.imageCache.clear();
                      setState(() {});
                      Navigator.pop(context);
                      Navigator.pop(context);
                      AppSnackbars().shoeMessageSnackbar("$type uploaded Successfully");
                    }),
                AppTextButton(
                    text: 'Go Back',
                    clickAction: () {
                      Navigator.pop(context);
                    }),
                const SizedBox(height: 32),
              ],
            ),
          );
        });
  }
}
