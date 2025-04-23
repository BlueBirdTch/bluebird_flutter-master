import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LiveLocationService {
  late LocationPermission permission;
  late bool serviceEnabled;

  Future<bool> requestLocationPermission() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.showSnackbar(const GetSnackBar(
        message: 'Location permissions not enabled',
        duration: Duration(seconds: 3),
      ));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        Get.showSnackbar(const GetSnackBar(
          message: 'You have chosen to disable location permissions, please go to settings to grant them to the app.',
          duration: Duration(seconds: 5),
        ));
        return false;
      }
    }
    return true;
  }

  Future<Position> getLiveLocation() async {
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best, timeLimit: const Duration(seconds: 30));
    return position;
  }
}
