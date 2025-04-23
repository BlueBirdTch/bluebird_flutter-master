// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'package:bluebird/api/firestore_api.dart';
import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/screens/trips/edit_trip_details.dart';
import 'package:bluebird/screens/trips/trip_details.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/utils/services/background_location_service.dart';
import 'package:bluebird/widgets/cusotm_expansion_tile.dart';
import 'package:bluebird/widgets/popups.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveJobTile extends StatefulWidget {
  const ActiveJobTile({
    Key? key,
    required this.document,
    required this.transporter,
  }) : super(key: key);
  final DocumentSnapshot document;
  final bool transporter;

  @override
  State<ActiveJobTile> createState() => _ActiveJobTileState();
}

class _ActiveJobTileState extends State<ActiveJobTile> {
  bool loading = false;
  DocumentSnapshot? document;
  @override
  void initState() {
    super.initState();
    setState(() {
      document = widget.document;
    });
  }

  void showPaymentCollection() {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.35, horizontal: MediaQuery.of(context).size.width * 0.05),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.fullWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("Collect Payment", style: AppTextStyles.fontBoldBlack20),
                const SizedBox(height: 12),
                const Text("Please collect payment from transporter and ask him to update the payment status on the app", style: AppTextStyles.fontBlack14),
                const Spacer(),
                AppTextButtonBold(text: 'OK', clickAction: () => Navigator.pop(context))
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.moonGrey,
            width: 1.0,
          ),
        ),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTileCustom(
          tilePadding: EdgeInsets.zero,
          leading: null,
          trailing: const SizedBox(),
          title: _buildTitleMethod(context),
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Last Location Update',
                      style: AppTextStyles.fontBlack14,
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<DataSnapshot>(
                        future: FirebaseDatabase.instance.ref("trips/${document?['trip_id']}").get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done && snapshot.data?.child('time').value != null) {
                            return Text(
                              '${snapshot.data!.child('time').value}',
                              style: AppTextStyles.fontBoldBlue20,
                            );
                          } else {
                            return const Text(
                              'N/A',
                              style: AppTextStyles.fontBoldBlue20,
                            );
                          }
                        })
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 36,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.near_me_rounded,
                        color: AppColors.baseColor,
                      ),
                    ),
                    Text(
                      'Live track',
                      style: AppTextStyles.fontBlack14.copyWith(fontSize: 12),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Total Cost: ₹ ${document?['totalAmount']}',
                        textAlign: TextAlign.left,
                        style: AppTextStyles.fontBoldBlue16.copyWith(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.60,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Advance Payment: ₹ ${document?['advanceAmount']}',
                        textAlign: TextAlign.left,
                        style: AppTextStyles.fontBoldBlue16.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 32,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TripDetails(
                              document: document!,
                              transporter: true,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.baseColor,
                      ),
                    ),
                    Text(
                      'Trip details',
                      style: AppTextStyles.fontBlack14.copyWith(fontSize: 10),
                    )
                  ],
                ),
              ],
            ),
            document?['status'] == 'NOT_ASSIGNED'
                ? Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '------',
                      textAlign: TextAlign.left,
                      style: AppTextStyles.fontBlack14.copyWith(fontSize: 12),
                    ),
                  )
                : AuthenticationDataProvider().getRole() == 'driver'
                    ? Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${document?['weight']}T of ${document?['cargoType']} payment per ${document?['paymentType']}',
                          textAlign: TextAlign.left,
                          style: AppTextStyles.fontBlack14.copyWith(fontSize: 12),
                        ),
                      )
                    : Container(),
            const SizedBox(height: 4),
            document?['status'] == 'NOT_ASSIGNED'
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.account_circle_rounded,
                        color: AppColors.baseColor,
                        size: 45,
                      ),
                      const SizedBox(width: 13),
                      Text(
                        'Driver not Assigned',
                        style: AppTextStyles.fontBoldBlue16.copyWith(fontSize: 18),
                      ),
                      const Spacer(),
                    ],
                  )
                : AuthenticationDataProvider().getRole() == 'driver'
                    ? FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(document?['uid']).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return SizedBox(
                              height: 60,
                              child: ListView(
                                shrinkWrap: true,
                                primary: false,
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: 45,
                                    width: MediaQuery.of(context).size.width - 44,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.account_circle_rounded,
                                          color: AppColors.baseColor,
                                          size: 45,
                                        ),
                                        const SizedBox(width: 13),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data!['fullName'],
                                              style: AppTextStyles.fontBoldBlue16.copyWith(fontSize: 18),
                                            ),
                                            Text(
                                              snapshot.data!['phoneNumber'],
                                              style: AppTextStyles.fontBoldBlue16,
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: 110,
                                          child: Text(
                                            'Swipe right for details',
                                            textAlign: TextAlign.end,
                                            style: AppTextStyles.fontGrey14.copyWith(fontSize: 11),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      launchUrl(Uri.parse('tel:${snapshot.data!['phoneNumber']}'));
                                    },
                                    child: Container(
                                      height: 60,
                                      width: 70,
                                      color: AppColors.baseColor,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.call_rounded,
                                            color: AppColors.fullWhite,
                                          ),
                                          Text(
                                            'Call',
                                            style: AppTextStyles.fontWhite14.copyWith(fontSize: 12),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      launchUrl(Uri.parse('sms:${snapshot.data!['phoneNumber']}'));
                                    },
                                    child: Container(
                                      height: 60,
                                      width: 70,
                                      decoration: BoxDecoration(border: Border.all(width: 1.0, color: AppColors.baseColor)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.sms_rounded,
                                            color: AppColors.baseColor,
                                          ),
                                          Text(
                                            'Message',
                                            style: AppTextStyles.fontBlue14.copyWith(fontSize: 12),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const Center(child: CircularProgressIndicator(color: AppColors.baseColor));
                          }
                        },
                      )
                    : FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance.collection('trips').doc(document?['trip_id']).collection('assignee').get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return SizedBox(
                              height: 60,
                              child: ListView(
                                shrinkWrap: true,
                                primary: false,
                                padding: EdgeInsets.zero,
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                children: [
                                  SizedBox(
                                    height: 45,
                                    width: MediaQuery.of(context).size.width - 44,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.account_circle_rounded,
                                          color: AppColors.baseColor,
                                          size: 45,
                                        ),
                                        const SizedBox(width: 13),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data!.docs[0]['fullName'],
                                              style: AppTextStyles.fontBoldBlue16.copyWith(fontSize: 18),
                                            ),
                                            Text(
                                              snapshot.data!.docs[0]['phoneNumber'],
                                              style: AppTextStyles.fontBoldBlue16,
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: 70,
                                          child: Text(
                                            'Swipe right for details',
                                            textAlign: TextAlign.end,
                                            style: AppTextStyles.fontGrey14.copyWith(fontSize: 12),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      launchUrl(Uri.parse('tel:${snapshot.data!.docs[0]['phoneNumber']}'));
                                    },
                                    child: Container(
                                      height: 60,
                                      width: 70,
                                      color: AppColors.baseColor,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.call_rounded,
                                            color: AppColors.fullWhite,
                                          ),
                                          Text(
                                            'Call',
                                            style: AppTextStyles.fontWhite14.copyWith(fontSize: 12),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      launchUrl(Uri.parse('sms:${snapshot.data!.docs[0]['phoneNumber']}'));
                                    },
                                    child: Container(
                                      height: 60,
                                      width: 70,
                                      decoration: BoxDecoration(border: Border.all(width: 1.0, color: AppColors.baseColor)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.sms_rounded,
                                            color: AppColors.baseColor,
                                          ),
                                          Text(
                                            'Message',
                                            style: AppTextStyles.fontBlue14.copyWith(fontSize: 12),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const Center(child: CircularProgressIndicator(color: AppColors.baseColor));
                          }
                        },
                      ),
            document?['status'] != "NOT_ASSIGNED" && AuthenticationDataProvider().getRole() == 'driver'
                ? StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('trips').doc(widget.document.id).snapshots(),
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.baseColor),
                        );
                      } else if (snapshot.connectionState == ConnectionState.active && snapshot.data!.data() != null) {
                        var tempcase;
                        return AppButton(
                            text: snapshot.data?.get('status') == 'ASSIGNED'
                                ? 'Start Loading'
                                : snapshot.data?.get('status') == 'LOADING_INITIATED'
                                    ? 'Start Trip'
                                    : snapshot.data?.get('status') == 'TRIP_STARTED'
                                        ? 'Start Unloading'
                                        : snapshot.data?.get('status') == 'UNLOADING_INITIATED'
                                            ? 'Confirm Unloading'
                                            : snapshot.data?.get('status') == 'PAYMENT_CONFIRM'
                                                ? ' Confirm Payment'
                                                : snapshot.data?.get('status') == 'PAYMENT_PENDING'
                                                    ? 'Collect Payment'
                                                    : 'END TRIP',
                            clickAction: () {
                              tempcase = snapshot.data?.get('status');
                              switch (tempcase) {
                                case 'PAYMENT_PENDING':
                                  showPaymentCollection();
                                  break;
                                default:
                                  _driverUpdateTripStatus(snapshot.data!.get('status'), snapshot.data!.get('trip_id'));
                                  break;
                              }
                            });
                      }
                      return const Center(child: CircularProgressIndicator(color: AppColors.baseColor));
                    }))
                : Container(),
            document?['status'] == 'PAYMENT_PENDING' && AuthenticationDataProvider().getRole() != 'driver'
                ? StreamBuilder(builder: ((context, snapshot) {
                    return AppButton(text: 'Complete Payment', clickAction: () => _showTransporterPaymentSheet());
                  }))
                : Container(),
            document?['status'] == 'ASSIGNED'
                ? AppTextButton(
                    text: 'Cancel Ride',
                    clickAction: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: MediaQuery.of(context).viewInsets,
                            child: AuthenticationDataProvider().getRole() == 'driver' ? ConfirmDriverCancelRide(document: document!) : ConfirmTransporterCancelRide(document: document!),
                          );
                        },
                      );
                    })
                : Container(),
            document?['status'] == 'NOT_ASSIGNED'
                ? Container(
                    padding: const EdgeInsets.only(top: 12),
                    child: AppButton(
                      clickAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditTripDetails(
                                    document: document!,
                                    isCancelled: false,
                                  ))),
                      text: 'Edit Trip details',
                    ),
                  )
                : Container(),
            document?['status'] == 'NOT_ASSIGNED'
                ? Container(
                    padding: const EdgeInsets.only(top: 12),
                    child: AppTextButton(
                      clickAction: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(color: AppColors.baseColor),
                                ),
                              );
                            });
                        bool response = await FirestoreAPIService().deleteTrip(document!.id);
                        if (response) {
                          Get.showSnackbar(const GetSnackBar(
                            message: 'Trip deleted successfully',
                            backgroundColor: AppColors.baseColor,
                            duration: Duration(seconds: 4),
                          ));
                        }
                        Navigator.pop(context);
                      },
                      text: 'Delete Trip',
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Future<void> _showTransporterPaymentSheet() async {
    await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: PaymentPopup(document: widget.document),
          );
        });
  }

  void _driverUpdateTripStatus(String status, String tripId) async {
    setState(() {
      loading = true;
    });
    switch (status) {
      case 'ASSIGNED':
        await FirebaseFirestore.instance.collection('trips').doc(widget.document['trip_id']).update({"status": "LOADING_INITIATED"});
        await FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).collection('active').doc(tripId).update({"status": "LOADING_INITIATED"});
        break;
      case 'LOADING_INITIATED':
        await FirebaseFirestore.instance.collection('trips').doc(widget.document['trip_id']).update({"status": "TRIP_STARTED"});
        await FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).collection('active').doc(tripId).update({"status": "TRIP_STARTED"});
        BackgroundLocationService().startLocationPosting(widget.document['trip_id']);
        break;
      case 'TRIP_STARTED':
        await FirebaseFirestore.instance.collection('trips').doc(widget.document['trip_id']).update({"status": "UNLOADING_INITIATED"});
        await FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).collection('active').doc(tripId).update({"status": "UNLOADING_INITIATED"});
        BackgroundLocationService().stopLocationPosting(widget.document['trip_id']);
        break;
      case 'UNLOADING_INITIATED':
        await FirebaseFirestore.instance.collection('trips').doc(widget.document['trip_id']).update({"status": "PAYMENT_PENDING"});
        await FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).collection('active').doc(tripId).update({"status": "PAYMENT_PENDING"});
        break;
      case 'PAYMENT_CONFIRM':
        await FirebaseFirestore.instance.collection('trips').doc(widget.document['trip_id']).update({"status": "PAYMENT_COMPLETE"});
        await FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).collection('active').doc(tripId).update({"status": "PAYMENT_COMPLETE"});
        break;
      case 'PAYMENT_COMPLETE':
        var milliseconds = DateTime.now().millisecondsSinceEpoch;
        await FirebaseFirestore.instance.collection('trips').doc(widget.document['trip_id']).update({"status": "COMPLETED", "completionDate": milliseconds});
        await FirebaseFirestore.instance
            .collection('users')
            .doc(AuthenticationService().getCurrentuserUID())
            .collection('active')
            .doc(tripId)
            .update({"status": "COMPLETED", "completionDate": milliseconds});
        break;
      default:
        AppSnackbars().showerrorSnackbar('An Error has occurred please try again later');
    }
    setState(() {
      loading = false;
    });
  }

  Container _buildTitleMethod(BuildContext context) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset('assets/images/connector.png'),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                height: 20,
                child: Text(
                  document?['loadingPointDetails']['name'],
                  style: AppTextStyles.fontBlack14.copyWith(overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(height: 8),
              const Text('to', style: AppTextStyles.fontBlue14),
              const SizedBox(height: 8),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                height: 20,
                child: Text(
                  document?['unloadingPointDetails']['name'],
                  style: AppTextStyles.fontBlack14.copyWith(overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              document?['status'] == 'ASSIGNED' || document?['status'] == 'ADVANCE_PAYMENT_WAITING'
                  ? const Text(
                      'Loading Date',
                      style: AppTextStyles.fontBlack14,
                    )
                  : const Text(
                      'Unloading Date',
                      style: AppTextStyles.fontBlack14,
                    ),
              document?['status'] == "NOT_ASSIGNED"
                  ? Text(
                      'N/A',
                      style: AppTextStyles.fontBlue27.copyWith(fontSize: 36),
                    )
                  : RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${DateTime.fromMillisecondsSinceEpoch(document?['loadingDate']).day}\n',
                            style: AppTextStyles.fontBlue27.copyWith(
                              fontSize: 36,
                            ),
                          ),
                          TextSpan(
                            text: DateFormat('MMM,yyyy').format(DateTime.fromMillisecondsSinceEpoch(document?['loadingDate'])),
                            style: AppTextStyles.fontBlue14,
                          ),
                        ],
                      ),
                    )
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                  child: Text(
                    'Delivery Info',
                    textAlign: TextAlign.end,
                    style: AppTextStyles.fontBlack14,
                  ),
                ),
                const SizedBox(height: 6),
                document?['status'] == "NOT_ASSIGNED"
                    ? const SizedBox(
                        height: 20,
                        child: Text(
                          'N/A',
                          style: AppTextStyles.fontBoldBlue14,
                        ),
                      )
                    : FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance.collection('trips').doc(document?['trip_id']).collection('assignee').get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.baseColor),
                            );
                          } else if (snapshot.connectionState == ConnectionState.done) {
                            return SizedBox(
                              height: 60,
                              child: RichText(
                                // overflow: TextOverflow.clip,
                                textAlign: TextAlign.end,
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: '${snapshot.data!.docs[0]['vehicleDetails'][0]['vehicle_name']}\n',
                                    style: AppTextStyles.fontBoldBlue14,
                                  ),
                                  TextSpan(
                                    text: '${snapshot.data!.docs[0]['vehicleDetails'][0]['vehicle_number']}\n',
                                    style: AppTextStyles.fontBlue14.copyWith(fontSize: 10),
                                  ),
                                  TextSpan(
                                    text: '${snapshot.data!.docs[0]['vehicleDetails'][0]['bodyType']}\n${snapshot.data!.docs[0]['vehicleDetails'][0]['category']}',
                                    style: AppTextStyles.fontBlue14.copyWith(fontSize: 10),
                                  ),
                                ]),
                              ),
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.baseColor),
                            );
                          }
                        },
                      ),
                const SizedBox(height: 6),
                document?['status'] == "NOT_ASSIGNED"
                    ? const SizedBox(
                        height: 20,
                        child: Text(
                          '-',
                          style: AppTextStyles.fontBoldBlue14,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CompletedJobTile extends StatefulWidget {
  const CompletedJobTile({
    Key? key,
    required this.document,
    required this.transporter,
  }) : super(key: key);
  final DocumentSnapshot document;
  final bool transporter;

  @override
  State<CompletedJobTile> createState() => _CompletedJobTileState();
}

class _CompletedJobTileState extends State<CompletedJobTile> {
  bool loading = false;
  DocumentSnapshot? document;
  @override
  void initState() {
    super.initState();
    setState(() {
      document = widget.document;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.moonGrey,
            width: 1.0,
          ),
        ),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTileCustom(
          tilePadding: EdgeInsets.zero,
          leading: null,
          trailing: const SizedBox(),
          title: _buildTitleMethod(context),
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Total Cost: ₹ ${document?['totalAmount']}',
                        textAlign: TextAlign.left,
                        style: AppTextStyles.fontBoldBlue16.copyWith(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.60,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Advance Payment: ₹ ${document?['advanceAmount']}',
                        textAlign: TextAlign.left,
                        style: AppTextStyles.fontBoldBlue16.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 32,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TripDetails(
                              document: document!,
                              transporter: true,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.baseColor,
                      ),
                    ),
                    Text(
                      'Trip details',
                      style: AppTextStyles.fontBlack14.copyWith(fontSize: 10),
                    )
                  ],
                ),
              ],
            ),
            AuthenticationDataProvider().getRole() == 'transporter' && widget.document['status'] == "CANCEL_TRIP_START"
                ? Container(
                    padding: const EdgeInsets.only(top: 12),
                    child: AppButton(
                      clickAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditTripDetails(
                                    document: document!,
                                    isCancelled: true,
                                  ))),
                      text: 'Edit Trip details',
                    ),
                  )
                : Container(),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Container _buildTitleMethod(BuildContext context) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset('assets/images/connector.png'),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                height: 20,
                child: Text(
                  document?['loadingPointDetails']['name'],
                  style: AppTextStyles.fontBlack14.copyWith(overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(height: 8),
              const Text('to', style: AppTextStyles.fontBlue14),
              const SizedBox(height: 8),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                height: 20,
                child: Text(
                  document?['unloadingPointDetails']['name'],
                  style: AppTextStyles.fontBlack14.copyWith(overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              document?['status'] == 'COMPLETED'
                  ? Text(
                      'COMPLETED',
                      style: AppTextStyles.fontBoldBlack14.copyWith(color: AppColors.statusOK),
                    )
                  : Text(
                      'CANCELLED',
                      style: AppTextStyles.fontBoldBlack14.copyWith(color: AppColors.errorRed),
                    ),
              document?['status'] == "CANCEL_TRIP_START"
                  ? Text(
                      'N/A',
                      style: AppTextStyles.fontBlue27.copyWith(fontSize: 36),
                    )
                  : RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${DateTime.fromMillisecondsSinceEpoch(document?['completionDate']).day}\n',
                            style: AppTextStyles.fontBlue27.copyWith(
                              fontSize: 36,
                            ),
                          ),
                          TextSpan(
                            text: DateFormat('MMM,yyyy').format(DateTime.fromMillisecondsSinceEpoch(document?['completionDate'])),
                            style: AppTextStyles.fontBlue14,
                          ),
                        ],
                      ),
                    )
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                  child: Text(
                    'Delivery Info',
                    textAlign: TextAlign.end,
                    style: AppTextStyles.fontBlack14,
                  ),
                ),
                const SizedBox(height: 6),
                document?['status'] == "CANCEL_TRIP_START"
                    ? const SizedBox(
                        height: 20,
                        child: Text(
                          'N/A',
                          style: AppTextStyles.fontBoldBlue14,
                        ),
                      )
                    : FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance.collection('trips').doc(document?['trip_id']).collection('assignee').get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.baseColor),
                            );
                          } else if (snapshot.connectionState == ConnectionState.done) {
                            return SizedBox(
                              height: 60,
                              child: RichText(
                                // overflow: TextOverflow.clip,
                                textAlign: TextAlign.end,
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: '${snapshot.data!.docs[0]['vehicleDetails'][0]['vehicle_name']}\n',
                                    style: AppTextStyles.fontBoldBlue14,
                                  ),
                                  TextSpan(
                                    text: '${snapshot.data!.docs[0]['vehicleDetails'][0]['vehicle_number']}\n',
                                    style: AppTextStyles.fontBlue14.copyWith(fontSize: 10),
                                  ),
                                  TextSpan(
                                    text: '${snapshot.data!.docs[0]['vehicleDetails'][0]['bodyType']}\n${snapshot.data!.docs[0]['vehicleDetails'][0]['category']}',
                                    style: AppTextStyles.fontBlue14.copyWith(fontSize: 10),
                                  ),
                                ]),
                              ),
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.baseColor),
                            );
                          }
                        },
                      ),
                const SizedBox(height: 6),
                document?['status'] == "CANCEL_TRIP_START"
                    ? const SizedBox(
                        height: 20,
                        child: Text(
                          '-',
                          style: AppTextStyles.fontBoldBlue14,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
