import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/home.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';


class uploadinfo extends StatefulWidget {
  @override
  _uploadinfoState createState() => _uploadinfoState();
}

class _uploadinfoState extends State<uploadinfo> {
  Future<String> getinterstlist() async{
    FirebaseDatabase.instance.reference().child("interst").once().then((result){
      for(var i in result.value.values){
        _interstdatalist.add(i);
      }
    });
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  String male_icon="https://i.pinimg.com/originals/ad/86/00/ad86000ae7f18e5ee5589c66a99edf00.jpg";
  String female_icon="https://nssauci.com/image/87178-full_tumblr-tumblr-drawings-tumblr-girl-drawing-tumblr-outline.jpg";
  String img_url="https://cdn4.iconfinder.com/data/icons/silky-icon-user/60/user2-add-512.png";
  var usernameicon = Icons.announcement;
  String username="0";
  String name="0";
  var birth_date="Birth Date";
  String bio="0";
  bool usernameavailable = false;
  var malebackgroundcolor = Colors.transparent;
  var Femalebackgroundcolor = Colors.transparent;
  var gender;
  var index = 0;
  var tokan;
  var time=DateTime.now();
  var platform;
  File _image;
  List<String> _interst = [];
  List<String> _interstdatalist = [];
  ScrollController _controller = ScrollController();
  FirebaseStorage _storage = FirebaseStorage.instance;
  var pagerview_contrller = PageController();



  SharedPreferences sharpref;
  Future<void> getdevicedata() async{
     sharpref=await SharedPreferences.getInstance();
    time= await DateTime.now();
    tokan =await FirebaseMessaging().getToken();
    platform= Platform.isAndroid==true? "android":  "ios";
  }


  Future<String> uploadimage(var img) async{
    var user= await FirebaseAuth.instance.currentUser();
    var ref=_storage.ref().child("profileimage").child(user.uid).child("profile.jpg");
    final StorageUploadTask uploadTask = ref.putFile(img);
    final StorageTaskSnapshot downloadUrl =
    (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    setState(() {
        img_url=url;
      _image=null;
    });
    return url;
  }


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinterstlist();
    getdevicedata();
    //img_url=male_icon;
  }


  @override
  Widget build(BuildContext context) {
     getImage() async {
      return showDialog(context: context,builder: (BuildContext contaxt){
        return   AlertDialog(
          content: Container(
            height: 80.0,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    IconButton(icon: Icon(Icons.sd_storage), onPressed: () async {
                      var image = await ImagePicker.pickImage(source: ImageSource.gallery,maxHeight:400.0,maxWidth:400.0 );
                      setState(() {
                        _image = image;
                      });
                      Navigator.pop(context);
                      uploadimage(image);
                    }),
                    Text("Gallery")
                  ],
                ),
                Column(
                  children: <Widget>[
                    IconButton(icon: Icon(Icons.camera), onPressed: () async {
                      var image = await ImagePicker.pickImage(source: ImageSource.camera,maxHeight:400.0,maxWidth:400.0);
                      setState(() {
                        _image = image;
                      });
                      Navigator.pop(context);
                      uploadimage(image);
                    }),
                    Text("camera")
                  ],
                ),

            ],),
          ),
        );
      });
    }
    Widget first = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 50.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                getImage();
              },
              child: GestureDetector(
                onTap: (){

                },
                child:
                GestureDetector(
                  onTap: (){
                    getImage();
                  },
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height:100.0,
                        width: 100.0,
                        decoration: BoxDecoration(color: Colors.white70,shape: BoxShape.circle,
                            border: Border.all(color: Colors.purple)
                            ,image: DecorationImage(image: NetworkImage(img_url),fit: BoxFit.cover)
                        ),
                      ),
                      Positioned(bottom: 3.0,right: 3.0,child: Container(decoration: BoxDecoration(shape:BoxShape.circle,border:Border.all(color: Colors.white,width: 2.0,),color: Colors.white),child: Icon(Icons.add_circle,color: Colors.pink,size:20.0,))),
                    ],
                  ),
                )
              ),
            )
          ],
        ),

        SizedBox(height: 20.0),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 250.0,
              height: 40.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.purple, width: 1.0)
              ),
              child: TextField(
                onChanged: (value) {

                  username=value.toLowerCase();

                  if (value.length > 5) {
                    setState(() {
                      usernameicon = Icons.watch_later;
                    });
                    FirebaseDatabase.instance.reference().child("users")
                        .orderByChild("username").equalTo(value.toLowerCase()).once()
                        .then((result) {
                      if (result.value == null) {
                        setState(() {
                          usernameicon = Icons.check;
                        });
                        usernameavailable = true;
                      }
                      else {
                        setState(() {
                          usernameicon = Icons.not_interested;
                        });

                        usernameavailable = false;
                      }
                    }).catchError((e) {
                      showInSnackBar(e.message);
                    });
                  }
                  else{
                    setState(() {
                      usernameicon = Icons.not_interested;
                    });

                    usernameavailable = false;
                  }
                },

                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        icon: Icon(usernameicon, color: Colors.pink,),
                        onPressed: null),
                    hintStyle: TextStyle(color: Colors.black26,fontWeight: FontWeight.normal),
                    border: InputBorder.none,
                    hintText: "Choose username",

                ),
                inputFormatters: [
                  new BlacklistingTextInputFormatter(new RegExp('[\\.|\\,|\\ |\\~|\\`|\\@|\\#|\\%|\\]|\\^|\\&|\\*|\\(|\\|\\-|\\+|\\=|\\/|\\||\\\|\\{|\\}|\\:|\\)]',)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 250.0,
              height: 40.0,
              decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.purple, width: 1.0)
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextField(
                  onChanged:(value)=>name=value ,
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.black26,fontWeight: FontWeight.normal),
                      border: InputBorder.none,
                      hintText: "Nickname"
                  ),
                ),
              ),
            )
          ],
        ),
       SizedBox(height:10.0,),
       /* Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    pagerview_contrller.jumpToPage(1);
                    index = 1;
                  });
                },
                child: Container(height: 50.0, width:250.0,
                  decoration: BoxDecoration(color: Colors.purple,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Center(
                    child: Text("Next", style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                ),
              ),
            ),
          ],
        ),*/
      ],
    );
    Widget second = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 10.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            /*SizedBox(height: 300.0,),*/

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if(img_url=="https://cdn4.iconfinder.com/data/icons/silky-icon-user/60/user2-add-512.png" || img_url==female_icon){
                      img_url=male_icon;
                    }
                    gender = "male";
                    setState(() {
                      malebackgroundcolor = Colors.purple;
                      Femalebackgroundcolor = Colors.transparent;

                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(height:80.0,
                        width:80.0,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                            border: Border.all(
                                color: malebackgroundcolor, width: 2.0)),
                        //child: Center(child: Text("Male",style: TextStyle(color: Colors.pink),),),
                        child: CircleAvatar(backgroundImage: NetworkImage(male_icon),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Male",style: TextStyle(color: Colors.purple),),
                      ),
                    ],
                  )
                ),


                SizedBox(width:50.0,),

                GestureDetector(
                  onTap: () {
                    if(img_url=="https://cdn4.iconfinder.com/data/icons/silky-icon-user/60/user2-add-512.png" || img_url==male_icon){
                      img_url=female_icon;
                    }
                    gender = "female";
                    setState(() {
                      malebackgroundcolor = Colors.transparent;
                      Femalebackgroundcolor = Colors.purple;

                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(height: 80.0,
                        width: 80.0,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                            border: Border.all(
                                color: Femalebackgroundcolor, width: 2.0)),
                        //  child: Center(child: Text("Female",style: TextStyle(color: Colors.pink),),),
                        child: CircleAvatar(backgroundImage: NetworkImage(female_icon),),

                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Female",style: TextStyle(color: Colors.purple),),
                      ),
                    ],
                  )
                ),
              ],
            ),

          ],
        ),

     /*   Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  pagerview_contrller.jumpToPage(2);
                  index = 2;
                });
              },
              child: Container(height: 50.0, width:250.0,
                decoration: BoxDecoration(color: Colors.purple,
                    borderRadius: BorderRadius.circular(10.0)),
                child: Center(
                  child: Text("Next", style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),),
                ),
              ),
            ),
          ],
        )*/

      ],
    );
    Widget third = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
     //   SizedBox(height: 100.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 250.0,
              height: 140.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.purple, width: 1.0)
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0,bottom: 5.0),
                child: TextField(
                  onChanged: (value){
                    bio=value;
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  maxLengthEnforced: true,
                  maxLength: 150,
                  style: TextStyle(
                      color: Colors.black87, fontWeight:FontWeight.bold),
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.black26,fontWeight: FontWeight.normal),
                      border: InputBorder.none,
                      hintText: "Describe yourself.."
                  ),
                ),
              ),
            )
          ],
        ),


        SizedBox(height: 10.0,),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                return   DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    minTime: DateTime(1945,1, 1),
                    maxTime: DateTime(2010,12, 30), onChanged: (date) {

                      setState(() {
                        birth_date= date.toString();
                      });
                      },
                    onConfirm: (date) {

                    }, currentTime: DateTime.now(), locale: LocaleType.en);
              },
              child: Container(
                width: 250.0,
                height: 40.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Colors.purple, width: 1.0)
                ),
                child:Row(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      birth_date.toString(), style: TextStyle(color: Colors.black26),),
                  ),
                 Expanded(child: Container()),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.calendar_today,color: Colors.pink,),
                  )
                ],),
              ),
            )
          ],
        ),



      ],
    );


    Widget Fourth = ListView.builder(itemBuilder: (_, position) {
      if (position == 0) {
        return Container(
          height: 60.0,
          color: Colors.white,
          child: _interst.length==0?
          Container(height: 50.0,
            child: Center(child: Text("Select five Interst", style: TextStyle(
                color: Colors.blueAccent, fontWeight: FontWeight.bold,fontSize:22.0),),),
          ) :
          ListView.builder(controller: _controller, itemBuilder: (_, position) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _interst.removeAt(position);
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.remove_circle_outline, color: Colors.blueAccent,),
                      Container(
                        decoration: BoxDecoration(
                          // color: Colors.deepOrange,
                          gradient: LinearGradient(colors: [Color(0xffFF0066),Color(0xffFF8800)],begin:Alignment.centerLeft,end: Alignment.centerRight),

                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal:10),
                          child: Text(_interst[position],
                            style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold),),
                        ),),
                      ),

                    ],

                  )
              ),
            );
          }, itemCount: _interst.length, scrollDirection: Axis.horizontal,),
        );
      }
      else if (position == _interstdatalist.length) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {

                },
                child: Container(height: 50.0, width: 150.0,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Center(
                    child: Text("Next", style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                ),
              ),
            )
          ],
        );
      }
      else {
        return Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  _interst.add(_interstdatalist[position]);
                  _interst = _interst.toSet().toList();
                });
                _controller.jumpTo(_controller.position.maxScrollExtent);
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                    height: 50.0,
                    decoration: BoxDecoration(
                      //   color: Colors.blue,
                      borderRadius: BorderRadius.circular(5.0),
                      //   border: Border.all(color: Colors.blue,width: 1.0)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.add),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(_interstdatalist[position],
                            style: TextStyle(color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0),),
                        ),
                      ],
                    )
                ),
              ),
            ),

            Container(height: 1.0, color: Colors.grey,),
          ],
        );
      }
    }, itemCount: _interstdatalist.length + 1,);



    List<Widget> _changelist = [
      first,
      second,
      third,
      Fourth,
    ];
    return Scaffold(
        key: _scaffoldKey,
        body: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                children: <Widget>[
                  first,
                  third,
                  second,
                ],controller: pagerview_contrller,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    /* setState(() {
                  pagerview_contrller.jumpToPage(3);
                  index = 3;
                });*/
                    _onLoading();
                    if(username.length > 4 && username.length < 16){
                      if(usernameavailable){
                        if(name.length > 3 && name.length < 16 ){
                          if(bio.length > 1){
                            if(gender != null){

                              ///////////////////////////////add birth date
                              uploaddata();
                              /*if(_interst.length > 4){

                          }else{
                            showInSnackBar("select atlist five interst");
                            Navigator.pop(context);
                          }*/
                            }
                            else{
                              showInSnackBar("select gender");
                              Navigator.pop(context);
                            }

                          }else{
                            showInSnackBar("Bio can't be empty");
                            Navigator.pop(context);
                          }
                        }
                        else{
                          showInSnackBar("name length must be more than 4 charcter and less than 16 character");
                          Navigator.pop(context);
                        }

                      }else{
                        showInSnackBar("username is already taken");
                        Navigator.pop(context);
                      }
                    }
                    else{
                      showInSnackBar("username length must be more than 5 character and less than 16 character");
                      Navigator.pop(context);
                    }

                  },
                  child: Container(height: 50.0,width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.purple,
                    //    borderRadius: BorderRadius.circular(10.0)
                    ),
                    child: Center(
                      child: Text("Create account", style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
        backgroundColor: Colors.white,


    );
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Container(
        height: 40.0,
        width: 250.0,
        child: Center(child: Text(value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),))),
      duration: Duration(milliseconds: 1000),
      backgroundColor: Colors.purple,));
  }

  void _onLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        child: Container(
          width: 200.0,
          height: 200.0,
          //decoration: BoxDecoration(color: Colors.white70,borderRadius: BorderRadius.circular(10.0),),
          child: Center(child: FlareActor(
              "flar/progress.flr", alignment: Alignment.center,
              animation: "Untitled"),),
        )
    );
  }

  uploaddata() async {
    await FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      Map<String,dynamic> data = Map();
      data["email"] = user.email;
      data["uid"] = user.uid;
      data["img_url"] = img_url;
      data["username"] = username.toLowerCase();
      data["name"] = name;
      data["bio"] = bio;
      data["gender"] = gender;
      data["birth_date"] = birth_date;
      data["account_created"] =time.toString();
      data["platform"] = platform;
      data["fcm_tocken"] = tokan;

      data["account_verified"] = false;
      data["gmail_verified"] = true;
      data["phone_verified"] = false;
      data["disable"] =false;
      data["private"] = false;

      //total count of list
      data["t_follower"] = 0;
      data["t_following"] = 0;
      data["t_likes"] = 0;
      data["t_crush_on_you"] = 0;
      data["t_close_friend"] = 0;
      data["t_posts"] = 0;
      data["t_tags"] = 0;
      data["t_following"] = 0;
      data["t_crush"] = 0;
      data["t_profile_visits"] = 0;
      data["t_secret_crush"] = 0;
      data["t_saved_posts"] = 0;
      data["t_unseen_nf"] = 0;


      //notification setting
      data["nf_message"] = true;
      data["nf_like"] = true;
      data["nf_comment"] = true;
      data["nf_post"] = true;
      data["nf_crush"] = true;
      data["nf_follow"] = true;
      data["nf_secretcrush"] = true;
      data["nf_official"] = true;
      print(data);

      FirebaseDatabase.instance.reference().child("users").child(user.uid).set({
        "uid":user.uid,
        "username":username,
        "name":name,
        "email":user.email,
      }).then((reslt) {
        Firestore.instance.collection("users").document(user.uid).setData(data).then((val){
          sharpref.setInt("login_status", 2);
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (builder)=>HomeFragment()),(Route<dynamic> route)=>false);
        });
      });
    });
  }




}
