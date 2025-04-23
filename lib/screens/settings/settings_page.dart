import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/screens/settings/app_settings.dart';
import 'package:bluebird/screens/settings/general_settings.dart';
import 'package:bluebird/screens/settings/privacy_policy.dart';
import 'package:bluebird/screens/settings/tncpage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context),
      body: _body(width, height, context),
    );
  }

  Container _body(double width, double height, BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.fullWhite,
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              primary: true,
              physics: const BouncingScrollPhysics(),
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneralSettings())),
                  child: SizedBox(
                    height: 54,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/images/general_settings.png', width: 32),
                        const SizedBox(width: 23),
                        const Text('General Settings', style: AppTextStyles.fontBlue20),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.baseColor, size: 30),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 2, color: AppColors.colorGrey),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSettings())),
                  child: SizedBox(
                    height: 54,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/images/app_settings.png', width: 32),
                        const SizedBox(width: 23),
                        const Text('App Settings', style: AppTextStyles.fontBlue20),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.baseColor, size: 30),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 2, color: AppColors.colorGrey),
                GestureDetector(
                  onTap: () {
                    final Uri emailUri = Uri(scheme: 'mailto', path: 'bluebirdpackers@gmail.com', query: 'subject: Feedback submission from');
                    launchUrl(emailUri);
                  },
                  child: SizedBox(
                    height: 54,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/images/feedback.png', width: 32),
                        const SizedBox(width: 23),
                        const Text('Help and Feedback', style: AppTextStyles.fontBlue20),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.baseColor, size: 30),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 2, color: AppColors.colorGrey),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsAndConditionsPage())),
                  child: const SizedBox(
                    height: 54,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.policy_outlined, color: AppColors.baseColor, size: 32),
                        SizedBox(width: 23),
                        Text('Terms and Conditions', style: AppTextStyles.fontBlue20),
                        Spacer(),
                        Icon(Icons.chevron_right_rounded, color: AppColors.baseColor, size: 30),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 2, color: AppColors.colorGrey),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
                  child: const SizedBox(
                    height: 54,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.security_outlined, color: AppColors.baseColor, size: 32),
                        SizedBox(width: 23),
                        Text('Privacy Policy', style: AppTextStyles.fontBlue20),
                        Spacer(),
                        Icon(Icons.chevron_right_rounded, color: AppColors.baseColor, size: 30),
                      ],
                    ),
                  ),
                ),
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
      title: const Text('Settings', style: AppTextStyles.fontBoldBlue20),
      centerTitle: true,
      actions: [
        TextButton(
          child: const Text(
            'Back',
            style: AppTextStyles.fontBlack16,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}
