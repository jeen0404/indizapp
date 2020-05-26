import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';
import 'uploadInfo.dart';
import 'package:flutter_app/other/storeprefrence.dart';

class SignUp extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<SignUp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String username="exmple";
  String password="exmple";
  var show_pass=false;
  var show_repass=false;
  var show_pass_icon=Icons.remove_red_eye;
  var show_repass_icon=Icons.remove_red_eye;


  Future<void> signup() async{
   await FirebaseAuth.instance.createUserWithEmailAndPassword(email: username, password: password).then((user){
      if(user != null){
        user.sendEmailVerification();
        storeprefrence().storeemailuid(user.email, user.uid);
        showInSnackBar("verification gmail is sent to given mail check your mailbox to verify your indiz account");
        Navigator.pop(context);
       Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (builder)=>uploadinfo()),(Route<dynamic> route)=>false);
      }
      else{
        showInSnackBar("error in signup");
        Navigator.pop(context);
      }

    }).catchError((error){
      showInSnackBar(error.message);
      Navigator.pop(context);
    });

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
    Widget emailtextField =   Row(mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          height: 50.0,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white,width: 1.0))),
          child: TextField(
            onChanged: (value)=>username=value,
            // keyboardType: TextInputType.numberWithOptions(),
            textAlign: TextAlign.left,
            // maxLength: 6,
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email,color: Colors.white,),
                fillColor: Colors.white,
                hintText: "email",
                hintStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),
                border: InputBorder.none
            ),
          ),
        )
      ],
    );

    // email or username input text field
    Widget passwordfield    =   Row(mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          height: 50.0,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white,width: 1.0))),
          child: TextField(
            obscureText: show_pass,
            onChanged: (value)=> password = value,
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline,color: Colors.white,),
                suffixIcon: IconButton(icon:Icon(show_pass_icon,color: Colors.white70,), onPressed:(){
                  setState(() {
                    if(show_pass==true){
                      show_pass=false;
                      show_pass_icon=Icons.vpn_key;
                    }
                    else{
                      show_pass=true;
                      show_pass_icon=Icons.remove_red_eye;
                    }
                  });
                }),
                fillColor: Colors.white,
                hintText: "create password",
                hintStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),
                border: InputBorder.none
            ),
          ),
        )
      ],
    );

    // login button for login
    Widget createaccount  =  GestureDetector(
      onTap: (){
        _onLoading();
        if(password.length < 8){
          showInSnackBar("length must be more than 8 characters");
          Navigator.pop(context);
        }
        else{
          signup();
        }

      },
      child: Container(
        width: 115.0,
        height: 45.0,
        decoration: BoxDecoration(color: Color(0xffFF0066),borderRadius: BorderRadius.circular(5.0),
          //     boxShadow: [BoxShadow(color: Colors.grey,spreadRadius: 0.0,blurRadius:5.0)]
        ),
        child: Center(child:Text("Next",style: TextStyle(color: Colors.white,fontSize: 22.0,fontWeight: FontWeight.bold),),),
      ),
    );

    Widget signin                =          GestureDetector(
       onTap: (){  Navigator.push(context, MaterialPageRoute(builder:(builder)=>LoginPage()));},
      child:  Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Container(
          width: 115.0,
          height: 50.0,
           child:Text("Sign-In",style: TextStyle(color: Color(0xff00E5FF),fontSize: 22.0,fontWeight: FontWeight.bold),),
        ),
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

            emailtextField, //input filed of email

            SizedBox(height:5.0,), // for margin between both input field

            passwordfield,

            SizedBox(height:20.0,), // for margin between both input field

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                signin,
                SizedBox(width: 20.0,),
                createaccount
              ],
            ),           // login and signup field

            SizedBox(height: 10.0,),
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
