import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressLine = TextEditingController();
  final TextEditingController _landmark = TextEditingController();
  final TextEditingController _cityState = TextEditingController();
  final TextEditingController _pinCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.fullWhite,
        body: _body(context, height, width),
      ),
    );
  }

  Widget _body(BuildContext context, height, width) {
    return SizedBox(
      height: height,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              primary: false,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: height * 0.14),
                Container(
                  width: width,
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Identification Proof',
                    style: AppTextStyles.fontBoldBlue27,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: width,
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Please update your personal details as provided in your Aadhar Card for verification.',
                    style: AppTextStyles.fontBlack16,
                  ),
                ),
                SizedBox(height: height * 0.029),
                Container(
                  width: width,
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Personal Details',
                    style: AppTextStyles.fontBlue24,
                  ),
                ),
                const SizedBox(height: 18),
                AppTextField(
                  hintText: 'Eg: John Doe',
                  autoFocus: false,
                  textInput: TextInputType.name,
                  textController: _nameController,
                  labelText: 'Full Name',
                ),
                const SizedBox(height: 15),
                AppTextField(
                  hintText: 'Eg: 22/09/2021',
                  autoFocus: false,
                  textInput: TextInputType.none,
                  textController: _dateController,
                  labelText: 'Date of Birth',
                  onTapAction: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 100),
                      lastDate: DateTime.now(),
                      initialDatePickerMode: DatePickerMode.year,
                    ).then((date) {
                      var formattedDate = DateFormat('dd/MM/yyyy').format(date as DateTime);
                      setState(() {
                        _dateController.text = formattedDate;
                      });
                    });
                  },
                ),
                const SizedBox(height: 28),
                Container(
                  width: width,
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Address Details',
                    style: AppTextStyles.fontBlue24,
                  ),
                ),
                const SizedBox(height: 18),
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
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30, bottom: MediaQuery.of(context).padding.bottom + 30),
            child: Consumer<DetailsAddProvider>(
              builder: (context, details, child) {
                return AppButtonConsumer(
                  clickAction: () => clickAction(details, context),
                  childWidget: DetailsAddProvider.loading == false
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

  void clickAction(details, context) async {
    if (_nameController.text.isNotEmpty && _dateController.text.isNotEmpty && _addressLine.text.isNotEmpty && _landmark.text.isNotEmpty && _cityState.text.isNotEmpty && _pinCode.text.isNotEmpty) {
      var response = await details.postDetails(
        <String, dynamic>{
          'fullName': _nameController.text,
          'dateOfBirth': _dateController.text,
          'address_line': _addressLine.text,
          'landmark': _landmark.text,
          'city_state': _cityState.text,
          'pincode': _pinCode.text,
        },
      );
      if (response) {
        Navigator.pushNamed(context, AppRoutes.identityDetails);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().showerrorSnackbar('Please enter all the details') as SnackBar);
    }
  }
}
