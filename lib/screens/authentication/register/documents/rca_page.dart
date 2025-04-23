import 'dart:io';

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/screens/authentication/register/complete_registration.dart';
import 'package:bluebird/screens/camera_popup/camera_popup.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RCAPage extends StatefulWidget {
  const RCAPage({Key? key}) : super(key: key);

  @override
  State<RCAPage> createState() => _RCAPageState();
}

class _RCAPageState extends State<RCAPage> {
  Future<QuerySnapshot>? query;
  @override
  void initState() {
    super.initState();
    getVehicles();
  }

  Future<void> getVehicles() async {
    query = FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).collection('vehicles').get();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.fullWhite,
        body: _body(height, width, context),
      ),
    );
  }

  Widget _body(height, width, context) {
    return SizedBox(
      height: height,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              primary: false,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: height * 0.14),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Upload your RC Card',
                    style: AppTextStyles.fontBoldBlue27,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Please upload your RC Card pictures to continue with the Verification process.',
                    style: AppTextStyles.fontBlack16,
                  ),
                ),
                SizedBox(height: height * 0.029),
                Container(
                  width: width,
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Take a Photo',
                    style: AppTextStyles.fontBlue24,
                  ),
                ),
                const SizedBox(height: 17),
                FutureBuilder<QuerySnapshot>(
                  future: query,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.baseColor));
                    } else {
                      IdentityFormProvider().initRCCard(snapshot.data!.size);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(
                            snapshot.data!.size,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("RCA CARD ${index + 1}", style: AppTextStyles.fontBoldBlue16),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                isScrollControlled: true,
                                                context: context,
                                                builder: (context) {
                                                  return CamerPopUp(type: 'RC Papers', index: index, front: true);
                                                },
                                              ).then((value) {
                                                setState(() {});
                                              });
                                            },
                                            child: Container(
                                              width: width * 0.30,
                                              height: width * 0.30,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                border: Border.all(color: AppColors.baseColor, width: 1),
                                              ),
                                              child: IdentityFormProvider.rcCard[index]['front'] == null
                                                  ? const Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.camera_alt_rounded, size: 30, color: AppColors.baseColor),
                                                        Text('Front', style: AppTextStyles.fontBlue14),
                                                      ],
                                                    )
                                                  : ClipRRect(
                                                      borderRadius: BorderRadius.circular(11),
                                                      child: Image.file(File(IdentityFormProvider.rcCard[index]['front']), fit: BoxFit.cover),
                                                    ),
                                            ),
                                          ),
                                          IdentityFormProvider.rcCard[index]['front'] != null
                                              ? OutlinedButton(
                                                  style: OutlinedButton.styleFrom(
                                                    fixedSize: Size(width * 0.30, 30),
                                                    backgroundColor: AppColors.baseColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    var imagePath = IdentityFormProvider.rcCard[index]['front'].toString();
                                                    IdentityFormProvider().deleteRCPath(true, index);
                                                    File(imagePath).delete();
                                                    setState(() {});
                                                  },
                                                  child: const Icon(
                                                    Icons.delete_rounded,
                                                    color: AppColors.fullWhite,
                                                  ),
                                                )
                                              : const SizedBox(
                                                  height: 30,
                                                ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (context) {
                                              return CamerPopUp(type: 'RC Papers', index: index, front: false);
                                            },
                                          ).then((value) {
                                            setState(() {});
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              width: width * 0.30,
                                              height: width * 0.30,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                border: Border.all(color: AppColors.baseColor, width: 1),
                                              ),
                                              child: IdentityFormProvider.rcCard[index]['back'] == null
                                                  ? const Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.camera_alt_rounded, size: 30, color: AppColors.baseColor),
                                                        Text('Back', style: AppTextStyles.fontBlue14),
                                                      ],
                                                    )
                                                  : ClipRRect(
                                                      borderRadius: BorderRadius.circular(11),
                                                      child: Image.file(File(IdentityFormProvider.rcCard[index]['back'].toString()), fit: BoxFit.cover),
                                                    ),
                                            ),
                                            IdentityFormProvider.rcCard[index]['back'] != null
                                                ? OutlinedButton(
                                                    style: OutlinedButton.styleFrom(
                                                      fixedSize: Size(width * 0.30, 30),
                                                      backgroundColor: AppColors.baseColor,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                    ),
                                                    onPressed: () {
                                                      var imagePath = IdentityFormProvider.rcCard[index]['back'].toString();
                                                      File(imagePath).delete();
                                                      IdentityFormProvider().deleteRCPath(false, index);
                                                      setState(() {});
                                                    },
                                                    child: const Icon(Icons.delete_rounded, color: AppColors.fullWhite))
                                                : const SizedBox(height: 30),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30, bottom: MediaQuery.of(context).padding.bottom + 30),
            child: Consumer<UploadFilesProvider>(
              builder: (context, upload, child) {
                return AppButtonConsumer(
                  clickAction: UploadFilesProvider.loading == false ? () => _clickAction(upload, context) : () {},
                  childWidget: UploadFilesProvider.loading == false
                      ? const Text(
                          'Submit',
                          style: AppTextStyles.fontBoldWhite20,
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.fullWhite,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _clickAction(upload, context) async {
    if (IdentityFormProvider.rcCard.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              'Please Wait...\nUploading your documents',
              style: AppTextStyles.fontBoldBlue16,
            ),
            content: Container(
              width: 30,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 95),
              child: const CircularProgressIndicator(color: AppColors.baseColor),
            ),
          );
        },
      );
      var response = await upload.uploadImageFiles();
      if (response) {
        Navigator.of(context).pop();
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          isDismissible: true,
          context: context,
          builder: (context) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: const CompleteRegistration(),
            );
          },
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().showerrorSnackbar('Please take pictures of all the mentioned documents') as SnackBar);
    }
  }
}
