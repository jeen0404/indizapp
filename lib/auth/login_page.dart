import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/other/InternetConnection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home.dart';
import 'signup.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/other/storeprefrence.dart';
import 'uploadInfo.dart';




class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String email="00";
  String password="00";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription _connectionChangeStream;
  bool isOffline = false;
  @override
  initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
  }
  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
  }




  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    print("signed in " + user.displayName);
    storeprefrence().storeemailuid(user.email,user.uid);
    return user;
  }


  @override
  Widget build(BuildContext context) {

    // logo of the app in top of the page
    Widget logo =             Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Image(image: AssetImage("assets/logo/logo.png"),width: 75.0,height: 75.0,),
        )
      ],
    );

    // email or username input text field
    Widget usernameemailtextfield = Row(mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          height: 50.0,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white,width: 1.0))),
          child: TextField(
            onChanged: (value)=>email=value,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),
            decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: "Email or username",
                hintStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),
                border: InputBorder.none
            ),
          ),
        )
      ],
    );


    // password input text field
    Widget passwordtextfield      =  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          height: 50.0,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white,width: 1.0))),
          child: TextField(
            onChanged: (value)=>password=value,
            textAlign: TextAlign.center,
            obscureText: true,
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),
            decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: "Password",
                hintStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),
                border: InputBorder.none
            ),
          ),
        )
      ],
    );

    // sign_up button to go sign_up page
    Widget signup                =          GestureDetector(
      onTap: (){  Navigator.push(context, MaterialPageRoute(builder:(builder)=>SignUp()));},
      child:  Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Container(
          width: 125.0,
          height: 50.0,
          child:Text("Sign-Up",style: TextStyle(color: Color(0xff00E5FF),fontSize: 22.0,fontWeight: FontWeight.bold),),
        ),
      ),
    );

    // login button for login
    Widget login                 =          GestureDetector(
      onTap: (){
        if(!isOffline){
          _onLoading();
        if(password.length < 8){
          showInSnackBar("check password length");
          Navigator.pop(context);
        }
        else{
          _auth.signInWithEmailAndPassword(email: email, password: password).then((user){
            storeprefrence().storeemailuid(user.email,user.uid);
          Navigator.pop(context);
            FirebaseDatabase.instance.reference().child("users").orderByChild("email").equalTo(user.email).once()
                .then((result){
              if(result.value == null){
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (builder)=>uploadinfo()),(Route<dynamic> route)=>false);
              }else{
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (builder)=>home()),(Route<dynamic> route)=>false);
              }
            }).catchError((e){
              showInSnackBar(e.message);
            });
          }).catchError((e){
            showInSnackBar(e.message);
            Navigator.pop(context);
          });
        }
        }
        else{
          showInSnackBar("check your internet connection");
          Navigator.pop(context);
        }
      },
      child:  Container(
        width: 125.0,
        height: 45.0,
        decoration: BoxDecoration(color: Color(0xffFF0066),borderRadius: BorderRadius.circular(5.0),
          //     boxShadow: [BoxShadow(color: Colors.grey,spreadRadius: 0.0,blurRadius:5.0)]
        ),
        child: Center(child:Text("Login",style: TextStyle(color: Colors.white,fontSize: 22.0,fontWeight: FontWeight.bold),),),
      ),
    );

    // to use available space
    Widget expand                =          Expanded(child: Container()); // to use available space of parent

    // putting both login and signup button into single row
    Widget loginsignup           =           Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        signup, // sign up button for go to signup activity
        login,  // login button for login
      ],
    );



    Future<bool> checkifperivioulyloedinwithgmail (FirebaseUser user) async{
     await FirebaseDatabase.instance.reference().child("users").orderByChild("email").equalTo(user.email).once()
          .then((result){
        if(result.value == null){
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (builder)=>uploadinfo()),(Route<dynamic> route)=>false);
        }else{
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (builder)=>home()),(Route<dynamic> route)=>false);
        }
      }).catchError((e){
        showInSnackBar(e.message);
      });
    }


    // google login button \
    Widget googlelogin = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: (){
            _onLoading();
            _handleSignIn()
          .then((FirebaseUser user){
              checkifperivioulyloedinwithgmail(user);
          })
              .catchError((e){
              showInSnackBar(e.message);
              Navigator.pop(context);
          });
          },
          child: Container(
            width: 250.0,
            height: 45.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xffFF0066),Color(0xffFF8800)],begin:Alignment.centerLeft,end: Alignment.centerRight),
              borderRadius: BorderRadius.circular(5.0),
              //     boxShadow: [BoxShadow(color: Colors.grey,spreadRadius: 0.0,blurRadius:5.0)]
            ),
            child: Center(child: Text("GOOGLE",style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20.0),),),
          ),
        ),
      ],
    );

    // help in login text or forgot password button
    Widget helpinlogin          =           Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text("Login trouble?",style: TextStyle(color: Colors.white),),
        )
      ],
    );


    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xffFE3083),Color(0xff0C0080)],begin:Alignment.topCenter,end: Alignment.bottomCenter)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            logo,  //logo of app

            expand,// to move every thing into bottom

            usernameemailtextfield, //input filed of email

            SizedBox(height: 5.0,), // for margin between both input field

            passwordtextfield,       // password text field

            SizedBox(height: 5.0,),

            loginsignup,            // login and signup field

            SizedBox(height: 5.0,),

            googlelogin,            //google login button

            SizedBox(height: 10.0,),

            helpinlogin             //help in login for forgot password
          ],
        ),
      ),
    );
  }
  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value,style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),duration: Duration(seconds: 2),backgroundColor: Colors.white,));
  }
  void _onLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        child:Container(
          width: 200.0,
          height: 200.0,
          //decoration: BoxDecoration(color: Colors.white70,borderRadius: BorderRadius.circular(10.0),),
          child: Center(child:FlareActor("flar/progress.flr", alignment:Alignment.center, animation:"Untitled"),),
        )
    );
  }
}