// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'package:bluebird/api/firestore_api.dart';
import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditTripDetails extends StatefulWidget {
  const EditTripDetails({Key? key, required this.document, required this.isCancelled}) : super(key: key);
  final DocumentSnapshot document;
  final bool isCancelled;
  @override
  State<EditTripDetails> createState() => _EditTripDetailsState();
}

class _EditTripDetailsState extends State<EditTripDetails> {
  TextEditingController _source = TextEditingController();
  TextEditingController _dest = TextEditingController();
  TextEditingController _amount = TextEditingController();
  TextEditingController _weight = TextEditingController();
  TextEditingController _type = TextEditingController();
  int? loading, unloading;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initialiseTextFields();
    });
  }

  void initialiseTextFields() {
    _source.text = widget.document['loadingAddress'];
    _dest.text = widget.document['unloadingAddress'];
    _amount.text = widget.document['advanceAmount'].toString();
    _weight.text = widget.document['weight'].toString();
    _type.text = widget.document['cargoType'].toString();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.fullWhite,
      body: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: SizedBox(
                width: width,
                height: 55,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.baseColor,
                        size: 45,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.only(top: 13),
                      child: const Text(
                        'Edit Trip Information',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.fontBoldBlue27,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                primary: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 22),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text('Loading Point', style: AppTextStyles.fontBlack20.copyWith(color: AppColors.appGreen, fontSize: 18)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text(widget.document['loadingPointDetails']['address'], style: AppTextStyles.fontBoldBlue20),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text(widget.document['loadingAddress'], style: AppTextStyles.fontBlue16),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text('Unloading Point', style: AppTextStyles.fontBlack20.copyWith(color: AppColors.appGreen, fontSize: 18)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text(widget.document['unloadingPointDetails']['address'], style: AppTextStyles.fontBoldBlue20),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text(widget.document['unloadingAddress'], style: AppTextStyles.fontBlue16),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text('Total Amount', style: AppTextStyles.fontBoldBlue20),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text('₹ ${widget.document['totalAmount']}', style: AppTextStyles.fontBoldBlue24),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text('Loading Point Address', style: AppTextStyles.fontBlack20.copyWith(fontSize: 18)),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    textController: _source,
                    hintText: 'Source Address',
                    labelText: 'Source Address',
                    autoFocus: false,
                    textInput: TextInputType.text,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text('Unloading Point Address', style: AppTextStyles.fontBlack20.copyWith(fontSize: 18)),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    textController: _dest,
                    hintText: 'Destination Address',
                    labelText: 'Destination Address',
                    autoFocus: false,
                    textInput: TextInputType.none,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text('Advance Amount', style: AppTextStyles.fontBlack20.copyWith(fontSize: 18)),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    textController: _amount,
                    hintText: 'Advance Amount',
                    labelText: 'Advance Amount',
                    autoFocus: false,
                    textInput: TextInputType.text,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text('Cargo/Consignment Weight', style: AppTextStyles.fontBlack20.copyWith(fontSize: 18)),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    textController: _weight,
                    hintText: 'Cargo Weight',
                    labelText: 'Cargo Weight',
                    autoFocus: false,
                    textInput: TextInputType.text,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20, top: 20),
              child: AppButton(
                text: 'Confirm Changes',
                clickAction: () async {
                  Map<String, dynamic> data = widget.isCancelled
                      ? {
                          "loadingAddress": _source.text,
                          "unloadingAddress": _dest.text,
                          "advanceAmount": double.parse(_amount.text),
                          "weight": int.parse(_weight.text),
                          "status": "NOT_ASSIGNED",
                        }
                      : {
                          "loadingAddress": _source.text,
                          "unloadingAddress": _dest.text,
                          "advanceAmount": double.parse(_amount.text),
                          "weight": int.parse(_weight.text),
                        };
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const Center(
                        child: SizedBox(height: 40, width: 40, child: CircularProgressIndicator(color: AppColors.baseColor)),
                      );
                    },
                  );
                  if (widget.isCancelled) {
                    bool response = await FirestoreAPIService().editTrip(widget.document.id, data);
                    var assignee = await FirebaseFirestore.instance.collection('trips').doc(widget.document.id).collection('assignee').get();
                    await FirebaseFirestore.instance.collection('trips').doc(widget.document.id).collection('assignee').doc(assignee.docs[0].id).delete();
                    if (response) {
                      Get.showSnackbar(const GetSnackBar(
                        message: 'Trip Edited Successfully',
                        backgroundColor: AppColors.appGreen,
                        duration: Duration(seconds: 4),
                      ));
                    }
                  } else {
                    bool response = await FirestoreAPIService().editTrip(widget.document.id, data);
                    if (response) {
                      Get.showSnackbar(const GetSnackBar(
                        message: 'Trip Edited Successfully',
                        backgroundColor: AppColors.appGreen,
                        duration: Duration(seconds: 4),
                      ));
                    }
                  }
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homePage, (route) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
