import 'dart:io';

import 'package:bluebird/widgets/widgets.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraService {
  Future<XFile?> _takePicture(CameraController controller) async {
    if (controller.value.isInitialized && controller.value.isTakingPicture) {
      return null;
    }
    try {
      XFile file = await controller.takePicture();
      return file;
    } on CameraException {
      ScaffoldMessenger.of(Get.context as BuildContext).showSnackBar(AppSnackbars().showerrorSnackbar('Unable to take picture, Please try again') as SnackBar);
    }
    return null;
  }

  Future<String?> clickPicture(CameraController controller) async {
    XFile? file = await _takePicture(controller);
    File imageFile = File(file!.path);
    return imageFile.path;
  }
}
