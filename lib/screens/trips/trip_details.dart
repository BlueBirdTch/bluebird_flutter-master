import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/utils/providers/authentication_data_provider.dart';
import 'package:bluebird/utils/services/dynamic_link_service.dart';
import 'package:bluebird/widgets/popups.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class TripDetails extends StatefulWidget {
  const TripDetails({
    Key? key,
    required this.document,
    required this.transporter,
  }) : super(key: key);
  final DocumentSnapshot document;
  final bool transporter;

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SizedBox(
      height: height,
      width: width,
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
                      'Trip Information',
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
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
              children: [
                Text('Loading Point', style: AppTextStyles.fontBlack20.copyWith(color: AppColors.appGreen, fontSize: 18)),
                Text(widget.document['loadingPointDetails']['address'], style: AppTextStyles.fontBoldBlue20),
                Text(widget.document['loadingAddress'], style: AppTextStyles.fontBlue16),
                const SizedBox(height: 20),
                Text('Unloading Point', style: AppTextStyles.fontBlack20.copyWith(color: AppColors.appGreen, fontSize: 18)),
                Text(widget.document['unloadingPointDetails']['address'], style: AppTextStyles.fontBoldBlue20),
                Text(widget.document['unloadingAddress'], style: AppTextStyles.fontBlue16),
                SizedBox(height: widget.document['status'] == "CANCEL_TRIP_START" ? 0 : 28),
                widget.document['status'] == "CANCEL_TRIP_START"
                    ? Container()
                    : widget.transporter
                        ? Text('Delivery Partner', style: AppTextStyles.fontBlack16.copyWith(fontSize: 18))
                        : Text('Delivery Client', style: AppTextStyles.fontBlack16.copyWith(fontSize: 18)),
                const SizedBox(height: 10),
                widget.document['status'] == "CANCEL_TRIP_START"
                    ? Container()
                    : widget.document['status'] == 'NOT_ASSIGNED' && AuthenticationDataProvider().getRole() == 'transporter'
                        ? SizedBox(
                            height: 45,
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
                                Text(
                                  'Driver not Assigned',
                                  style: AppTextStyles.fontBoldBlue16.copyWith(fontSize: 18),
                                ),
                              ],
                            ),
                          )
                        : AuthenticationDataProvider().getRole() == 'driver'
                            ? FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('users').doc(widget.document['uid']).get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    return SizedBox(
                                      height: 60,
                                      child: ListView(
                                        shrinkWrap: true,
                                        primary: false,
                                        padding: EdgeInsets.zero,
                                        physics: const ClampingScrollPhysics(),
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
                                future: FirebaseFirestore.instance.collection('trips').doc(widget.document['trip_id']).collection('assignee').get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    return SizedBox(
                                      height: 60,
                                      child: ListView(
                                        shrinkWrap: true,
                                        primary: false,
                                        padding: EdgeInsets.zero,
                                        physics: const ClampingScrollPhysics(),
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
                const SizedBox(height: 20),
                const Text('Total Payment:', style: AppTextStyles.fontBoldBlue24),
                Text('₹ ${widget.document['totalAmount']}', style: AppTextStyles.fontBoldBlue24.copyWith(color: AppColors.appGreen)),
                Text('Advance Payment: ₹${widget.document['advanceAmount']}', style: AppTextStyles.fontBlack16.copyWith(fontSize: 18)),
                const SizedBox(height: 20),
                const Text('Consignment Details:', style: AppTextStyles.fontBoldBlue20),
                const SizedBox(height: 10),
                Text('Cargo Type: ${widget.document['weight']} tonnes of ${widget.document['cargoType']}', style: AppTextStyles.fontBlack16.copyWith(fontSize: 18)),
                Text(
                    'Payment Type: ₹${widget.document['paymentType'] == 'truck' ? widget.document['totalAmount'] / widget.document['trucks'] : widget.document['totalAmount'] / widget.document['weight']} per ${widget.document['paymentType']}',
                    style: AppTextStyles.fontBlack16.copyWith(fontSize: 18)),
                const SizedBox(height: 20),
                AppTextButtonBold(
                    text: 'Share this trip',
                    clickAction: () async {
                      var link = await FirebaseLinkService().createDyanmicLink(widget.document.id, widget.document['loadingPointDetails']['name'], widget.document['unloadingPointDetails']['name'],
                          widget.document['weight'].toString(), "tonned", widget.document['cargoType']);
                      if (kDebugMode) {
                        print("DEBUG: $link");
                      }
                      Share.share('Bluebird Shareable Trip $link');
                    })
              ],
            ),
          ),
          widget.transporter
              ? Container()
              : Container(
                  padding: EdgeInsets.only(top: 20, bottom: MediaQuery.of(context).padding.bottom + 20),
                  alignment: Alignment.center,
                  child: AppButton(
                    clickAction: () async {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: ConfirmTripPopup(document: widget.document),
                            );
                          });
                    },
                    text: 'Confirm Trip',
                  ),
                ),
        ],
      ),
    ));
  }
}
