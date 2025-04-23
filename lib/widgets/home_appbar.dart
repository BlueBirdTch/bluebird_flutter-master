import 'dart:async';

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/screens/profile/profile.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 8,
      ),
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 17, right: 17),
      width: width,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xDEFFFFFF),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            icon: const Icon(
              Icons.settings_rounded,
              color: AppColors.colorBlack,
              size: 32,
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AuthenticationDataProvider.role == 'driver'
                    ? 'Hi, ${AuthenticationDataProvider.fireUserDataDriver?.fullName.split(' ')[0]}'
                    : AuthenticationDataProvider.role == 'transporter'
                        ? 'Hi, ${AuthenticationDataProvider.fireUserTransporter?.fullName.split(' ')[0]}'
                        : '-',
                style: AppTextStyles.fontBlack20,
              ),
              const TimeWidget(),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage())),
            icon: const Icon(Icons.account_circle_rounded, color: AppColors.colorBlack, size: 32),
          ),
        ],
      ),
    );
  }
}

class TimeWidget extends StatefulWidget {
  const TimeWidget({Key? key}) : super(key: key);

  @override
  State<TimeWidget> createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  DateFormat date = DateFormat('dd MMM yyyy');
  DateFormat time = DateFormat('jm');
  String _homeTime = '';
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      getCurrentTime();
    });
  }

  void getCurrentTime() {
    if (mounted) {
      setState(() {
        _homeTime = '${time.format(DateTime.now())} ${date.format(DateTime.now())}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _homeTime,
      style: AppTextStyles.fontBlue14,
    );
  }
}
