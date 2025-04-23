import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    Key? key,
    required this.textController,
    required this.hintText,
    required this.labelText,
    required this.autoFocus,
    required this.textInput,
    this.onSubmitAction,
    this.onChangedAction,
    this.prefix,
    this.maxLength,
    this.width,
    this.onTapAction,
    this.suffix,
  }) : super(key: key);
  final TextEditingController textController;
  final String hintText;
  final String? labelText;
  final bool autoFocus;
  final String? prefix;
  final Widget? suffix;
  final void Function(String value)? onSubmitAction;
  final void Function(String value)? onChangedAction;
  final void Function()? onTapAction;
  final TextInputType textInput;
  final int? maxLength;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: width == null ? const EdgeInsets.symmetric(horizontal: 26) : const EdgeInsets.all(0),
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.fullWhite,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 1,
          color: AppColors.baseColor,
        ),
      ),
      child: TextFormField(
        keyboardType: textInput,
        controller: textController,
        autofocus: autoFocus,
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
        onChanged: onChangedAction ?? (value) {},
        onFieldSubmitted: onSubmitAction ?? (value) {},
        onTap: onTapAction ?? () {},
        style: AppTextStyles.fontBlack16,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.fontGrey16,
          suffix: suffix,
          label: labelText == null
              ? null
              : Text(
                  labelText!,
                  style: AppTextStyles.fontGrey14,
                ),
          prefix: prefix != null
              ? Container(
                  margin: const EdgeInsets.only(right: 5),
                  child: Text(
                    prefix!,
                    style: AppTextStyles.fontGrey16,
                  ),
                )
              : null,
          prefixStyle: AppTextStyles.fontGrey16,
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class AppTextSearchField extends StatelessWidget {
  const AppTextSearchField({
    Key? key,
    required this.textController,
    required this.hintText,
    required this.labelText,
    required this.autoFocus,
    required this.textInput,
    this.onSubmitAction,
    this.onChangedAction,
    this.prefix,
    this.maxLength,
    this.width,
    this.onTapAction,
  }) : super(key: key);
  final TextEditingController textController;
  final String hintText;
  final String? labelText;
  final bool autoFocus;
  final String? prefix;
  final void Function(String value)? onSubmitAction;
  final void Function(String value)? onChangedAction;
  final void Function()? onTapAction;
  final TextInputType textInput;
  final int? maxLength;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: width == null ? const EdgeInsets.symmetric(horizontal: 26) : const EdgeInsets.all(0),
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.fullWhite,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 1,
          color: AppColors.moonGrey,
        ),
      ),
      child: TextFormField(
        keyboardType: textInput,
        controller: textController,
        autofocus: autoFocus,
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
        onChanged: onChangedAction ?? (value) {},
        onFieldSubmitted: onSubmitAction ?? (value) {},
        onTap: onTapAction ?? () {},
        style: AppTextStyles.fontBlack16,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.fontGrey16,
          label: labelText == null
              ? null
              : Text(
                  labelText!,
                  style: AppTextStyles.fontGrey14,
                ),
          prefix: prefix != null
              ? Container(
                  margin: const EdgeInsets.only(right: 5),
                  child: Text(
                    prefix!,
                    style: AppTextStyles.fontGrey16,
                  ),
                )
              : null,
          prefixStyle: AppTextStyles.fontGrey16,
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class AppTextFieldNoBorder extends StatelessWidget {
  const AppTextFieldNoBorder({
    Key? key,
    required this.textController,
    required this.hintText,
    required this.labelText,
    required this.autoFocus,
    required this.textInput,
    this.onTap,
    this.suffix,
    this.onSubmitAction,
    this.onChangedAction,
    this.prefix,
    this.maxLength,
    this.showCursor,
  }) : super(key: key);
  final TextEditingController textController;
  final String hintText;
  final String? labelText;
  final bool autoFocus;
  final String? prefix;
  final Widget? suffix;
  final void Function(String value)? onSubmitAction;
  final void Function(String value)? onChangedAction;
  final void Function()? onTap;
  final TextInputType textInput;
  final int? maxLength;
  final bool? showCursor;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 1),
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.fullWhite.withAlpha(220),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        showCursor: showCursor ?? true,
        keyboardType: textInput,
        controller: textController,
        autofocus: autoFocus,
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
        onChanged: onChangedAction ?? (value) {},
        onFieldSubmitted: onSubmitAction ?? (value) {},
        onTap: onTap ?? () {},
        style: AppTextStyles.fontBlack16,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.fontGrey16,
          label: labelText == null
              ? null
              : Text(
                  labelText!,
                  style: AppTextStyles.fontGrey14,
                ),
          suffixIcon: suffix,
          prefixStyle: AppTextStyles.fontGrey16,
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class AppTextFieldElevated extends StatelessWidget {
  const AppTextFieldElevated({
    Key? key,
    required this.textController,
    required this.hintText,
    required this.labelText,
    required this.autoFocus,
    required this.textInput,
    this.onSubmitAction,
    this.onChangedAction,
    this.onTap,
    this.suffix,
    this.maxLength,
    this.multiline,
    this.showCursor,
  }) : super(key: key);
  final TextEditingController textController;
  final String hintText;
  final String? labelText;
  final bool autoFocus;
  final Widget? suffix;
  final void Function(String value)? onSubmitAction;
  final void Function(String value)? onChangedAction;
  final void Function()? onTap;
  final TextInputType textInput;
  final int? maxLength;
  final bool? multiline;
  final bool? showCursor;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 1),
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.fullWhite, borderRadius: BorderRadius.circular(15), boxShadow: const [
        BoxShadow(
          color: AppColors.blurGrey,
          blurRadius: 4,
          spreadRadius: 0,
          offset: Offset(0, 4),
        ),
      ]),
      child: TextFormField(
        showCursor: showCursor ?? true,
        keyboardType: textInput,
        controller: textController,
        autofocus: autoFocus,
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
        onChanged: onChangedAction ?? (value) {},
        onFieldSubmitted: onSubmitAction ?? (value) {},
        onTap: onTap ?? () {},
        style: AppTextStyles.fontBlack16,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.fontGrey16,
          label: labelText == null
              ? null
              : Text(
                  labelText!,
                  style: AppTextStyles.fontGrey14,
                ),
          suffixIcon: suffix,
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}
