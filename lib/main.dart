import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/uploadInfo.dart';
import 'home.dart';
import 'other/InternetConnection.dart';


void main(){
  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  runApp(MyApp());
}



class MyApp extends StatefulWidget {


  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    firebaseCloudMessaging_Listeners();
  }
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
       home:FutureBuilder(builder: (_,snapshot){
         if(snapshot.connectionState==ConnectionState.waiting){
           return Scaffold(body: Center(child: CircularProgressIndicator(),),);
         }else{
          if(snapshot.hasData){
           return FutureBuilder(builder: (_,snapshot){
             if(snapshot.connectionState==ConnectionState.waiting){
               return Scaffold(body: Center(child: CircularProgressIndicator(),),);
             }
             else{
               if(snapshot.data.value!=null){
               return home();
               }
               else{
                 return uploadinfo();
               }
             }
           },future:  FirebaseDatabase.instance.reference().child("users").child(snapshot.data.uid).once());
          } else{
           return LoginPage();
          }
         }
       },future: FirebaseAuth.instance.currentUser(),)
     );
  }
}
