import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/profilepage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:core';

class EditInfo extends StatefulWidget {
  var name;
  var username;
  var bio;
  var img_url;
  EditInfo(name,username,bio,img_url){
    this.name=name;
    this.username=username;
    this.bio=bio;
    this.img_url=img_url;
  }

  @override
  _EditInfoState createState() => _EditInfoState(this.name,this.username,this.bio,img_url);
}

class _EditInfoState extends State<EditInfo> {

  var name;
  var username;
  var bio;
  var img_url;
  var usernameicon = Icons.announcement;
  bool usernameavailable = false;
  TextEditingController usernamecomtroller=TextEditingController();
  TextEditingController nicknamecontroller=TextEditingController();
  TextEditingController biocontriller=TextEditingController();



  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _EditInfoState(name,username,bio,img_url){
    this.name=name;
    this.username=username;
    this.bio=bio;
    this.img_url=img_url;
  }

  Widget serarchwidget=Container();
  Widget linewidget=Container();

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    usernamecomtroller.text=username;
    nicknamecontroller.text=name;
    biocontriller.text=bio;
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar:  AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        //centerTitle: true,
        elevation: 0.0,
        title: Text("Edit Profile",style: TextStyle(color: Colors.black),),
        leading: new IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        }),
        actionsIconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              onTap: (){
                _onLoading();
                if(usernamecomtroller.text.length>4){
                  if(usernamecomtroller.text.length<15){
                    if(nicknamecontroller.text.length>5){
                      if(nicknamecontroller.text.length<15){
                        if(biocontriller.text.length>1){
                         updatedata();

                        }else{
                          showInSnackBar("bio can't be empty");
                          Navigator.pop(context);
                        }
                      }else{
                        showInSnackBar("Nickname lenth must be less than 15 character");
                        Navigator.pop(context);
                      }
                    }else{
                      showInSnackBar("Nickname lenth must be more than 5 character");
                      Navigator.pop(context);
                    }

                  }else{
                    showInSnackBar("username lenth must be less than 15 character");
                    Navigator.pop(context);
                  }

                }else{
                  showInSnackBar("username lenth must be more than 4 character");
                  Navigator.pop(context);
                }
              },
                child: Text("Save",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20.0),)),
          )
        ],
      ),
      body:ListView(children: <Widget>[
        Column(children: <Widget>[
          Divider(height: 1.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top:20.0),
                child: GestureDetector(
                  onTap: (){
                    getimages();
                  },
                  child: Container(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height:100.0,
                          width: 100.0,
                          decoration: BoxDecoration(color: Colors.white70,shape: BoxShape.circle
                              ,image: DecorationImage(image: NetworkImage(img_url),fit: BoxFit.cover)
                          ),
                        ),
                        Positioned(bottom: 3.0,right: 3.0,child: Container(decoration: BoxDecoration(shape:BoxShape.circle,border:Border.all(color: Colors.white,width: 2.0,),color: Colors.white),child: Icon(Icons.add_circle,color: Colors.pink,size:20.0,))),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),

          SizedBox(height:15.0,),
          Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 15.0),
              child: Text("Indiz id",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.normal),),
            )
          ],),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 250.0,
                height: 40.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Colors.black12, width: 1.0)
                ),
                child: TextField(
                  inputFormatters: [
                    new BlacklistingTextInputFormatter(new RegExp('[\\.|\\,|\\ |\\~|\\`|\\@|\\#|\\%|\\]|\\^|\\&|\\*|\\(|\\|\\-|\\+|\\=|\\/|\\||\\\|\\{|\\}|\\:|\\)]',)),
                  ],
                  controller: usernamecomtroller,
                  onChanged: (value) {
                    username=value.toLowerCase();
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
                ),
              ),
            ],
          ),

          Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 15.0),
              child: Text("Nickname",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.normal),),
            )
          ],),


          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 250.0,
                height: 40.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Colors.black12, width: 1.0)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: TextField(
                    controller: nicknamecontroller,
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


          Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 15.0),
              child: Text("Bio",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.normal),),
            )
          ],),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 250.0,
                height: 140.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Colors.black12, width: 1.0)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0,bottom: 5.0),
                  child: TextField(
                    onChanged: (value){
                      bio=value;
                   //   TagHasTag(value);
                    },
                    controller: biocontriller,
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


        ],),

        serarchwidget,
        linewidget,

      ],)
    );
  }


  File _image;
  getimages() async {
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
                    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
                    if(image!=null){
                      Navigator.pop(context);
                      image=await _cropImage(image);
                      if(image!=null){
                        uploadimage(image);
                      }
                    }
                    // Navigator.pop(context);
                  }),
                  Text("Gallery")
                ],
              ),
              Column(
                children: <Widget>[
                  IconButton(icon: Icon(Icons.camera), onPressed: () async {
                    var image = await ImagePicker.pickImage(source: ImageSource.camera);
                    if(image!=null) {
                      image=await _cropImage(image);
                      if(image!=null){
                        uploadimage(image);
                      }
                    }
                    Navigator.pop(context);
                  }),
                  Text("camera")
                ],
              ),
            ],),
        ),
      );
    });
  }


  updatedata() async{
    FirebaseUser user =await FirebaseAuth.instance.currentUser();
   await Firestore.instance.collection("users").document(user.uid).updateData({
      "img_url":img_url,
      "name":nicknamecontroller.text,
      "username":usernamecomtroller.text.toLowerCase(),
      "bio":biocontriller.text,
    }).then((val){
      FirebaseDatabase.instance.reference().child("users").child(user.uid)
          .update({
        "name":nicknamecontroller.text,
        "username":usernamecomtroller.text,
      }).then((result){
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (builder)=>Profile_activity()),(Route<dynamic> route)=>false);

      }).catchError((e){
        Navigator.pop(context);
        showInSnackBar(e.message);
      });
   }).catchError((e){
     Navigator.pop(context);
     showInSnackBar(e.message);
   });


  }


  Future<File> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath:imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1,ratioY:1),
      maxWidth:400,
      maxHeight:400,
    );
    return croppedFile;
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
    Firestore.instance.collection("users").document(user.uid).updateData({
      "img_url":img_url});
    return url;
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


  uploadinfo(){

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


  TagHasTag(text){
    var wordlist;
    print(text);
    if(text!=""){
      wordlist=text.split(' ');
      if(wordlist!=""){
        var word=wordlist[wordlist.length-1];
        if(word.length>1){
          if(word.substring(0,1)=="@"){
            print(word.substring(1,word.length));
            FirebaseDatabase.instance.reference().child("users").orderByChild("username").startAt(word.substring(1,word.length))
                .endAt(word.substring(1,word.length)+"\uf8ff").limitToFirst(50).once().then((DataSnapshot val){
              print(val.value);
              var list=[];
              if(val.value!=null){
                for (var i in val.value.values){
                  list.add(i);
                }
                setState(() {
                  linewidget=Divider(height: 1.0,);
                  serarchwidget=Container(height: 80.0,
                      child: Column(children: <Widget>[
                        Row(mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[

                            Container(height: 30.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Searching For"+":  '"+word+"'"),
                              ),),
                          ],
                        ),
                        Container(
                            color: Colors.white,
                            height:45.0,
                            child:
                            ListView.builder(itemBuilder:(_,index){
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: (){
                                    var text=biocontriller.text;
                                    var text2=text.replaceAll(word,"@"+list[index]["username"]+" ");
                                    print(text);
                                    biocontriller.text=text2;
                                    setState(() {
                                      var cursorPos = biocontriller.selection;
                                      cursorPos = new TextSelection.fromPosition(
                                          new TextPosition(offset: biocontriller.text.length));
                                      biocontriller.selection = cursorPos;
                                      serarchwidget=Container();
                                      linewidget=Container();
                                    });
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 1.0),
                                          borderRadius: BorderRadius.circular(2.0)
                                      )
                                      ,child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 20.0),
                                    child: Text("@"+list[index]["username"],style: TextStyle(color: Colors.pink,fontWeight: FontWeight.bold),),
                                  )),
                                ),
                              );
                            },itemCount:list.length,scrollDirection: Axis.horizontal,)
                        ),
                      ],)
                  );
                });
              }
              else{
                setState(() {
                  serarchwidget=Container();
                  linewidget=Container();
                });
              }
            });
          }




          else if(word.substring(0,1)=="#"){
            var list=[];

            FirebaseDatabase.instance.reference().child("hashtag").child("username").startAt(word.substring(1,word.length))
                .endAt(word.substring(1,word.length)+"\uf8ff").limitToFirst(50).once().then((DataSnapshot val){
              print(val.value);

              if(val.value!=null){
                for (var i in val.value.values){
                  list.add(i);
                }
                setState(() {
                  linewidget=Divider(height: 1.0,);
                  serarchwidget=Container(height: 90.0,
                      child: Column(children: <Widget>[
                        Row(mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(height: 30.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Searching For"+":  '"+word+"'"),
                              ),),
                          ],
                        ),
                        Container(
                            color: Colors.white,
                            height:45.0,
                            child:
                            ListView.builder(itemBuilder:(_,index){
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: (){
                                    var text=biocontriller.text;
                                    var text2=text.replaceAll(word,"#"+list[index]["username"]+" ");
                                    print(text);
                                    biocontriller.text=text2;
                                    setState(() {
                                      var cursorPos = biocontriller.selection;
                                      cursorPos = new TextSelection.fromPosition(
                                          new TextPosition(offset: biocontriller.text.length));
                                      biocontriller.selection = cursorPos;
                                      serarchwidget=Container();
                                      linewidget=Container();
                                    });
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 1.0),
                                          borderRadius: BorderRadius.circular(2.0)
                                      )
                                      ,child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 20.0),
                                    child: Text("@"+list[index]["username"],style: TextStyle(color: Colors.pink,fontWeight: FontWeight.bold),),
                                  )),
                                ),
                              );
                            },itemCount:list.length,scrollDirection: Axis.horizontal,)
                        ),
                      ],)
                  );
                });
              }
              else{
                list.add({"username":word.substring(1,word.length)});
                setState(() {
                  linewidget=Divider(height: 1.0,);

                    serarchwidget=Container(height: 90.0,
                      child: Column(children: <Widget>[
                        Row(mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[

                            Container(height: 30.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Searching For"+":  '"+word+"'"),
                              ),),
                          ],
                        ),
                        Container(
                            color: Colors.white,
                            height:45.0,
                            child:
                            ListView.builder(itemBuilder:(_,index){
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: (){
                                    var text=biocontriller.text;
                                    var text2=text.replaceAll(word,"#"+list[index]["username"]+" ");
                                    print(text);
                                    biocontriller.text=text2;
                                    setState(() {
                                      var cursorPos = biocontriller.selection;
                                      cursorPos = new TextSelection.fromPosition(
                                          new TextPosition(offset: biocontriller.text.length));
                                      biocontriller.selection = cursorPos;
                                      serarchwidget=Container();
                                      linewidget=Container();
                                    });
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 1.0),
                                          borderRadius: BorderRadius.circular(2.0)
                                      )
                                      ,child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 20.0),
                                    child: Text("#"+list[index]["username"],style: TextStyle(color: Colors.pink,fontWeight: FontWeight.bold),),
                                  )),
                                ),
                              );
                            },itemCount:list.length,scrollDirection: Axis.horizontal,)
                        ),
                      ],)
                  );
                });
              }
            });
          }
        }else{
          setState(() {
            serarchwidget=Container();
            linewidget=Container();
          });
        }
      }
      else{
        setState(() {
          serarchwidget=Container();
        });
      }
    }
    else{
      setState(() {
        serarchwidget=Container();
        linewidget=Container();
      });
    }
  }



}
