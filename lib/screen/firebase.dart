import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initFCM() async {
    // 1. Init local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);


    await _firebaseMessaging.requestPermission();
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenUser = prefs.getString('access_token');


    try {
      var rs = await Dio().post(
        "http://18.182.12.54:8080/identity/fcm/store-update-token?token=$token",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $tokenUser",
          },
        ),
      );
      print("tokenfb ${rs.data}");
    } catch (e) {
      print("firebaseerr $e");
    }

    // foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened: ${message.notification?.title}');
    });
  }


  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'fcm_channel', // ID
      'FCM Notifications', // name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'No title',
      message.notification?.body ?? 'No body',
      platformChannelSpecifics,
    );
  }


}

