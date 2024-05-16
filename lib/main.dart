import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:project_1304/notification_service.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackground);
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

@pragma("vm:entry-point")
Future<void> firebaseMessagingBackground(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("bg:${message.notification?.title}");
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NotificationService service = NotificationService();

  @override
  void initState() {

    service.requestNotification();
    service.forGroundMessage();
    service.firebaseInit(context);
    // service.isRefreshToken();

    service.getDeviceToken().then((value) {
      print("token:$value");
    });
    super.initState();
  }


  postApiToSendNotification(){
    service.getDeviceToken().then((value) async {
      var data = {
        "to": value.toString(),
        "priority": "high",
        "notification": {
          "title": "henil",
          "body": "hello how are you"
        },
        "data":{
          "type":"msj",
          "id":"1234"
        }
      };
      await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        body: jsonEncode(data),
        headers: {
          "Content-Type": 'application/json; charset=UTF-8',
          "Authorization":
          'key=AAAAumAUxnE:APA91bEAlKu6_4bPp_0pkYxbmVFEukZKj_ay9Zx9R47vHnmkFJdjK7gWCXmD4jtKOrKNwvEI7lpBnt4Ev3q6cOdSbrwC982l6fFLJzu24liDXWj0DERhy0bgZuIpeNxGOZ9C-RdrZoyq'
        },
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello"),
        centerTitle: true,
      ),
      body: Center(
          child: ElevatedButton(
              onPressed: () {
                postApiToSendNotification();
              },
              child: const Text("Send notification"))),
    );
  }
}

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("demo"),
        centerTitle: true,
      ),
    );
  }
}
