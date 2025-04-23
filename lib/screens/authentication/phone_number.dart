import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/screens/authentication/register/confirm_register.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PhoneNumberPage extends StatelessWidget {
  PhoneNumberPage({Key? key}) : super(key: key);
  final TextEditingController _phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fullWhite,
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: height,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: height * 0.15),
                SizedBox(
                  height: height * 0.17,
                  width: width,
                  child: Image.asset('assets/images/logoBlue.png'),
                ),
                SizedBox(height: height * 0.05),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  width: width,
                  child: const Text(
                    'Phone Number',
                    style: AppTextStyles.fontBoldBlue27,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  width: width,
                  child: const Text(
                    'Enter you Phone Number to login or register.',
                    style: AppTextStyles.fontBlack16,
                  ),
                ),
                SizedBox(height: height * 0.04),
                AppTextField(
                  textController: _phoneController,
                  hintText: '970XXXXXXX',
                  labelText: 'Mobile Number',
                  autoFocus: false,
                  maxLength: 10,
                  prefix: '+91',
                  textInput: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                ),
              ],
            ),
          ),
          Consumer<PhoneNumberAuth>(builder: (context, phone, child) {
            return Container(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 30, top: 30),
              child: AppButtonConsumer(
                clickAction: () => clickAction(phone, context),
                childWidget: PhoneNumberAuth.loading == false
                    ? const Text(
                        'Next',
                        style: AppTextStyles.fontBoldWhite20,
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.fullWhite,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void clickAction(phone, context) async {
    if (_phoneController.text.isNotEmpty) {
      FocusManager.instance.primaryFocus!.unfocus();
      var route = await phone.checkPhoneNumber(_phoneController.text);
      if (route == 'login') {
        AuthenticationInfoProvider().setPhoneNumber('+91${_phoneController.text}');
        AuthenticationInfoProvider().setLoginType('login');
        Navigator.pushNamed(context, AppRoutes.otpPage);
      } else if (route == 'register') {
        AuthenticationInfoProvider().setPhoneNumber('+91${_phoneController.text}');
        AuthenticationInfoProvider().setLoginType('register');
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          isDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: const ConfirmRegister(),
            );
          },
        );
      }
    } else {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('Please enter a phone Number') as SnackBar);
    }
  }
}
