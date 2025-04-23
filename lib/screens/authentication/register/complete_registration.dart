import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/utils/providers/phone_details_provider.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CompleteRegistration extends StatelessWidget {
  const CompleteRegistration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.50,
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
                    'Your Documents are being verified',
                    style: AppTextStyles.fontBoldWhite27,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Text(
                    'Once your documents are verified, you will be notified',
                    style: AppTextStyles.fontWhite16,
                  ),
                ),
              ],
            ),
          ),
          LottieBuilder.asset('assets/images/verify.json', fit: BoxFit.fitHeight),
          Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 30, top: 30),
            child: AppButtonWhite(
              text: 'Go to Home Screen',
              clickAction: () {
                AuthenticationInfoProvider.type = 'registrationComplete';
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.authChecker);
              },
            ),
          ),
        ],
      ),
    );
  }
}
