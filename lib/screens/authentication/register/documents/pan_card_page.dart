import 'dart:io';

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/screens/camera_popup/camera_popup.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';

class PANCard extends StatefulWidget {
  const PANCard({Key? key}) : super(key: key);

  @override
  State<PANCard> createState() => _PANCardState();
}

class _PANCardState extends State<PANCard> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.fullWhite,
      body: _body(height, width, context),
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
                    'Upload your PAN Card',
                    style: AppTextStyles.fontBoldBlue27,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Please upload your PAN Card pictures to continue with the Verification process.',
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
                          return const CamerPopUp(type: 'PAN Card');
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
                          child: IdentityFormProvider.panCard == null
                              ? const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 30,
                                  color: AppColors.baseColor,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.file(
                                    IdentityFormProvider.panCard as File,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 2),
                        IdentityFormProvider.panCard != null
                            ? OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  fixedSize: Size(width * 0.30, 30),
                                  backgroundColor: AppColors.baseColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {
                                  var imagePath = IdentityFormProvider.panCard;
                                  IdentityFormProvider.panCard = null;
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
            child: AppButton(
              text: 'Next',
              clickAction: () {
                if (IdentityFormProvider.panCard != null) {
                  if (AuthenticationDataProvider().getRole() == 'driver') {
                    Navigator.pushNamed(context, AppRoutes.drivingLicensePage);
                  } else if (AuthenticationDataProvider().getRole() == 'transporter') {
                    Navigator.pushNamed(context, AppRoutes.tradeLicensePage);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().showerrorSnackbar('Please take pictures of all the mentioned documents') as SnackBar);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
