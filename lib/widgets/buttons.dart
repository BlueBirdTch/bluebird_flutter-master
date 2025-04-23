import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    Key? key,
    required this.text,
    required this.clickAction,
  }) : super(key: key);
  final String text;
  final void Function() clickAction;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.baseColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        fixedSize: Size(MediaQuery.of(context).size.width - 52, 60),
      ),
      onPressed: clickAction,
      child: Text(
        text,
        style: AppTextStyles.fontBoldWhite20,
      ),
    );
  }
}

class AppButtonWhite extends StatelessWidget {
  const AppButtonWhite({
    Key? key,
    required this.text,
    required this.clickAction,
  }) : super(key: key);
  final String text;
  final void Function() clickAction;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.fullWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        fixedSize: Size(MediaQuery.of(context).size.width - 52, 60),
      ),
      onPressed: clickAction,
      child: Text(
        text,
        style: AppTextStyles.fontBoldBlue20,
      ),
    );
  }
}

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    Key? key,
    required this.text,
    required this.clickAction,
  }) : super(key: key);
  final String text;
  final void Function() clickAction;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: clickAction,
      child: Text(text, style: AppTextStyles.fontBoldBlue16),
    );
  }
}

class AppTextButtonBold extends StatelessWidget {
  const AppTextButtonBold({
    Key? key,
    required this.text,
    required this.clickAction,
  }) : super(key: key);
  final String text;
  final void Function() clickAction;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: clickAction,
      child: Text(text, style: AppTextStyles.fontBoldBlue16),
    );
  }
}

class AppButtonConsumer extends StatelessWidget {
  const AppButtonConsumer({
    Key? key,
    this.text,
    required this.clickAction,
    required this.childWidget,
  }) : super(key: key);
  final String? text;
  final void Function() clickAction;
  final Widget childWidget;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.baseColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        fixedSize: Size(MediaQuery.of(context).size.width - 52, 60),
      ),
      onPressed: clickAction,
      child: childWidget,
    );
  }
}

class AppButtonWhiteConsumer extends StatelessWidget {
  const AppButtonWhiteConsumer({
    Key? key,
    this.text,
    required this.clickAction,
    required this.childWidget,
  }) : super(key: key);
  final String? text;
  final void Function() clickAction;
  final Widget childWidget;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.fullWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        fixedSize: Size(MediaQuery.of(context).size.width - 52, 60),
      ),
      onPressed: clickAction,
      child: childWidget,
    );
  }
}
