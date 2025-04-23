// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:bluebird/api/firestore_api.dart';
import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/utils/providers/trip_provider.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ConfirmTripPopup extends StatefulWidget {
  ConfirmTripPopup({Key? key, required this.document}) : super(key: key);
  DocumentSnapshot document;

  @override
  State<ConfirmTripPopup> createState() => _ConfirmTripPopupState();
}

class _ConfirmTripPopupState extends State<ConfirmTripPopup> {
  final TextEditingController _loadingDate = TextEditingController();
  final TextEditingController _unloadingDate = TextEditingController();
  final List<TextEditingController> _vehicles = [];
  final List<Map<dynamic, dynamic>> _selectedVehicles = [];
  int? loading;
  int? unloading;

  @override
  void initState() {
    super.initState();
    generateVehicleSelectors();
  }

  void generateVehicleSelectors() {
    if (widget.document['paymentType'] == 'tonne') {
      _vehicles.add(TextEditingController());
      _selectedVehicles.add({});
    } else {
      for (var vehicle = 0; vehicle < widget.document['trucks']; vehicle++) {
        _vehicles.add(TextEditingController());
        _selectedVehicles.add({});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * 0.65,
      decoration: BoxDecoration(color: AppColors.fullWhite, borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: Text('Confirm Trip', style: AppTextStyles.fontBoldBlue27)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              primary: false,
              padding: const EdgeInsets.symmetric(vertical: 0),
              children: [
                const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: Text('Estimated Loading Date', style: AppTextStyles.fontBlack20)),
                AppTextField(
                  textController: _loadingDate,
                  hintText: 'Estimated Loading Date',
                  labelText: 'Loading Date',
                  autoFocus: false,
                  textInput: TextInputType.none,
                  onTapAction: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 10)),
                      initialDatePickerMode: DatePickerMode.day,
                    ).then((date) {
                      var formattedDate = DateFormat('dd/MM/yyyy').format(date as DateTime);
                      setState(() {
                        _loadingDate.text = formattedDate;
                        loading = date.toLocal().millisecondsSinceEpoch;
                      });
                    });
                  },
                ),
                const SizedBox(height: 12),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: Text('Estimated Unloading Date', style: AppTextStyles.fontBlack20)),
                AppTextField(
                  textController: _unloadingDate,
                  hintText: 'Estimated Unloading Date',
                  labelText: 'Unloading Date',
                  autoFocus: false,
                  textInput: TextInputType.none,
                  onTapAction: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 10)),
                      initialDatePickerMode: DatePickerMode.day,
                    ).then((date) {
                      var formattedDate = DateFormat('dd/MM/yyyy').format(date as DateTime);
                      setState(() {
                        _unloadingDate.text = formattedDate;
                        unloading = date.toLocal().millisecondsSinceEpoch;
                      });
                    });
                  },
                ),
                const SizedBox(height: 12),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: Text('Vehicle Information', style: AppTextStyles.fontBlack20)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    _vehicles.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: AppTextField(
                        textController: _vehicles[index],
                        labelText: 'Vehicle ${index + 1}',
                        hintText: 'Vehicle Details',
                        autoFocus: false,
                        textInput: TextInputType.none,
                        onTapAction: () {
                          showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              Map<dynamic, dynamic> selected = {};
                              return Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: Container(
                                  width: width,
                                  height: height * 0.45,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.fullWhite),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 26),
                                      const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: Text('Select Vehicle', style: AppTextStyles.fontBoldBlue24)),
                                      const SizedBox(height: 12),
                                      Expanded(
                                        child: FutureBuilder<QuerySnapshot>(
                                          future: FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).collection('vehicles').get(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting || (snapshot.connectionState == ConnectionState.done && snapshot.data?.size == 0)) {
                                              return const Center(
                                                child: CircularProgressIndicator(color: AppColors.baseColor),
                                              );
                                            } else {
                                              return CupertinoPicker(
                                                itemExtent: 65,
                                                onSelectedItemChanged: (value) {
                                                  if (value != 0) {
                                                    selected = {
                                                      "bodyType": snapshot.data!.docs[value - 1]['bodyType'],
                                                      "category": snapshot.data!.docs[value - 1]['category'],
                                                      "vehicle_name": snapshot.data!.docs[value - 1]['vehicle_name'],
                                                      "vehicle_number": snapshot.data!.docs[value - 1]['vehicle_number'],
                                                      "vehicle_rc": snapshot.data!.docs[value - 1]['vehicle_rc'],
                                                    };
                                                  }
                                                },
                                                children: List.generate(
                                                  snapshot.data!.size + 1,
                                                  (vehicle) => vehicle == 0
                                                      ? const Text('-', style: AppTextStyles.fontBlack16)
                                                      : Text(
                                                          '${snapshot.data!.docs[vehicle - 1]['vehicle_name']}\n${snapshot.data!.docs[vehicle - 1]['vehicle_number']}\n${snapshot.data!.docs[vehicle - 1]['bodyType']} ${snapshot.data!.docs[vehicle - 1]['category']}',
                                                          textAlign: TextAlign.center,
                                                          style: AppTextStyles.fontBlack16),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.only(top: 20, bottom: MediaQuery.of(context).padding.bottom + 20),
                                        child: AppButton(
                                          text: 'Confirm',
                                          clickAction: () {
                                            _vehicles[index].text = selected['vehicle_name'] + ' ' + selected['bodyType'] + ' ' + selected['category'];
                                            _selectedVehicles[index] = selected;
                                            setState(() {});
                                            Navigator.pop(context);
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Consumer<TripProvider>(builder: (context, trip, child) {
            return Container(
              padding: EdgeInsets.only(top: 20, bottom: MediaQuery.of(context).padding.bottom + 20),
              alignment: Alignment.center,
              child: AppButtonConsumer(
                clickAction: () async {
                  bool value = true;
                  for (var i = 0; i < _vehicles.length; i++) {
                    if (_vehicles[i].text.isEmpty) {
                      value = false;
                    }
                  }
                  if (value == false) {
                    Get.showSnackbar(const GetSnackBar(message: 'Please fill all the fields', backgroundColor: AppColors.baseColor, duration: Duration(seconds: 3)));
                  } else {
                    if (loading != null && unloading != null) {
                      if (loading! > unloading!) {
                        Get.showSnackbar(const GetSnackBar(
                          message: 'Unloading Date has to be after Loading Date',
                          backgroundColor: AppColors.baseColor,
                          duration: Duration(seconds: 3),
                        ));
                      } else {
                        Map<String, dynamic> data = widget.document['paymentType'] == 'tonne'
                            ? {
                                'advanceAmount': widget.document['advanceAmount'],
                                'advanceType': widget.document['advanceType'],
                                'cargoType': widget.document['cargoType'],
                                'createdAt': widget.document['createdAt'],
                                'expiration_date': widget.document['expiration_date'],
                                'loadingAddress': widget.document['loadingAddress'],
                                'loadingPointDetails': widget.document['loadingPointDetails'],
                                'paymentType': widget.document['paymentType'],
                                'status': 'ASSIGNED',
                                'totalAmount': widget.document['totalAmount'],
                                'trip_id': widget.document['trip_id'],
                                'uid': widget.document['uid'],
                                'unloadingAddress': widget.document['unloadingAddress'],
                                'unloadingPointDetails': widget.document['unloadingPointDetails'],
                                'weight': widget.document['weight'],
                                'loadingDate': loading,
                                'unloadingDate': unloading,
                                'vehicleData': _selectedVehicles,
                              }
                            : {
                                'advanceAmount': widget.document['advanceAmount'],
                                'advanceType': widget.document['advanceType'],
                                'cargoType': widget.document['cargoType'],
                                'createdAt': widget.document['createdAt'],
                                'expiration_date': widget.document['expiration_date'],
                                'loadingAddress': widget.document['loadingAddress'],
                                'loadingPointDetails': widget.document['loadingPointDetails'],
                                'paymentType': widget.document['paymentType'],
                                'status': 'ASSIGNED',
                                'totalAmount': widget.document['totalAmount'],
                                'trip_id': widget.document['trip_id'],
                                'uid': widget.document['uid'],
                                'unloadingAddress': widget.document['unloadingAddress'],
                                'unloadingPointDetails': widget.document['unloadingPointDetails'],
                                'weight': widget.document['weight'],
                                'loadingDate': loading,
                                'unloadingDate': unloading,
                                'trucks': widget.document['trucks'],
                                'vehicleData': _selectedVehicles,
                              };
                        bool response = await trip.joinTrip(widget.document['trip_id'], data, loading!, unloading!);
                        if (response) {
                          ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().shoeMessageSnackbar('Joined Trip Successfully') as SnackBar);
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.homePage);
                        }
                      }
                    } else {
                      Get.showSnackbar(const GetSnackBar(
                        message: 'Please enter all the required fields',
                        backgroundColor: AppColors.baseColor,
                        duration: Duration(seconds: 3),
                      ));
                    }
                  }
                },
                childWidget: TripProvider.loading == false
                    ? const Text(
                        'Submit',
                        style: AppTextStyles.fontBoldWhite20,
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.fullWhite,
                        ),
                      ),
              ),
            );
          })
        ],
      ),
    );
  }
}

class ConfirmDriverCancelRide extends StatelessWidget {
  ConfirmDriverCancelRide({Key? key, required this.document}) : super(key: key);
  DocumentSnapshot document;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * 0.35,
      decoration: BoxDecoration(color: AppColors.fullWhite, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 26),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: Text('Are you sure you want to cancel the ride?', style: AppTextStyles.fontBoldBlue24)),
          const SizedBox(height: 26),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              primary: false,
              padding: const EdgeInsets.symmetric(horizontal: 26),
              children: [
                const SizedBox(height: 26),
                AppButton(
                    text: 'Confirm',
                    clickAction: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const Center(child: SizedBox(height: 40, width: 40, child: CircularProgressIndicator(color: AppColors.baseColor)));
                          });
                      bool response = await FirestoreAPIService().cancelTripDriver(document.id);
                      if (response) {
                        Get.showSnackbar(const GetSnackBar(message: 'Trip cancelled successfully', backgroundColor: AppColors.baseColor, duration: Duration(seconds: 4)));
                      }
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }),
                const SizedBox(height: 12),
                AppTextButton(text: 'Go Back', clickAction: () => Navigator.pop(context)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ConfirmTransporterCancelRide extends StatefulWidget {
  ConfirmTransporterCancelRide({Key? key, required this.document}) : super(key: key);
  DocumentSnapshot document;

  @override
  State<ConfirmTransporterCancelRide> createState() => _ConfirmTransporterCancelRideState();
}

class _ConfirmTransporterCancelRideState extends State<ConfirmTransporterCancelRide> {
  int? selected;

  String? reason;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * 0.65,
      decoration: BoxDecoration(color: AppColors.fullWhite, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 26),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 26),
            child: Text('Select you reason for cancelling the ride', style: AppTextStyles.fontBoldBlue20),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              primary: true,
              physics: const BouncingScrollPhysics(),
              children: [
                ListTile(
                  selected: selected == 0,
                  onTap: () {
                    setState(() {
                      selected = 0;
                      reason = 'Truck received through someone else';
                    });
                  },
                  minLeadingWidth: 26,
                  leading: Icon(selected == 0 ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected == 0 ? AppColors.baseColor : AppColors.moonGrey),
                  title: Text('Truck received through someone else', style: AppTextStyles.fontBlack16.copyWith(fontSize: 18)),
                ),
                ListTile(
                  selected: selected == 1,
                  onTap: () {
                    setState(() {
                      selected = 1;
                      reason = 'Truck received through Bluebird';
                    });
                  },
                  minLeadingWidth: 26,
                  leading: Icon(selected == 1 ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected == 1 ? AppColors.baseColor : AppColors.moonGrey),
                  title: Text('Truck received through Bluebird', style: AppTextStyles.fontBlack16.copyWith(fontSize: 18)),
                ),
                ListTile(
                  selected: selected == 2,
                  onTap: () {
                    setState(() {
                      selected = 2;
                      reason = 'Load got cancelled';
                    });
                  },
                  minLeadingWidth: 26,
                  leading: Icon(selected == 2 ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected == 2 ? AppColors.baseColor : AppColors.moonGrey),
                  title: Text('Load got cancelled', style: AppTextStyles.fontBlack16.copyWith(fontSize: 18)),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: MediaQuery.of(context).padding.bottom + 30),
            child: AppButton(
              text: 'Confirm',
              clickAction: () async {
                if (selected == null) {
                  Get.showSnackbar(const GetSnackBar(message: "Please select a cancellation reason", duration: Duration(seconds: 3), backgroundColor: AppColors.baseColor));
                } else {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const Center(child: SizedBox(height: 40, width: 40, child: CircularProgressIndicator(color: AppColors.baseColor)));
                      });
                  await FirestoreAPIService().cancelTripTransoprter(widget.document.id, reason as String);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().shoeMessageSnackbar('Trip Cancellation Successful') as SnackBar);
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

class ConfirmLogout extends StatelessWidget {
  const ConfirmLogout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * 0.30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColors.fullWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 26),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: Text('Are you sure you want to Logout?', textAlign: TextAlign.center, style: AppTextStyles.fontBoldBlue20)),
          const SizedBox(height: 26),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              primary: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 26),
              children: [
                AppButton(
                    text: 'Confirm',
                    clickAction: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: AppColors.baseColor)));
                          });
                      await AuthenticationService().signOutUser();
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.phoneNumberPage, (route) => false);
                    }),
                AppTextButton(text: 'Go Back', clickAction: () => Navigator.pop(context)),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 30)
        ],
      ),
    );
  }
}

class PaymentPopup extends StatefulWidget {
  PaymentPopup({Key? key, required this.document}) : super(key: key);
  DocumentSnapshot document;
  @override
  State<PaymentPopup> createState() => _PaymentPopupState();
}

class _PaymentPopupState extends State<PaymentPopup> {
  String paymentCallbackUrl = "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=";
  //Replace with this in production "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID="
  int paymentMode = 0;
  dynamic result;
  dynamic tokenResult;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * 0.60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColors.fullWhite,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Total Amount:", style: AppTextStyles.fontBoldBlack14.copyWith(fontSize: 16)),
                    Text("₹ ${widget.document['totalAmount']}", style: AppTextStyles.fontBoldBlue20),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Advance Amount:", style: AppTextStyles.fontBoldBlack14.copyWith(fontSize: 16)),
                    Text("₹ ${widget.document['advanceAmount']}", style: AppTextStyles.fontBoldBlue20),
                  ],
                )
              ],
            ),
            const SizedBox(height: 30),
            const Text("Amount to be paid:", style: AppTextStyles.fontBoldBlack20),
            Text("₹ ${widget.document['totalAmount'] - widget.document['advanceAmount']}", style: AppTextStyles.fontBoldBlue24),
            const SizedBox(height: 12),
            const Text("Select Mode of Payment: ", style: AppTextStyles.fontBoldBlack20),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  paymentMode = 0;
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    paymentMode == 0 ? const Icon(Icons.circle, color: AppColors.baseColor) : const Icon(Icons.circle_outlined, color: AppColors.baseColor),
                    const SizedBox(width: 12),
                    const Text("Net Banking", style: AppTextStyles.fontBlack16),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  paymentMode = 1;
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    paymentMode == 1 ? const Icon(Icons.circle, color: AppColors.baseColor) : const Icon(Icons.circle_outlined, color: AppColors.baseColor),
                    const SizedBox(width: 12),
                    const Text("Credit/Debit Card", style: AppTextStyles.fontBlack16),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  paymentMode = 2;
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    paymentMode == 2 ? const Icon(Icons.circle, color: AppColors.baseColor) : const Icon(Icons.circle_outlined, color: AppColors.baseColor),
                    const SizedBox(width: 12),
                    const Text("UPI", style: AppTextStyles.fontBlack16),
                  ],
                ),
              ),
            ),
            const Spacer(),
            loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.baseColor))
                : AppButton(
                    text: "Confirm Payment",
                    clickAction: () async {
                      setState(() {
                        loading = true;
                      });
                      //await getTransactionToken("Payment", orderId, callbackurl, callbackUrl, widget.document['totalAmount'] - double.parse(widget.document['advanceAmount']), custId, checksum)
                      //await _paytmPaymentCall(mid, orderId, amount, txnToken, callbackurl, true, false)
                      await FirebaseFirestore.instance.collection('trips').doc(widget.document.id).update({"status": "PAYMENT_CONFIRM"});
                      var driverAssignee = await FirebaseFirestore.instance.collection('trips').doc(widget.document.id).collection('assignee').get();
                      var number = driverAssignee.docs[0]['phoneNumber'];
                      var driverDoc = await FirebaseFirestore.instance.collection('users').where("phoneNumber", isEqualTo: number).get();
                      await FirebaseFirestore.instance.collection('users').doc(driverDoc.docs[0].id).update({"status": "PAYMENT_CONFIRM"});
                      setState(() {
                        loading = false;
                      });
                      Navigator.pop(context);
                    }),
          ],
        ),
      ),
    );
  }

  Future<void> getTransactionToken(requestType, mid, orderId, callbackUrl, websiteName, txnAmount, custId, checksum) async {
    var url = Uri.https('example.com', '/getTxnToken');
    var data = {
      "body": {
        "requestType": requestType,
        "mid": mid,
        "websiteName": websiteName,
        "orderId": orderId,
        "txnAmount": {
          "value": txnAmount,
          "currency": "INR",
        },
        "userInfo": {
          "custId": custId,
        },
        "callbackUrl": callbackUrl,
      },
      "head": {
        "signature": checksum,
      }
    };
    var response = await http.post(url, body: data);
    if (response.statusCode == 200) {
      tokenResult = response.body;
    }
  }

  Future<void> _paytmPaymentCall(mid, orderId, amount, txnToken, callbackurl, isStaging, restrictAppInvoke) async {
    var response = AllInOneSdk.startTransaction(mid, orderId, amount, txnToken, callbackurl, isStaging, restrictAppInvoke);
    response.then((value) {
      setState(() {
        result = value.toString();
      });
    }).catchError((onError) {
      if (onError is PlatformException) {
        setState(() {
          result = "${onError.message!} \n  ${onError.details}";
        });
      } else {
        setState(() {
          result = onError.toString();
        });
      }
    });
  }
}
