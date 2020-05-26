import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'login_page.dart';
import 'checkotp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'signup.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String verificationId;
  String smscode;

  String mobail_no="1";
  String selected_cou_code="+91";
  Color conty_code_list_background_color=Colors.white;
  Color conty_code_list_text_color=Colors.pink;

  List<String> country_code=[
    "+91",
    "+94",
    "+92",
    "+880",
    "+977",
    "+1",
    "+61",
    "+975",
    "+93",
    "+60",
    "+65"
  ];
  
  verificaficationcomplite() async{
    FirebaseUser user =await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(user.uid).updateData({"phone_verified":true});
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(builder)=>HomeFragment()),(Route<dynamic> routs)=>false);
  }
  

  /// Sends the code to the specified phone number.
  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve =(String verId) {
      this.verificationId = verId;
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (builder)=>checkotp(verId)),(Route<dynamic> route)=>false);
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int
    forceCodeResend]){
      _onLoading();
      this.verificationId = verId;
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential credential) {
      print("Verificado");
      verificaficationcomplite();
    };

    final PhoneVerificationFailed verifiedFailed = (AuthException
    exception) {
      showInSnackBar(exception.message);
      print("${exception.message}");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.mobail_no,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: verifiedFailed,
        codeSent: smsCodeSent,
        codeAutoRetrievalTimeout: autoRetrieve);
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
    Widget phoneno = Row(mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height:50.0,
          width:50.0,
          //decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.grey,spreadRadius: 0.0,blurRadius: 2.0)]),
          child:MediaQuery.removePadding(
            removeTop: true,
            child: ListView.builder(itemBuilder:(context,position){
            return GestureDetector(
              onTap: (){
                setState(() {
                  selected_cou_code=country_code[position];
                });
              },
              child: Container(width: 50.0,height: 45.0,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0),border: Border.all(color: Colors.white,width: 1.0)),
              child: Center(child: Text(country_code[position],style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),),
              ),
            );
            },itemCount: country_code.length,), context:context,
          )

        ),

                                              SizedBox(width: 20.0,),
                                              Container(
                                              width: 180.0,
                                              height: 50.0,
                                              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white,width: 1.0))),
                                              child: TextField(
                                                keyboardType:TextInputType.numberWithOptions(),
                                                onChanged: (value){
                                                  mobail_no=selected_cou_code+value;
                                                //  print(mobail_no);
                                                  }
                                                ,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                                                decoration: InputDecoration(
                                                  prefixText: selected_cou_code,
                                                    prefixStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18.0),
                                                    fillColor: Colors.white,
                                                    hintText: "Phone No:",
                                                    hintStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.normal),
                                                    border: InputBorder.none
                                                ),
                                              ),
                                            )
                                          ],
                                        );

    // sign_up button to go sign_up page
    Widget signin                =          GestureDetector(
                                                    //  onTap: (){  Navigator.push(context, MaterialPageRoute(builder:(builder)=>LoginPage()));},
                                                      child:  Padding(
                                                        padding: const EdgeInsets.only(top: 20.0),
                                                        child: Container(
                                                          width: 125.0,
                                                          height: 50.0,
                                                       //   child:Text("Sign-In",style: TextStyle(color: Color(0xff00E5FF),fontSize: 22.0,fontWeight: FontWeight.bold),),
                                                        ),
                                                      ),
                                                    );

    // login button for login
    Widget sendotp                 =      Builder(builder: (context)=>GestureDetector(
      onTap: (){
        if(mobail_no.length < 10){
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("check moabil number length",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),duration: Duration(seconds: 1),backgroundColor: Colors.white,));
        }
        else {
          verifyPhone();
        }
      },
      child:   Container(
        width: 125.0,
        height: 45.0,
        decoration: BoxDecoration(color: Color(0xffFF0066),borderRadius: BorderRadius.circular(5.0),
          //     boxShadow: [BoxShadow(color: Colors.grey,spreadRadius: 0.0,blurRadius:5.0)]
        ),
        child: Center(child:Text("Next",style: TextStyle(color: Colors.white,fontSize: 22.0,fontWeight: FontWeight.bold),),),
      ),
    ));

    // to use available space
    Widget expand                =          Expanded(child: Container()); // to use available space of parent

    // putting both login and signup button into single row
    Widget loginsignup           =          Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        signin, // sign up button for go to signup activity
        sendotp,  // login button for login
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

            phoneno, //input filed of email

            SizedBox(height: 10.0,), // for margin between both input field

            loginsignup,            // login and signup field

            SizedBox(height: 10.0,),
          ],
        ),
      ),
    );
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value,style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),duration: Duration(seconds: 1),backgroundColor: Colors.white,));
  }


}
