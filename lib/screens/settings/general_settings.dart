import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({Key? key}) : super(key: key);

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  PermissionStatus _cameraPermission = PermissionStatus.denied;
  PermissionStatus _locationPermission = PermissionStatus.denied;
  @override
  void initState() {
    super.initState();
    getPermissionsData();
  }

  Future<void> getPermissionsData() async {
    _cameraPermission = await Permission.camera.status;
    _locationPermission = await Permission.location.status;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.fullWhite,
      appBar: _appBar(context),
      body: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                primary: true,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    title: const Text('Camera Permission', style: AppTextStyles.fontBoldBlue16),
                    subtitle: const Text('Manage your camera permissions here', style: AppTextStyles.fontBlack14),
                    trailing: _cameraPermission.isGranted
                        ? Text('Granted', style: AppTextStyles.fontBoldBlue14.copyWith(color: AppColors.appGreen))
                        : Text('Denied', style: AppTextStyles.fontBoldBlue14.copyWith(color: AppColors.errorRed)),
                  ),
                  _cameraPermission.isPermanentlyDenied || _cameraPermission.isDenied
                      ? AppTextButton(
                          text: 'Grant Camera Permission',
                          clickAction: () async {
                            if (_cameraPermission.isPermanentlyDenied) {
                              openAppSettings();
                            } else if (_cameraPermission.isDenied) {
                              await Permission.camera.request();
                              getPermissionsData();
                            }
                          })
                      : Container(),
                  const SizedBox(height: 12),
                  const Divider(thickness: 1, height: 1, color: AppColors.moonGrey),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    title: const Text('Location Permission', style: AppTextStyles.fontBoldBlue16),
                    subtitle: const Text('Manage your location permissions here', style: AppTextStyles.fontBlack14),
                    trailing: _locationPermission.isGranted
                        ? Text('Granted', style: AppTextStyles.fontBoldBlue14.copyWith(color: AppColors.appGreen))
                        : Text('Denied', style: AppTextStyles.fontBoldBlue14.copyWith(color: AppColors.errorRed)),
                  ),
                  _locationPermission.isPermanentlyDenied || _locationPermission.isDenied
                      ? AppTextButton(
                          text: 'Grant Location Permission',
                          clickAction: () async {
                            if (_locationPermission.isPermanentlyDenied) {
                              openAppSettings();
                            } else if (_locationPermission.isDenied) {
                              await Permission.location.request();
                              getPermissionsData();
                            }
                          })
                      : Container(),
                  const SizedBox(height: 12),
                  const Divider(thickness: 1, height: 1, color: AppColors.moonGrey),
                ],
              ),
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
      title: const Text('General Settings', style: AppTextStyles.fontBoldBlue20),
      centerTitle: true,
      leadingWidth: 75,
      leading: TextButton(
        child: const Text(
          'Back',
          style: AppTextStyles.fontBlack16,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
