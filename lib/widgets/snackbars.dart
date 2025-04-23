import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:flutter/material.dart';

class AppSnackbars {
  Widget showerrorSnackbar(String text) {
    return SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.fontWhite14,
      ),
      backgroundColor: AppColors.errorRed,
    );
  }

  Widget shoeMessageSnackbar(String text) {
    return SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.fontWhite14,
      ),
      backgroundColor: AppColors.baseColor,
    );
  }
}
