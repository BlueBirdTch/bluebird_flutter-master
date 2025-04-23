import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fullWhite,
      appBar: _appBar(context),
      body: FutureBuilder(
        future: rootBundle.loadString("assets/docs/privacy.md"),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Markdown(data: snapshot.data as String);
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.fullWhite),
          );
        },
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.fullWhite,
      elevation: 0,
      title: const Text('Privacy Policy', style: AppTextStyles.fontBoldBlue20),
      centerTitle: true,
      leadingWidth: 75,
      leading: TextButton(
        child: const Text(
          'Back',
          style: AppTextStyles.fontBlack16,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
