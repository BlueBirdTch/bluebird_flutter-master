import 'dart:async';
import 'package:bluebird/config/res/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_curved_line/maps_curved_line.dart';

class LocationProvider extends ChangeNotifier {
  Completer<GoogleMapController>? mainController;
  List<Marker> markers = [const Marker(markerId: MarkerId('source')), const Marker(markerId: MarkerId('destination')), const Marker(markerId: MarkerId('live'))];
  Completer<GoogleMapController>? tripCompleter;
  List<Polyline> polyLine = [const Polyline(polylineId: PolylineId('jump'))];
  String sourceLocationName = '';
  String sourceId = '';
  LatLng? sourceLatLng;
  String sourceAddress = '';
  String destinationId = '';
  String destinationLocationName = '';
  LatLng? destLatLng;
  String destAddress = '';
  static CameraPosition currentLocation = const CameraPosition(target: LatLng(13.45, 67.45));

  Future<void> initialiseMainMaps() async {
    mainController = Completer();
  }

  Future<void> initialiseTripMaps() async {
    tripCompleter = Completer();
  }

  Future<void> setCameraNewLocation(LatLng target, double zoom) async {
    final GoogleMapController gmap = await mainController!.future;
    gmap.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: zoom)));
    notifyListeners();
  }

  Future<void> setSourceLocation(String id, String name, String address, LatLng source) async {
    sourceId = id;
    sourceLocationName = name;
    sourceLatLng = source;
    sourceAddress = address;
    BitmapDescriptor locationMarker = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'assets/images/location_marker.png');
    markers[0] = Marker(markerId: const MarkerId('source'), position: source, icon: locationMarker);
    final GoogleMapController gmap = await tripCompleter!.future;

    gmap.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: source, zoom: 15.6),
      ),
    );

    notifyListeners();
  }

  Future<void> setDestinationLocation(String id, String name, String address, LatLng dest) async {
    destinationId = id;
    destinationLocationName = name;
    destLatLng = dest;
    destAddress = address;
    BitmapDescriptor locationMarker = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'assets/images/location_marker.png');
    markers[1] = Marker(markerId: const MarkerId('destination'), position: dest, icon: locationMarker);
    final GoogleMapController gmap = await tripCompleter!.future;
    gmap.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: dest, zoom: 15.6),
      ),
    );
    notifyListeners();
  }

  Future<void> zoomOutCamera2points() async {
    final GoogleMapController gmap = await tripCompleter!.future;
    gmap.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: destLatLng!.latitude > sourceLatLng!.latitude ? sourceLatLng as LatLng : destLatLng as LatLng,
            northeast: destLatLng!.latitude > sourceLatLng!.latitude ? destLatLng as LatLng : sourceLatLng as LatLng),
        50,
      ),
    );
  }

  Future<void> createPolyLine() async {
    polyLine[0] = Polyline(
      polylineId: const PolylineId('jump'),
      visible: true,
      points: MapsCurvedLines.getPointsOnCurve(sourceLatLng as LatLng, destLatLng as LatLng),
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      color: AppColors.baseColor,
      width: 2,
      jointType: JointType.round,
    );
    notifyListeners();
  }

  Future<void> clearProvider() async {
    sourceId = '';
    sourceLocationName = '';
    sourceLatLng = null;
    sourceAddress = '';
    destinationId = '';
    destinationLocationName = '';
    destLatLng = null;
    destAddress = '';
    markers = [const Marker(markerId: MarkerId('source')), const Marker(markerId: MarkerId('destination'))];
    polyLine = [const Polyline(polylineId: PolylineId('jump'))];
    final GoogleMapController controller = await tripCompleter!.future;
    controller.dispose();
    notifyListeners();
  }

  Future<void> clearMainMap() async {
    final GoogleMapController controller = await mainController!.future;
    controller.dispose();
    notifyListeners();
  }
}
