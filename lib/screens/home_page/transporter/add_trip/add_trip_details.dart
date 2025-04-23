import 'package:bluebird/screens/home_page/transporter/add_trip/add_trip_location.dart';
import 'package:bluebird/utils/providers/location_service_provider.dart';
import 'package:bluebird/widgets/home_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AddTripDetails extends StatelessWidget {
  const AddTripDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            Consumer<LocationProvider>(builder: (context, location, child) {
              return GoogleMap(
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                markers: Set<Marker>.of(location.markers),
                polylines: Set<Polyline>.of(location.polyLine),
                initialCameraPosition: const CameraPosition(target: LatLng(17.360816, 78.468838), zoom: 15.67),
                onMapCreated: (GoogleMapController controller) async {
                  await location.initialiseTripMaps();
                  location.tripCompleter!.complete(controller);
                },
              );
            }),
            const LocationTrip(),
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
