// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:io';

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/utils/providers/identity_details_form_provder.dart';
import 'package:bluebird/utils/services/camera_picture_save_service.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CamerPopUpRetake extends StatefulWidget {
  const CamerPopUpRetake({Key? key, required this.type, this.index, this.total, this.front}) : super(key: key);
  final String type;
  final int? index, total;
  final bool? front;
  @override
  State<CamerPopUpRetake> createState() => _CamerPopUpRetakeState();
}

class _CamerPopUpRetakeState extends State<CamerPopUpRetake> {
  CameraController? _cameraController;
  Future<void>? _initializeCameraController;
  var cameras;
  bool loading = false;
  Directory? appDir;
  String? appDirPath;

  void _initAppDirectory() async {
    appDir = await getApplicationDocumentsDirectory();
    appDirPath = appDir?.path;
  }

  void _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      widget.type == 'Selfie' ? cameras[1] : cameras[0],
      ResolutionPreset.medium,
    );
    _initializeCameraController = _cameraController!.initialize();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAppDirectory();
      _initializeCamera();
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      color: AppColors.fullWhite,
      height: height,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              primary: false,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: height * 0.10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    widget.type,
                    style: AppTextStyles.fontBoldBlue27,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Please take a clear picture of the document under good lighting conditions.',
                    style: AppTextStyles.fontBlack16,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  decoration: BoxDecoration(
                    border: Border.all(width: 4.0, color: AppColors.baseColor),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: FutureBuilder<void>(
                      future: _initializeCameraController,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CameraPreview(_cameraController!);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.baseColor),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30, bottom: MediaQuery.of(context).padding.bottom + 30),
            child: AppButtonConsumer(
              clickAction: loading == false
                  ? () async {
                      setState(() {
                        loading = true;
                      });
                      String? imagePath = await CameraService().clickPicture(_cameraController!);
                      switch (widget.type) {
                        case 'Aadhar Front':
                          IdentityFormProvider().setAadharFront(imagePath!);
                          break;
                        case 'Aadhar Back':
                          IdentityFormProvider().setAadharBack(imagePath!);
                          break;
                        case 'PAN Card':
                          IdentityFormProvider().setPanCard(imagePath!);
                          break;
                        case 'Driving License Front':
                          IdentityFormProvider().setdrivingLicenseFront(imagePath!);
                          break;
                        case 'Driving License Back':
                          IdentityFormProvider().setdrivingLicenseBack(imagePath!);
                          break;
                        case 'RC Papers':
                          IdentityFormProvider().setrcCard(imagePath!, widget.front!, widget.index!);
                          break;
                        case 'Trade License':
                          IdentityFormProvider().settradeLicense(imagePath!);
                          break;
                        case 'Selfie':
                          IdentityFormProvider().setSelfie(imagePath!);
                          break;
                        default:
                          ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().showerrorSnackbar('Oops! Seems like something is wrong') as SnackBar);
                      }
                      setState(() {
                        loading = false;
                      });
                      Navigator.pop(context);
                    }
                  : () {},
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
          ),
        ],
      ),
    );
  }
}
