import 'dart:io';

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/screens/camera_popup/camera_popup.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:bluebird/utils/providers/providers.dart';

class AadharPage extends StatefulWidget {
  const AadharPage({Key? key}) : super(key: key);

  @override
  State<AadharPage> createState() => _AadharPageState();
}

class _AadharPageState extends State<AadharPage> {
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
    return WillPopScope(
      onWillPop: () async => false,
      child: SizedBox(
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
                      'Upload your Aadhar Card',
                      style: AppTextStyles.fontBoldBlue27,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 26),
                    child: const Text(
                      'Please upload your Aadhar Card pictures to continue with the Verification process.',
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return const CamerPopUp(type: 'Aadhar Front');
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
                                child: IdentityFormProvider.aadharFront == null
                                    ? const Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt_rounded,
                                            size: 30,
                                            color: AppColors.baseColor,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Front',
                                            style: AppTextStyles.fontBlue16,
                                          )
                                        ],
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: Image.file(
                                          IdentityFormProvider.aadharFront as File,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 2),
                              IdentityFormProvider.aadharFront != null
                                  ? OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        fixedSize: Size(width * 0.30, 30),
                                        backgroundColor: AppColors.baseColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                      onPressed: () {
                                        var imagePath = IdentityFormProvider.aadharFront;
                                        IdentityFormProvider.aadharFront = null;
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
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    return const CamerPopUp(type: 'Aadhar Back');
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
                                child: IdentityFormProvider.aadharBack == null
                                    ? const Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt_rounded,
                                            size: 30,
                                            color: AppColors.baseColor,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Back',
                                            style: AppTextStyles.fontBlue16,
                                          )
                                        ],
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.file(
                                          IdentityFormProvider.aadharBack as File,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            IdentityFormProvider.aadharBack != null
                                ? OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      fixedSize: Size(width * 0.30, 30),
                                      backgroundColor: AppColors.baseColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed: () {
                                      var imagePath = IdentityFormProvider.aadharBack;
                                      IdentityFormProvider.aadharBack = null;
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
                      ],
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
                  if (IdentityFormProvider.aadharBack != null && IdentityFormProvider.aadharFront != null) {
                    Navigator.pushNamed(context, AppRoutes.panCardPage);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().showerrorSnackbar('Please take pictures of all the mentioned documents') as SnackBar);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
