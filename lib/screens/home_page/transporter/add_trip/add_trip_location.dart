import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/screens/home_page/transporter/add_trip/confirm_trip.dart';
import 'package:bluebird/screens/home_page/transporter/add_trip/location_search.dart';
import 'package:bluebird/utils/providers/location_service_provider.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class LocationTrip extends StatefulWidget {
  const LocationTrip({Key? key}) : super(key: key);

  @override
  State<LocationTrip> createState() => _LocationTripState();
}

class _LocationTripState extends State<LocationTrip> {
  final TextEditingController _startLocation = TextEditingController();
  final TextEditingController _endLocation = TextEditingController();
  LocationProvider? location;
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    location = Provider.of<LocationProvider>(context, listen: false);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height,
      alignment: Alignment.bottomCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 80),
          locationSetter(width, _startLocation, context, _endLocation),
          const Spacer(),
          Center(
            child: AppButton(
              text: 'Next',
              clickAction: () {
                if (_startLocation.text.isNotEmpty && _endLocation.text.isNotEmpty) {
                  showModalBottomSheet(
                    isDismissible: true,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child: ConfirmTrip(
                          source: {
                            'name': location!.sourceLocationName,
                            'id': location!.sourceId,
                            'latitude': location!.sourceLatLng!.latitude,
                            'longitude': location!.sourceLatLng!.longitude,
                            'address': location!.sourceAddress,
                          },
                          destination: {
                            'name': location!.destinationLocationName,
                            'id': location!.destinationId,
                            'latitude': location!.destLatLng!.latitude,
                            'longitude': location!.destLatLng!.longitude,
                            'address': location!.destAddress,
                          },
                          distance: calculateDistance(location!.sourceLatLng!.latitude, location!.sourceLatLng!.longitude, location!.destLatLng!.latitude, location!.destLatLng!.longitude),
                        ),
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().shoeMessageSnackbar('Please enter all the required fields') as SnackBar);
                }
              },
            ),
          ),
          Center(
            child: AppTextButton(
              text: 'Go Back',
              clickAction: () {
                location!.clearProvider();
                Navigator.pop(context);
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }

  Row locationSetter(double width, TextEditingController startLocation, BuildContext context, TextEditingController endLocation) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 23),
          child: Image.asset('assets/images/connector.png', height: 80),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: width - 72,
              child: AppTextFieldElevated(
                textController: startLocation,
                hintText: 'Enter loading point location',
                labelText: 'Loading point',
                autoFocus: false,
                textInput: TextInputType.none,
                suffix: const Icon(Icons.search_rounded, color: AppColors.fullBlack, size: 32),
                showCursor: false,
                onTap: () async {
                  await showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child: const LocationSearch(
                          soure: true,
                          destination: false,
                          hintText: 'Enter pickup location',
                        ),
                      );
                    },
                  );
                  if (location!.sourceLatLng != null) {
                    startLocation.text = '${location!.sourceLocationName}, ${location!.sourceAddress}';
                    startLocation.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
                    if (location!.destLatLng != null) {
                      Future.delayed(const Duration(seconds: 3), () {
                        location!.zoomOutCamera2points();
                        location!.createPolyLine();
                      });
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 19),
            SizedBox(
              width: width - 72,
              child: AppTextFieldElevated(
                textController: endLocation,
                hintText: 'Enter unload point location',
                labelText: 'Unloading point',
                autoFocus: false,
                textInput: TextInputType.none,
                suffix: const Icon(Icons.search_rounded, color: AppColors.fullBlack, size: 32),
                showCursor: false,
                onTap: () async {
                  await showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child: const LocationSearch(
                          soure: false,
                          destination: true,
                          hintText: 'Enter unloading location',
                        ),
                      );
                    },
                  );
                  if (location!.destLatLng != null) {
                    endLocation.text = '${location!.destinationLocationName}, ${location!.destAddress}';
                    endLocation.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
                    if (location!.sourceLatLng != null) {
                      Future.delayed(const Duration(seconds: 3), () {
                        location!.zoomOutCamera2points();
                        location!.createPolyLine();
                      });
                    }
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(width: 31),
      ],
    );
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
