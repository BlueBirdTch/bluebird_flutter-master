// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/screens/home_page/home_dashboard.dart';
import 'package:bluebird/utils/providers/location_service_provider.dart';
import 'package:bluebird/utils/services/live_location_service.dart';
import 'package:bluebird/widgets/home_appbar.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  LocationProvider? location;
  bool locationPermission = false;
  Future<Position>? liveLocation;
  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    getLocation();
  }

  void requestLocationPermission() async {
    locationPermission = await LiveLocationService().requestLocationPermission();
    setState(() {});
  }

  // Future<void> getLiveLocationDevice() async {
  //   Timer.periodic(const Duration(seconds: 5), ((timer) async {
  //     liveLocation = LiveLocationService().getLiveLocation();
  //   }));
  // }

  late GoogleMapController mapController;

  LatLng? _currentPosition;
  bool _isLoading = true;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);

    setState(() {
      _currentPosition = location;
      _isLoading = false;
      MarkerId markerId = const MarkerId('current');
      final Marker marker = Marker(markerId: markerId, position: LatLng(lat, long));
      markers[markerId] = marker;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    location = Provider.of<LocationProvider>(context, listen: false);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            locationPermission
                ? _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        onMapCreated: _onMapCreated,
                        markers: Set<Marker>.of(markers.values),
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition!,
                          zoom: 16.0,
                        ),
                      )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Please give location permission to the app from Settings > Apps&Permissions',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.fontBlue16,
                        ),
                        const SizedBox(height: 20),
                        AppTextButton(text: 'Open Settings', clickAction: () => openAppSettings())
                      ],
                    ),
                  ),
            const HomeDashBoard(),
            Container(
              alignment: Alignment.topCenter,
              child: const HomeAppBar(),
            ),
          ],
        ),
      ),
    );
  }
}
