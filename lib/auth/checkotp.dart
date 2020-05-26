import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/home.dart';
import 'login_page.dart';
import 'signup.dart';

// ignore: camel_case_types
class checkotp extends StatefulWidget {
  var varId;
  checkotp(varId){
    this.varId=varId;
  }
  @override
  _checkotpState createState() => _checkotpState(varId);
}

// ignore: camel_case_types
class _checkotpState extends State<checkotp> {
  var varId;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  _checkotpState(varid){
    this.varId=varid;
  }

  verificaficationcomplite() async{
    FirebaseUser user =await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(user.uid).updateData({"phone_verified":true});
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(builder)=>HomeFragment()),(Route<dynamic> routs)=>false);
  }

  String Otp="0";
  void _signInWithPhoneNumber(String smsCode) async {
    AuthCredential credential = PhoneAuthProvider.getCredential(
    verificationId: varId,
    smsCode: this.Otp,
    );
    final FirebaseUser user = await FirebaseAuth.instance.signInWithCredential(credential);
    if(user.uid != null){
      verificaficationcomplite();
    }
    else{
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("check otp again"),duration: Duration(seconds: 1),));
    }
  }

  @override
  Widget build(BuildContext context) {

    // logo of the app in top of the page
    Widget logo = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Image(image: AssetImage("assets/logo/logo.png"),width: 75.0,height: 75.0,),
        )
      ],
    );

    // email or username input text field
    Widget otpinputfield =   Row(mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          height: 50.0,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white,width: 1.0))),
          child: TextField(
            onChanged: (value)=>this.Otp=value,
          keyboardType: TextInputType.numberWithOptions(),
          textAlign: TextAlign.center,
           maxLength: 6,
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),
            decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: "Enter Otp Here",
                hintStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),
                border: InputBorder.none
            ),
          ),
        )
      ],
    );

    // login button for login
    Widget createaccount         =        GestureDetector(
      onTap: (){
        if(this.Otp.length>5) {
          _signInWithPhoneNumber(this.Otp);
        }
        else{
          showInSnackBar("check otp again");
        }

        },
      child: Container(
        width: 250.0,
        height: 45.0,
        decoration: BoxDecoration(color: Color(0xffFF0066),borderRadius: BorderRadius.circular(5.0),
          //     boxShadow: [BoxShadow(color: Colors.grey,spreadRadius: 0.0,blurRadius:5.0)]
        ),
        child: Center(child:Text("Create account",style: TextStyle(color: Colors.white,fontSize: 22.0,fontWeight: FontWeight.bold),),),
      ),
    );

    // to use available space
    Widget expand                =       Expanded(child: Container()); // to use available space of parent


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

            otpinputfield, //input filed of email

            SizedBox(height:20.0,), // for margin between both input field

            createaccount,           // login and signup field

            SizedBox(height: 10.0,),
          ],
        ),
      ),
    );


  }
  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value)
    ));
  }
}
