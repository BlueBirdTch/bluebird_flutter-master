// ignore_for_file: depend_on_referenced_packages

import 'package:bluebird/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.high,
  playSound: true,
);

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final box = GetStorage();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  flutterLocalNotificationsPlugin.initialize(settings, onDidReceiveNotificationResponse: NotificationService().onSelectNotification);
  box.write('payload', message.data['video_uid']);
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class NotificationService {
  static const int count = 0;
  NotificationService() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  Future<String?> getFCMToken() async {
    var fcm = await FirebaseMessaging.instance.getToken();
    return fcm;
  }

  void initServices() async {
    await FirebaseMessaging.instance.requestPermission(alert: true, announcement: true, badge: false, carPlay: false, criticalAlert: false, provisional: false, sound: true);
    //Settings for Android
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    //Settings for iOS
    flutterLocalNotificationsPlugin.initialize(InitializationSettings(android: androidInitializationSettings), onDidReceiveNotificationResponse: NotificationService().onSelectNotification);
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<dynamic> onSelectNotification(payload) async {}

  static void renderOnMessage() {
    final box = GetStorage();
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        if (box.read('inApp') == 'true' || box.read('inApp') != null) {
          Get.showSnackbar(GetSnackBar(
            title: message.notification!.title,
            message: message.notification!.body,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.TOP,
          ));
        }
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ),
            payload: message.data['video_uid'],
          );
        }
      },
    );
  }

  // static void broadcastMessages() {
  //   FirebaseMessaging.onMessage.asBroadcastStream();
  // }

  static void renderOnMessageOpenedApp() {
    final box = GetStorage();
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        if (box.read('inApp') == 'true' || box.read('inApp') != null) {
          Get.showSnackbar(GetSnackBar(
            title: message.notification!.title,
            message: message.notification!.body,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.TOP,
          ));
        }
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ),
            payload: message.data['video_uid'],
          );
        }
      },
    );
  }

  static void renderLocalNotification() {
    flutterLocalNotificationsPlugin.show(
      1,
      'You’ve failed, Your Highness. I am a Jedi, like my father before me.',
      'I want to come with you to Alderaan. There’s nothing for me here now. I want to learn the ways of the Force, and become a Jedi like my father.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          color: Colors.blue,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
