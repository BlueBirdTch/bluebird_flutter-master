import 'package:bluebird/utils/services/deep_link_page.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirebaseLinkService {
  String baseUrl = 'https://bluebirdtest.page.link/';
  FirebaseLinkService() {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    dynamicLinks.onLink.listen((dynamicLinkData) {
      Navigator.push(Get.context as BuildContext, MaterialPageRoute(builder: (_) => DeepLinkPage(tripId: dynamicLinkData.link.toString().split('/').last)));
    });
    initDynamicLinks();
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    final String? deeplink = initialLink?.link.toString();
    if (deeplink != null) {
      Navigator.push(Get.context as BuildContext, MaterialPageRoute(builder: (_) => DeepLinkPage(tripId: deeplink.split('/').last)));
    }
  }

  Future<Uri> createDyanmicLink(String id, String start, String finish, String weight, String unit, String goods) async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("https://bluebirdtest.page.link/$id"),
      uriPrefix: baseUrl,
      androidParameters: const AndroidParameters(packageName: "com.ride.bluebird"),
      socialMetaTagParameters: SocialMetaTagParameters(title: "BlueBird Trip Link", description: "Bluebird shareable link for trip from $start to $finish for $weight $unit of $goods"),
    );
    final dynamicLink = await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);
    return dynamicLink;
  }
}
