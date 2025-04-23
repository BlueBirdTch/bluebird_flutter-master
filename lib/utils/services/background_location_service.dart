import 'dart:async';

import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class BackgroundLocationService {
  FirebaseDatabase database = FirebaseDatabase.instance;
  static late Timer _timer;
  var box = GetStorage();

  Future<void> startLocationPosting(String tripId) async {
    getLocationUpdate(tripId);
    await box.write('locationUpdate', true);
    await box.write('activeTrip', tripId);
  }

  Future<void> stopLocationPosting(String tripId) async {
    _timer.cancel();
    await box.remove('locationUpdate');
    await box.remove('activeTrip');
    DatabaseReference ref = FirebaseDatabase.instance.ref("trips/$tripId");
    await ref.remove();
  }

  dynamic getLocationUpdate(String tripId) async {
    if (AuthenticationService().getUser() != null) {
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        String now = DateFormat('H:mm d-MMM-y').format(DateTime.now());
        Position location = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, forceAndroidLocationManager: true, timeLimit: const Duration(seconds: 5));
        DatabaseReference ref = FirebaseDatabase.instance.ref("trips/$tripId");
        await ref.set({
          "long": location.longitude,
          "lat": location.latitude,
          "time": now,
        });
      });
    }
  }
}
