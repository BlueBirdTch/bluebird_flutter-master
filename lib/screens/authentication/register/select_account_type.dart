// ignore_for_file: use_build_context_synchronously

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AccountCreation extends StatefulWidget {
  const AccountCreation({Key? key}) : super(key: key);

  @override
  State<AccountCreation> createState() => _AccountCreationState();
}

class _AccountCreationState extends State<AccountCreation> {
  String selectedType = '';
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              primary: false,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: height * 0.07),
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
                    'Select Account Type',
                    style: AppTextStyles.fontBoldBlue27,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  width: width,
                  child: const Text(
                    'Select whether you are a Truck Owner or a Transporter.',
                    style: AppTextStyles.fontBlack16,
                  ),
                ),
                SizedBox(height: height * 0.03),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(
                        color: AppColors.baseColor,
                        width: 1,
                      ),
                    ),
                    selected: selectedType == 'driver',
                    onTap: () {
                      setState(() {
                        selectedType = 'driver';
                      });
                    },
                    selectedTileColor: AppColors.baseColor,
                    leading: FaIcon(
                      FontAwesomeIcons.truck,
                      color: selectedType == 'driver' ? AppColors.fullWhite : AppColors.baseColor,
                    ),
                    title: Text(
                      'Truck Owner',
                      style: selectedType == 'driver' ? AppTextStyles.fontWhite20 : AppTextStyles.fontBlack20,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(
                        color: AppColors.baseColor,
                        width: 1,
                      ),
                    ),
                    selected: selectedType == 'transporter',
                    onTap: () {
                      setState(() {
                        selectedType = 'transporter';
                      });
                    },
                    selectedTileColor: AppColors.baseColor,
                    leading: FaIcon(
                      FontAwesomeIcons.warehouse,
                      color: selectedType == 'transporter' ? AppColors.fullWhite : AppColors.baseColor,
                    ),
                    title: Text(
                      'Transporter',
                      style: selectedType == 'transporter' ? AppTextStyles.fontWhite20 : AppTextStyles.fontBlack20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30, bottom: MediaQuery.of(context).padding.bottom + 30),
            child: Consumer<RegisterUserProvider>(
              builder: (context, register, child) {
                return AppButtonConsumer(
                  clickAction: () => clickAction(register),
                  childWidget: RegisterUserProvider.loading == false
                      ? const Text(
                          'Next',
                          style: AppTextStyles.fontBoldWhite20,
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.fullWhite,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void clickAction(register) async {
    bool response = await register.createUserDoc(selectedType);
    if (response) {
      Navigator.pushNamed(context, AppRoutes.detailsPage);
      AuthenticationDataProvider().setRole(selectedType);
    }
  }
}
