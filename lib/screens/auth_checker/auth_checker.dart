// ignore_for_file: use_build_context_synchronously

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:flutter/material.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await AuthenticationDataProvider().getUserDocument();
        if (AuthenticationInfoProvider.type == 'login') {
          if (AuthenticationDataProvider().getRole() == 'driver') {
            if (AuthenticationDataProvider.fireUserDataDriver!.signUpCompleted == true &&
                AuthenticationDataProvider.fireUserDataDriver!.detailsSubmitted == false &&
                AuthenticationDataProvider.fireUserDataDriver!.documentsSubmitted == false &&
                AuthenticationDataProvider.fireUserDataDriver!.identitySubmitted == false) {
              AuthenticationService().setNotificationToken();
              Navigator.pushNamed(context, AppRoutes.detailsPage);
            } else if (AuthenticationDataProvider.fireUserDataDriver!.signUpCompleted == true &&
                AuthenticationDataProvider.fireUserDataDriver!.detailsSubmitted == true &&
                AuthenticationDataProvider.fireUserDataDriver!.documentsSubmitted == false &&
                AuthenticationDataProvider.fireUserDataDriver!.identitySubmitted == false) {
              AuthenticationService().setNotificationToken();
              Navigator.pushNamed(context, AppRoutes.identityDetails);
            } else if (AuthenticationDataProvider.fireUserDataDriver!.signUpCompleted == true &&
                AuthenticationDataProvider.fireUserDataDriver!.detailsSubmitted == true &&
                AuthenticationDataProvider.fireUserDataDriver!.identitySubmitted == true &&
                AuthenticationDataProvider.fireUserDataDriver!.documentsSubmitted == false) {
              AuthenticationService().setNotificationToken();
              Navigator.pushNamed(context, AppRoutes.selfiePage);
            } else if (AuthenticationDataProvider.fireUserDataDriver!.signUpCompleted == true &&
                AuthenticationDataProvider.fireUserDataDriver!.detailsSubmitted == true &&
                AuthenticationDataProvider.fireUserDataDriver!.identitySubmitted == true &&
                AuthenticationDataProvider.fireUserDataDriver!.documentsSubmitted == true) {
              AuthenticationService().setNotificationToken();
              Navigator.pushNamed(context, AppRoutes.homePage);
            } else {
              AuthenticationService().setNotificationToken();
              Navigator.pushNamed(context, AppRoutes.selectAccount);
            }
          } else if (AuthenticationDataProvider().getRole() == 'transporter') {
            if (AuthenticationDataProvider.fireUserTransporter!.signUpCompleted == true &&
                AuthenticationDataProvider.fireUserTransporter!.detailsSubmitted == false &&
                AuthenticationDataProvider.fireUserTransporter!.documentsSubmitted == false &&
                AuthenticationDataProvider.fireUserTransporter!.identitySubmitted == false) {
              AuthenticationService().setNotificationToken();
              Navigator.pushNamed(context, AppRoutes.detailsPage);
            } else if (AuthenticationDataProvider.fireUserTransporter!.signUpCompleted == true &&
                AuthenticationDataProvider.fireUserTransporter!.detailsSubmitted == true &&
                AuthenticationDataProvider.fireUserTransporter!.documentsSubmitted == false &&
                AuthenticationDataProvider.fireUserTransporter!.identitySubmitted == false) {
              AuthenticationService().setNotificationToken();
              Navigator.pushNamed(context, AppRoutes.identityDetails);
            } else if (AuthenticationDataProvider.fireUserTransporter!.signUpCompleted == true &&
                AuthenticationDataProvider.fireUserTransporter!.detailsSubmitted == true &&
                AuthenticationDataProvider.fireUserTransporter!.identitySubmitted == true &&
                AuthenticationDataProvider.fireUserTransporter!.documentsSubmitted == false) {
              AuthenticationService().setNotificationToken();
              Navigator.pushNamed(context, AppRoutes.selfiePage);
            } else if (AuthenticationDataProvider.fireUserTransporter!.signUpCompleted == true &&
                AuthenticationDataProvider.fireUserTransporter!.detailsSubmitted == true &&
                AuthenticationDataProvider.fireUserTransporter!.identitySubmitted == true &&
                AuthenticationDataProvider.fireUserTransporter!.documentsSubmitted == true) {
              AuthenticationService().setNotificationToken();
              Navigator.pushNamed(context, AppRoutes.homePage);
            } else {
              AuthenticationService().setNotificationToken();
              Navigator.pushNamed(context, AppRoutes.selectAccount);
            }
          }
        } else if (AuthenticationInfoProvider.type == 'register') {
          AuthenticationService().setNotificationToken();
          Navigator.pushNamed(context, AppRoutes.selectAccount);
        } else {
          if (AuthenticationDataProvider().getRole() == 'driver') {
            if (AuthenticationDataProvider.fireUserDataDriver!.signUpCompleted == true &&
                AuthenticationDataProvider.fireUserDataDriver!.detailsSubmitted == true &&
                AuthenticationDataProvider.fireUserDataDriver!.identitySubmitted == true &&
                AuthenticationDataProvider.fireUserDataDriver!.documentsSubmitted) {
              AuthenticationService().setNotificationToken();
              Navigator.pushNamed(context, AppRoutes.homePage);
            } else {
              AuthenticationService().signOutUser();
              Navigator.pushNamed(context, AppRoutes.phoneNumberPage);
            }
          } else if (AuthenticationDataProvider().getRole() == 'transporter') {
            if (AuthenticationDataProvider.fireUserTransporter!.signUpCompleted == true &&
                AuthenticationDataProvider.fireUserTransporter!.detailsSubmitted == true &&
                AuthenticationDataProvider.fireUserTransporter!.identitySubmitted == true &&
                AuthenticationDataProvider.fireUserTransporter!.documentsSubmitted) {
              AuthenticationService().setNotificationToken();
              Navigator.pushNamed(context, AppRoutes.homePage);
            } else {
              AuthenticationService().signOutUser();
              Navigator.pushNamed(context, AppRoutes.phoneNumberPage);
            }
          } else {
            AuthenticationService().signOutUser();
            Navigator.pushNamed(context, AppRoutes.phoneNumberPage);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.fullWhite,
      body: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(color: AppColors.baseColor),
        ),
      ),
    );
  }
}
