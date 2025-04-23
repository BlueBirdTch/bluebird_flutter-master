// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:io';

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/utils/providers/identity_details_form_provder.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/utils/services/camera_picture_save_service.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SelfiePage extends StatefulWidget {
  const SelfiePage({Key? key}) : super(key: key);

  @override
  State<SelfiePage> createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  bool loading = false;
  var cameras;
  bool camper = false, micro = false;
  Directory? appDir;
  String? appDirPath;
  CameraController? _selfieController;
  Future<void>? _initializeCameraController;

  void _initAppDirectory() async {
    appDir = await getApplicationDocumentsDirectory();
    appDirPath = appDir?.path;
  }

  void _initializeCamera() async {
    camper = await Permission.camera.isGranted;
    micro = await Permission.microphone.isGranted;
    setState(() {});
    if (camper && micro) {
      cameras = await availableCameras();
      _selfieController = CameraController(
        cameras[1],
        ResolutionPreset.medium,
      );
      _initializeCameraController = _selfieController!.initialize();
      setState(() {});
    } else {
      await Permission.camera.request();
      await Permission.microphone.request();
      _initializeCameraController;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
      _initAppDirectory();
    });
  }

  @override
  void dispose() {
    _selfieController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.fullWhite,
        body: _body(width, height, context),
      ),
    );
  }

  Widget _body(width, height, context) {
    var aspectRatio = MediaQuery.of(context).size.aspectRatio;
    return SizedBox(
      width: width,
      height: height,
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
                SizedBox(height: height * 0.12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Identification Proof',
                    style: AppTextStyles.fontBoldBlue27,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Please upload a selfie for the eKYC Verification process. Make sure the lighting is good and your face is clear.',
                    style: AppTextStyles.fontBlack16,
                  ),
                ),
                SizedBox(height: height * 0.023),
                camper && micro
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        width: width * aspectRatio,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.baseColor,
                            width: 4.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: FutureBuilder<void>(
                            future: _initializeCameraController,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                return CameraPreview(
                                  _selfieController!,
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                                    child: const Text(
                                      'Please make sure your face is in the frame',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.fontWhite14,
                                    ),
                                  ),
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(color: AppColors.baseColor),
                                );
                              }
                            },
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 26),
                            child: Text(
                              "\nCamera Permission\n",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.fontBoldBlue20,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 26),
                            child: Text(
                              "We need to request camera permission to complete the eKYC process, this is used to take pictures of the IDs asked by the app for human verification",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.fontBlue16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          AppButtonWhite(
                            text: 'Allow Permission',
                            clickAction: () async {
                              await Permission.camera.request();
                              await Permission.microphone.request();
                              camper = await Permission.camera.isGranted;
                              micro = await Permission.microphone.isGranted;
                              if (!camper || !micro) {
                                await openAppSettings();
                                _initializeCamera();
                                setState(() {});
                              } else {
                                _initializeCamera();
                                setState(() {});
                              }
                            },
                          )
                        ],
                      ),
              ],
            ),
          ),
          camper
              ? Container(
                  margin: EdgeInsets.only(top: 30, bottom: MediaQuery.of(context).padding.bottom + 30),
                  child: AppButtonConsumer(
                    clickAction: loading == false && camper ? () => clickAction() : () {},
                    childWidget: loading == false
                        ? const Text(
                            'Take Picture',
                            style: AppTextStyles.fontBoldWhite20,
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.fullWhite,
                            ),
                          ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget imagePreview() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.70,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.fullWhite,
      ),
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
                const SizedBox(height: 20),
                const Text(
                  'Confirm Picture?',
                  style: AppTextStyles.fontBoldBlue27,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Would you like to use this picture?',
                  style: AppTextStyles.fontBlack16,
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.baseColor, width: 4.0),
                  ),
                  height: MediaQuery.of(context).size.height * 0.30,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(
                      IdentityFormProvider.selfie as File,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppButton(
            text: 'Next',
            clickAction: () {
              Navigator.pushNamed(context, AppRoutes.aadharPage);
            },
          ),
          Container(
            margin: EdgeInsets.only(top: 10, bottom: MediaQuery.of(context).padding.bottom + 30),
            child: AppTextButton(
              text: 'Try Again',
              clickAction: () async {
                await IdentityFormProvider.selfie?.delete();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  void clickAction() async {
    setState(() {
      loading = true;
    });
    String? name = AuthenticationService().getCurrentuserUID();
    name = '${name}_selfie';
    String? selfiePath = await CameraService().clickPicture(_selfieController!);
    IdentityFormProvider().setSelfie(selfiePath!);
    setState(() {
      loading = false;
    });
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: imagePreview(),
        );
      },
    );
  }
}
