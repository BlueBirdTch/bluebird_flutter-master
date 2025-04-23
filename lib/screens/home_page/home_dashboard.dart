import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/widgets/app_tiles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class HomeDashBoard extends StatefulWidget {
  const HomeDashBoard({Key? key}) : super(key: key);

  @override
  State<HomeDashBoard> createState() => _HomeDashBoardState();
}

class _HomeDashBoardState extends State<HomeDashBoard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SnappingSheet(
      grabbing: _buildGrabbingWidget(),
      sheetAbove: null,
      sheetBelow: _buildJobSheet(),
      grabbingHeight: 124,
      initialSnappingPosition: const SnappingPosition.factor(positionFactor: 0.24),
      snappingPositions: const [
        SnappingPosition.factor(
          positionFactor: 0.17,
          snappingCurve: Curves.easeInExpo,
          snappingDuration: Duration(milliseconds: 100),
          grabbingContentOffset: GrabbingContentOffset.top,
        ),
        SnappingPosition.factor(
          positionFactor: 0.65,
          snappingCurve: Curves.easeInExpo,
          snappingDuration: Duration(milliseconds: 100),
          grabbingContentOffset: GrabbingContentOffset.top,
        )
      ],
    );
  }

  SnappingSheetContent _buildJobSheet() {
    return SnappingSheetContent(
      draggable: false,
      child: Container(
        color: AppColors.fullWhite,
        child: TabBarView(
          controller: _tabController,
          children: [
            AuthenticationDataProvider().getRole() == 'transporter' ? const ActiveJobsTransporter() : const ActiveJobsDriver(),
            AuthenticationDataProvider().getRole() == 'transporter' ? const CompletedjobsTransporter() : const CompletedJobsDriver(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrabbingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AuthenticationDataProvider().getRole() == 'transporter'
            ? Container(
                margin: const EdgeInsets.only(right: 13, bottom: 13),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.baseColor,
                    elevation: 4,
                    shape: const CircleBorder(),
                    fixedSize: const Size(52, 52),
                  ),
                  child: Image.asset(
                    'assets/images/add_icon.png',
                    width: 36,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.addTrip);
                  },
                ),
              )
            : Container(
                margin: const EdgeInsets.only(right: 13, bottom: 13),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.baseColor,
                    elevation: 4,
                    shape: const CircleBorder(),
                    fixedSize: const Size(52, 52),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: AppColors.fullWhite,
                    size: 36,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.searchPage);
                  },
                ),
              ),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.fullWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 16,
                spreadRadius: 0,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 3,
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.38,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.moonGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 36,
                child: TabBar(
                  controller: _tabController,
                  unselectedLabelStyle: AppTextStyles.fontGrey20.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                  labelStyle: AppTextStyles.fontBlue20,
                  labelColor: AppColors.baseColor,
                  indicatorColor: AppColors.baseColor,
                  indicatorWeight: 2,
                  tabs: const [
                    Tab(text: 'ACTIVE'),
                    Tab(text: 'COMPLETED'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActiveJobsTransporter extends StatefulWidget {
  const ActiveJobsTransporter({Key? key}) : super(key: key);

  @override
  State<ActiveJobsTransporter> createState() => _ActiveJobsTransporterState();
}

class _ActiveJobsTransporterState extends State<ActiveJobsTransporter> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .where("uid", isEqualTo: AuthenticationService().getCurrentuserUID())
          .where("status", isNotEqualTo: 'COMPLETED')
          .where("status", whereIn: ["LOADING_INITIATED", "PAYMENT_CONFIRM", "TRIP_STARTED", "UNLOADING_INITIATED", "PAYMENT_PENDING", "PAYMENT_COMPLETE", "NOT_ASSIGNED", "ASSIGNED"]).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.baseColor));
        } else if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return ListView(
            shrinkWrap: true,
            primary: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            children: List.generate(
              snapshot.data!.size,
              (index) => ActiveJobTile(
                document: snapshot.data!.docs[index],
                transporter: true,
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'You have no Active Jobs',
              style: AppTextStyles.fontBlack16,
            ),
          );
        } else {
          return const Center(
              child: Icon(
            Icons.error_rounded,
            color: AppColors.errorRed,
          ));
        }
      },
    );
  }
}

class ActiveJobsDriver extends StatefulWidget {
  const ActiveJobsDriver({Key? key}) : super(key: key);

  @override
  State<ActiveJobsDriver> createState() => _ActiveJobsDriverState();
}

class _ActiveJobsDriverState extends State<ActiveJobsDriver> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(AuthenticationService().getCurrentuserUID())
          .collection('active')
          .where("status", whereIn: ["LOADING_INITIATED", "PAYMENT_CONFIRM", "TRIP_STARTED", "UNLOADING_INITIATED", "PAYMENT_PENDING", "PAYMENT_COMPLETE", "NOT_ASSIGNED", "ASSIGNED"]).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.baseColor));
        } else if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return ListView(
            shrinkWrap: true,
            primary: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            children: List.generate(
              snapshot.data!.size,
              (index) => ActiveJobTile(
                document: snapshot.data!.docs[index],
                transporter: false,
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'You have no Active Jobs',
              style: AppTextStyles.fontBlack16,
            ),
          );
        } else {
          return const Center(
              child: Icon(
            Icons.error_rounded,
            color: AppColors.errorRed,
          ));
        }
      },
    );
  }
}

class CompletedJobsDriver extends StatefulWidget {
  const CompletedJobsDriver({Key? key}) : super(key: key);

  @override
  State<CompletedJobsDriver> createState() => _CompletedJobsDriverState();
}

class _CompletedJobsDriverState extends State<CompletedJobsDriver> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).collection('active').where("status", whereIn: ["COMPLETED", "CANCEL_TRIP_START"]).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.baseColor));
        } else if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return ListView(
            shrinkWrap: true,
            primary: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            children: List.generate(
              snapshot.data!.size,
              (index) => CompletedJobTile(
                document: snapshot.data!.docs[index],
                transporter: false,
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'You have no Completed Jobs',
              style: AppTextStyles.fontBlack16,
            ),
          );
        } else {
          return const Center(
              child: Icon(
            Icons.error_rounded,
            color: AppColors.errorRed,
          ));
        }
      },
    );
  }
}

class CompletedjobsTransporter extends StatefulWidget {
  const CompletedjobsTransporter({Key? key}) : super(key: key);

  @override
  State<CompletedjobsTransporter> createState() => _CompletedjobsTransporterState();
}

class _CompletedjobsTransporterState extends State<CompletedjobsTransporter> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('trips').where("uid", isEqualTo: AuthenticationService().getCurrentuserUID()).where("status", whereIn: ['COMPLETED', 'CANCEL_TRIP_START']).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.baseColor));
        } else if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return ListView(
            shrinkWrap: true,
            primary: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            children: List.generate(
              snapshot.data!.size,
              (index) => CompletedJobTile(
                document: snapshot.data!.docs[index],
                transporter: true,
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'You have no Completed Jobs',
              style: AppTextStyles.fontBlack16,
            ),
          );
        } else {
          return const Center(
              child: Icon(
            Icons.error_rounded,
            color: AppColors.errorRed,
          ));
        }
      },
    );
  }
}
