// ignore_for_file: use_build_context_synchronously

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({Key? key}) : super(key: key);

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  String _verificationCode = '';
  final TextEditingController _otpController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        sendOtp();
      },
    );
  }

  void sendOtp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: AuthenticationInfoProvider.phoneNumber,
      verificationCompleted: _verificationCompleted,
      verificationFailed: _verificationFailed,
      codeSent: _codeSent,
      codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 120),
    );
  }

  _verificationCompleted(AuthCredential credential) async {
    bool response = await AuthenticationService().authenticateCredential(credential);
    if (response) {
      Navigator.pushNamed(context, AppRoutes.authChecker);
    }
  }

  _verificationFailed(FirebaseAuthException e) {
    if (e.code == 'invalid-phone-number') {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().showerrorSnackbar('Invalid Phone Number') as SnackBar);
    }
  }

  _codeSent(String verificationId, int? resenedToken) {
    setState(() {
      _verificationCode = verificationId;
    });
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    setState(() {
      _verificationCode = verificationId;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.fullWhite,
      appBar: _appBar(height),
      body: _body(height, width),
    );
  }

  AppBar _appBar(double height) {
    return AppBar(
      toolbarHeight: height * 0.08,
      backgroundColor: AppColors.fullWhite,
      elevation: 0,
    );
  }

  Widget _body(height, width) {
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
              padding: const EdgeInsets.all(0),
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: height * 0.08),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'OTP Authentication',
                    style: AppTextStyles.fontBoldBlue27,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    'A code has been sent to ${AuthenticationInfoProvider.phoneNumber}',
                    style: AppTextStyles.fontBlack16,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Enter the code below',
                    style: AppTextStyles.fontBlue16,
                  ),
                ),
                SizedBox(height: height * 0.10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: Pinput(
                    controller: _otpController,
                    autofocus: true,
                    length: 6,
                    onCompleted: (pin) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      var credential = PhoneAuthProvider.credential(verificationId: _verificationCode, smsCode: pin);
                      _verificationCompleted(credential);
                    },
                    defaultPinTheme: PinTheme(
                      width: width * 0.15,
                      height: width * 0.15,
                      textStyle: AppTextStyles.fontBlack27.copyWith(fontSize: 36),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.colorGrey,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: width * 0.15,
                      height: width * 0.15,
                      textStyle: AppTextStyles.fontBlack27.copyWith(fontSize: 36),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.baseColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: width * 0.15,
                      height: width * 0.15,
                      textStyle: AppTextStyles.fontBlack27.copyWith(fontSize: 36),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.baseColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 30, bottom: 20),
            child: AppButton(
              text: 'Submit',
              clickAction: () {
                var credential = PhoneAuthProvider.credential(verificationId: _verificationCode, smsCode: _otpController.text);
                _verificationCompleted(credential);
              },
            ),
          ),
          const Text(
            'Didn\'t recieve an OTP?',
            style: AppTextStyles.fontBlack16,
          ),
          Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 30),
            child: AppTextButton(
              text: 'Click here to get new OTP',
              clickAction: () => sendOtp(),
            ),
          ),
        ],
      ),
    );
  }
}
