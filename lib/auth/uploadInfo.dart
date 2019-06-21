import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';


import '../home.dart';
import 'dart:io';


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

  String img_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpu1ABiiruJQ51kiP3Z01DwtNHJ25CQ6Q5Rf5rFBWfMBbflVqj";
  var usernameicon = Icons.announcement;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String username="0";
  String name="0";
  var birth_date;
  String bio="0";
  bool usernameavailable = false;
  var malebackgroundcolor = Colors.transparent;
  var Femalebackgroundcolor = Colors.transparent;
  var gender;
  var index = 0;
  var tokan;
  var time=DateTime.now();

  var platform;

  Future<void> getdevicedata() async{
    time= await DateTime.now();
    tokan =await FirebaseMessaging().getToken();
    platform= Platform.isAndroid==true? "android":  "ios";
  }



  FirebaseStorage _storage = FirebaseStorage.instance;

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



  File _image;
  List<String> _interst = [];
  List<String> _interstdatalist = [];
  ScrollController _controller = ScrollController();

@override
  void initState() {
    getinterstlist();
    getdevicedata();
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
                      var image = await ImagePicker.pickImage(source: ImageSource.gallery,maxHeight:100.0,maxWidth:100.0 );
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
                      var image = await ImagePicker.pickImage(source: ImageSource.camera,maxHeight:100.0,maxWidth:100.0);
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
        SizedBox(height: 100.0,),
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
                child: _image == null ?
               GestureDetector(
                 onTap: (){
                   getImage();
                 },
                 child:  Container(
                   height: 80.0,
                   width: 80.0,
                   decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(50.0),
                       color: Colors.pink,
                       image: DecorationImage(image: NetworkImage(img_url),fit: BoxFit.cover)
                   ),
                 ),
               ) :
                GestureDetector(
                  onTap: (){
                    getImage();
                  },
                  child: Container(
                    height: 80.0,
                    width: 80.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x33A6A6A6)),
                      // image: new Image.asset(_image.)
                    ),
                    child: new Image.file(_image ),
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
                  border: Border.all(color: Colors.blueAccent, width: 1.0)
              ),
              child: TextField(
                onChanged: (value) {
                  username=value;
                  if (value.length > 5) {
                    setState(() {
                      usernameicon = Icons.watch_later;
                    });
                    FirebaseDatabase.instance.reference().child("users")
                        .orderByChild("username").equalTo(value).once()
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
                },

                style: TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        icon: Icon(usernameicon, color: Colors.pink,),
                        onPressed: null),
                    hintStyle: TextStyle(color: Colors.blueAccent),
                    border: InputBorder.none,
                    hintText: "choose Username"
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 250.0,
              height: 40.0,
              decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.blueAccent, width: 1.0)
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextField(
                  onChanged:(value)=>name=value ,
                  style: TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.blueAccent),
                      border: InputBorder.none,
                      hintText: "name"
                  ),
                ),
              ),
            )
          ],
        ),
        Expanded(child: Container()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    index = 1;
                  });
                },
                child: Container(height: 50.0, width: 150.0,
                  decoration: BoxDecoration(color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Center(
                    child: Text("Next", style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
    Widget second = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 20.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            SizedBox(height: 300.0,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    gender = "male";
                    setState(() {
                      malebackgroundcolor = Colors.deepOrange;
                      Femalebackgroundcolor = Colors.transparent;

                    });
                  },
                  child: Container(height: 120.0,
                    width: 120.0,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(
                            color: malebackgroundcolor, width: 2.0)),
                    //child: Center(child: Text("Male",style: TextStyle(color: Colors.pink),),),
                    child: CircleAvatar(backgroundImage: NetworkImage(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDoVxLapMz1rLsy_JGJYE24hUq3pgi4v6_uYlQaDElDbE8nwys"),),
                  ),
                ),
                SizedBox(width: 20.0,),

                GestureDetector(
                  onTap: () {
                    gender = "female";
                    setState(() {
                      malebackgroundcolor = Colors.transparent;
                      Femalebackgroundcolor = Colors.deepOrange;

                    });
                  },
                  child: Container(height: 120.0,
                    width: 120.0,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(
                            color: Femalebackgroundcolor, width: 2.0)),
                    //  child: Center(child: Text("Female",style: TextStyle(color: Colors.pink),),),
                    child: CircleAvatar(backgroundImage: NetworkImage(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS0goQ0GNqzQ6QkLwQnmc9HVc-VdjAnP3Wd1I2ft-A2SErpOehf"),),

                  ),
                ),
              ],
            ),

          ],
        ),

        Expanded(child: Container()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    index = 2;
                  });
                },
                child: Container(height: 50.0, width: 150.0,
                  decoration: BoxDecoration(color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Center(
                    child: Text("Next", style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                ),
              ),
            ),
          ],
        )

      ],
    );
    Widget third = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 100.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 250.0,
              height: 100.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.blueAccent, width: 1.0)
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextField(
                  onChanged: (value){
                    bio=value;
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  style: TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.blueAccent),
                      border: InputBorder.none,
                      hintText: "Bio"
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
                    minTime: DateTime(2000,1, 1),
                    maxTime: DateTime(2010,12, 30), onChanged: (date) {

                      setState(() {
                        birth_date= date;
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
                    border: Border.all(color: Colors.blueAccent, width: 1.0)
                ),
                child: Center(child: Text(
                  birth_date.toString(), style: TextStyle(color: Colors.blueAccent),),),
              ),
            )
          ],
        ),

        Expanded(child: Container()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    index = 3;
                  });
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
        )
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
                  _onLoading();
                  if(username.length > 4){
                    if(usernameavailable){
                      if(name.length > 3 ){
                        if(bio.length > 1){
                          if(gender != null){
                            if(_interst.length > 4){
                                uploaddata();
                            }else{
                              showInSnackBar("select atlist five interst");
                              Navigator.pop(context);
                            }
                          }
                          else{
                            showInSnackBar("select gender");
                            Navigator.pop(context);
                          }

                        }else{
                          showInSnackBar("bio can't be empty");
                          Navigator.pop(context);
                        }
                      }
                      else{
                        showInSnackBar("name length must be more that 4 charcter");
                        Navigator.pop(context);
                      }

                    }else{
                      showInSnackBar("username is already taken");
                      Navigator.pop(context);
                    }
                  }
                  else{
                    showInSnackBar("username length must be more that 5 charcter");
                    Navigator.pop(context);
                  }

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

    SizedBox(height: 20.0,);

    List<Widget> _changelist = [
      first,
      second,
      third,
      Fourth,
    ];
    return Scaffold(
        key: _scaffoldKey,
        body: _changelist[index],
        backgroundColor: Colors.white,

        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white,
          color: Colors.blueAccent,
          index: index,
          height: 55.0,
          items: <Widget>[
            Icon(Icons.perm_identity, size: 20, color: Colors.white,),
            Icon(Icons.gamepad, size: 20, color: Colors.white,),
            Icon(Icons.info_outline, size: 20, color: Colors.white,),
            Icon(Icons.date_range, size: 20, color: Colors.white,),
          ],
          onTap: (i) {
            setState(() {
              index = i;
            });
            //Handle button tap
          },
        )
    );
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Container(
        height: 40.0,
        width: 250.0,
        child: Center(child: Text(value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),))),
      duration: Duration(milliseconds: 1000),
      backgroundColor: Colors.blue,));
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
    await FirebaseAuth.instance.currentUser().then((user) {
      FirebaseDatabase.instance.reference().child("users").child(user.uid).set({
        "email": user.email,
        "uid": user.uid,
        "mob": "",
        "username":username,
      }).then((reslt) {
        Map<String,dynamic> data = Map();
        data["uid"] = user.uid;
        data["img_url"] = img_url;
        data["username"] = username;
        data["name"] = name;
        data["bio"] = bio;
        data["birth_date"] = birth_date;
        data["interst"] = _interst;
        data["is_verifyed"] = false;
        data["t_follower"] = 0;
        data["t_following"] = 0;
        data["t_likes"] = 0;
        data["t_close_friend"] = 0;
        data["t_posts"] = 0;
        data["t_tags"] = 0;
        data["t_following"] = 0;
        data["t_crush"] = 0;
        data["t_profile_visits"] = 0;
        data["t_secret_crush"] = 0;
        data["t_saved_posts"] = 0;
        data["private"] = false;
        data["fcm_tocken"] = {"time_created": time, "tocken": tokan};
        data["notification_setting"] = {
          "nf_post": 1,
          "nf_meggages": 1,
          "nf_story": 1,
          "nf_likes": 1,
          "nf_comments": 1,
          "nf_tag": 1,
          "nf_comm_like": "1"
        };
        data["account_created"] =time;
        data["platform"] = platform;
        data["location"] = "";
        print(data);
        Firestore.instance.collection("users").document(user.uid)
            .setData(data)
            .then((result) {

          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (builder)=>home()),(Route<dynamic> route)=>false);

        }).catchError((e) {
          showInSnackBar(e.message);
          Navigator.pop(context);
        });
      }).catchError((e) {
        showInSnackBar(e.message);
        Navigator.pop(context);
      });
    }).catchError((e) {
      Navigator.pop(context);
      showInSnackBar(e.message);
    });
  }
}
