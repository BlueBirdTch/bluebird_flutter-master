import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ConfirmRegister extends StatelessWidget {
  const ConfirmRegister({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: AppColors.baseColor,
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
              padding: const EdgeInsets.all(0),
              children: [
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Confirm Registration',
                    style: AppTextStyles.fontBoldWhite27,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Text(
                    'Would you like to create a new account?',
                    style: AppTextStyles.fontWhite16,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Text(
                    'Phone Number:',
                    style: AppTextStyles.fontBoldWhite16,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    AuthenticationInfoProvider.phoneNumber,
                    style: AppTextStyles.fontBoldWhite24,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 30, top: 30),
            child: AppButtonWhite(
              text: 'Confirm',
              clickAction: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.otpPage);
              },
            ),
          ),
        ],
      ),
    );
  }
}
