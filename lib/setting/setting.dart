import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login_page.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: RaisedButton(onPressed: (){
          FirebaseAuth.instance.signOut();
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>LoginPage()),(Route<dynamic> route)=>false);
        }),
      ),

    );
  }
}
