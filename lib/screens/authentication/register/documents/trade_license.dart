import 'dart:io';

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/screens/authentication/register/complete_registration.dart';
import 'package:bluebird/screens/camera_popup/camera_popup.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TradeLicensePage extends StatefulWidget {
  const TradeLicensePage({Key? key}) : super(key: key);

  @override
  State<TradeLicensePage> createState() => _TradeLicensePageState();
}

class _TradeLicensePageState extends State<TradeLicensePage> {
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
                    'Upload your Trade License',
                    style: AppTextStyles.fontBoldBlue27,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Please upload your Trade License pictures to continue with the Verification process.',
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
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return const CamerPopUp(type: 'Trade License');
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
                          child: IdentityFormProvider.tradeLicense == null
                              ? const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 30,
                                  color: AppColors.baseColor,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.file(
                                    IdentityFormProvider.tradeLicense as File,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 2),
                        IdentityFormProvider.tradeLicense != null
                            ? OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  fixedSize: Size(width * 0.30, 30),
                                  backgroundColor: AppColors.baseColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {
                                  var imagePath = IdentityFormProvider.tradeLicense;
                                  IdentityFormProvider.tradeLicense = null;
                                  imagePath!.delete();
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
                  ),
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
    if (IdentityFormProvider.tradeLicense != null) {
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
        IdentityFormProvider().clearAll();
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
