import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/uploadInfo.dart';
import 'package:flutter_app/home.dart';
import 'other/InternetConnection.dart';


void main() {
    runApp(new MyApp());
}

class MyApp extends StatefulWidget {


  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  void initState() {
    firebaseCloudMessaging_Listeners();
  }
  // ignore: non_constant_identifier_names
  void firebaseCloudMessaging_Listeners() {


    if (Platform.isIOS) iOS_Permission();
    _firebaseMessaging.getToken().then((token){
      print(token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }


  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
       debugShowCheckedModeBanner: false,
       title: "INDIZ",
       home:FutureBuilder<SharedPreferences>(builder: (_,snapshot){
         if(snapshot.connectionState==ConnectionState.waiting){
           return Scaffold(body: Center(child: CircularProgressIndicator(),),);
         }else{

          var login_status=snapshot.data.getInt("login_status");
          if(login_status==2){
            return HomeFragment();
          }
          else if(login_status==1){
            return uploadinfo();
          }
          else{
            return LoginPage();
          }
         }
       },future: SharedPreferences.getInstance())
     );
  }
}
