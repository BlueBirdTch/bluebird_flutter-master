// ignore_for_file: use_build_context_synchronously

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddressPage extends StatelessWidget {
  AddressPage({Key? key}) : super(key: key);
  final TextEditingController _addressLine = TextEditingController();
  final TextEditingController _landmark = TextEditingController();
  final TextEditingController _cityState = TextEditingController();
  final TextEditingController _pinCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context),
      backgroundColor: AppColors.fullWhite,
      body: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                primary: true,
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 26),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 26),
                    child: Text('Add a new address', style: AppTextStyles.fontBoldBlack20),
                  ),
                  const SizedBox(height: 13),
                  AppTextField(
                    hintText: 'Eg: Eg: Flat/House No., Colony Name,',
                    autoFocus: false,
                    textInput: TextInputType.name,
                    textController: _addressLine,
                    labelText: 'Address Line',
                  ),
                  const SizedBox(height: 15),
                  AppTextField(
                    hintText: 'Eg: Near Municipal Office',
                    autoFocus: false,
                    textInput: TextInputType.text,
                    textController: _landmark,
                    labelText: 'Landmark',
                  ),
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 26),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width * 0.50,
                          child: AppTextField(
                            hintText: 'Eg: Mumbai, Maharashtra',
                            autoFocus: false,
                            textInput: TextInputType.name,
                            textController: _cityState,
                            labelText: 'City, State',
                            width: 20,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: AppTextField(
                            hintText: '500067',
                            maxLength: 6,
                            autoFocus: false,
                            textInput: TextInputType.number,
                            textController: _pinCode,
                            width: 20,
                            labelText: 'Pin-Code',
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                      child: AppButton(
                          text: 'Add Address',
                          clickAction: () async {
                            if (_addressLine.text.isEmpty || _landmark.text.isEmpty || _cityState.text.isEmpty || _pinCode.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().showerrorSnackbar('Please fill all the required fields') as SnackBar);
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: AppColors.baseColor)));
                                  });
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(AuthenticationService().getCurrentuserUID())
                                  .collection('addresses')
                                  .add({"address_line": _addressLine.text, "city_state": _cityState.text, "landmark": _landmark.text, "pincode": _pinCode.text});
                              Navigator.pop(context);
                            }
                          })),
                  const SizedBox(height: 26),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 26),
                    child: Text('Your Addresses', style: AppTextStyles.fontBoldBlack20),
                  ),
                  const SizedBox(height: 13),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).collection('addresses').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 26),
                            child: const CircularProgressIndicator(color: AppColors.baseColor),
                          ),
                        );
                      } else if (snapshot.connectionState == ConnectionState.active && snapshot.data?.size != 0) {
                        return Column(
                          children: List.generate(
                            snapshot.data!.size,
                            (index) => Theme(
                              data: ThemeData(dividerColor: Colors.transparent),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 26),
                                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.colorGrey, width: 0.8))),
                                child: ExpansionTile(
                                  title: Text('${snapshot.data!.docs[index]['address_line']}', style: AppTextStyles.fontBlue16.copyWith(fontSize: 18)),
                                  subtitle: Text('${snapshot.data!.docs[index]['city_state']}', style: AppTextStyles.fontBoldBlack14),
                                  trailing: Text('${snapshot.data!.docs[index]['pincode']}', style: AppTextStyles.fontBlue14),
                                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                  expandedAlignment: Alignment.topLeft,
                                  tilePadding: EdgeInsets.zero,
                                  childrenPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  children: [
                                    Text('${snapshot.data!.docs[index]['address_line']}', style: AppTextStyles.fontBlue16),
                                    Text('${snapshot.data!.docs[index]['landmark']}', style: AppTextStyles.fontBlue16),
                                    Text('${snapshot.data!.docs[index]['city_state']}', style: AppTextStyles.fontBlue16),
                                    Text('${snapshot.data!.docs[index]['pincode']}', style: AppTextStyles.fontBlue16),
                                    SizedBox(
                                      width: width,
                                      child: Center(
                                        child: TextButton(
                                          onPressed: () async {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: AppColors.baseColor)));
                                                });
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(AuthenticationService().getCurrentuserUID())
                                                .collection('addresses')
                                                .doc(snapshot.data!.docs[index].id)
                                                .delete();
                                            _addressLine.clear();
                                            _landmark.clear();
                                            _cityState.clear();
                                            _pinCode.clear();
                                            Navigator.pop(context);
                                          },
                                          child: Text('Delete Address', style: AppTextStyles.fontBoldBlue16.copyWith(color: AppColors.errorRed)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (snapshot.connectionState == ConnectionState.active && snapshot.data?.size == 0) {
                        return const Center(child: Text('Looks like you do not have any saved addresses', style: AppTextStyles.fontBlack14));
                      } else {
                        return const Center(child: Text('An unknown error has occurred', style: AppTextStyles.fontBlack14));
                      }
                    },
                  )
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
      title: const Text('Saved Addresses', style: AppTextStyles.fontBoldBlue20),
      centerTitle: true,
      actions: [
        TextButton(
          child: const Text('Back', style: AppTextStyles.fontBlack16),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}
