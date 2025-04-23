import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  bool _pushNotifications = false;
  bool _inAppNotifications = false;
  @override
  void initState() {
    super.initState();
    initPushNotificationData();
    initInAppPermissions();
  }

  Future<void> initPushNotificationData() async {
    var document = await FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).get();
    if (document.data()!['fcmTokens'].toString().isNotEmpty) {
      _pushNotifications = true;
      setState(() {});
    }
  }

  Future<void> initInAppPermissions() async {
    final box = GetStorage();
    var temp = box.read('inApp');
    if (temp == 'true') {
      _inAppNotifications = true;
      setState(() {});
    }
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
                  const Text('Permission Settings', style: AppTextStyles.fontBoldBlue20),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
                    title: const Text('Push Notification', style: AppTextStyles.fontBoldBlue16),
                    subtitle: const Text('Set your push notification permissions', style: AppTextStyles.fontBlack14),
                    trailing: CupertinoSwitch(
                        value: _pushNotifications,
                        onChanged: (value) {
                          if (value) {
                            AuthenticationService().setNotificationToken();
                            _pushNotifications = true;
                            setState(() {});
                          } else {
                            AuthenticationService().removeNotificationToken();
                            _pushNotifications = false;
                            setState(() {});
                          }
                        }),
                  ),
                  const Divider(height: 1, thickness: 1, color: AppColors.moonGrey),
                  ListTile(
                    contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
                    title: const Text('In-App Notification', style: AppTextStyles.fontBoldBlue16),
                    subtitle: const Text('Set your In-App notification permissions', style: AppTextStyles.fontBlack14),
                    trailing: CupertinoSwitch(
                        value: _inAppNotifications,
                        onChanged: (value) {
                          if (value) {
                            GetStorage().write('inApp', value.toString());
                            _inAppNotifications = true;
                            setState(() {});
                          } else {
                            GetStorage().write('inApp', value.toString());
                            _inAppNotifications = false;
                            setState(() {});
                          }
                        }),
                  ),
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
      title: const Text('App Settings', style: AppTextStyles.fontBoldBlue20),
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
