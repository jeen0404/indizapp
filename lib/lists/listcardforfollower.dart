import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ImagesLoding/imageload.dart';
import 'package:flutter_app/OtherUserProfile.dart';
import 'package:flutter_app/firebase/Firebase.dart';

import '../Messages.dart';

class list_card_for_follower extends StatefulWidget {
  var userid;
  list_card_for_follower(useid){
    this.userid=useid;
  }
  @override
  _list_card_for_followerState createState() => _list_card_for_followerState(this.userid);
}

class _list_card_for_followerState extends State<list_card_for_follower> with AutomaticKeepAliveClientMixin{
  var userid;

  FirebaseUser user;


_list_card_for_followerState(id){
  this.userid=id;
}

  List<String> profiledata;

  String crush_text="loding...";
  String S_crush_text="loding...";
  var loding=true;
  var f_f_text="loding..";



  var private=true;
  var img_url="--";
  var name="--";
  var username="--";

  getuserdata() async{
    user=await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(userid).get()
        .then((DocumentSnapshot dq){
      private=dq.data["private"];
      img_url=dq.data["img_url"];
      name=dq.data["name"];
      username=dq.data["username"];
    });
    CheckFollow();
    await setState(() {
      loding=false;
    });
  }

  CheckFollow() async{
    var user =await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(userid).collection("follower").document(user.uid)
        .get().then((result){
      if(result.data!=null){
        setState(() {
          f_f_text="Unfollow";
        });
      }
      else{
        Firestore.instance.collection("users").document(userid).collection("f_request").document(user.uid)
            .get().then((result){
          if(result.data!=null){
            setState(() {
              f_f_text="Requested";
            });
          }else{
            setState(() {
              f_f_text="Follow Back";
            });
          }
        }).catchError((e){
          setState(() {
            f_f_text="Error..";
          });

        });
      }
    }).catchError((e){
      setState(() {
        f_f_text="Error..";
      });
    });
  }

  follow() async{
    var user=await FirebaseAuth.instance.currentUser();
    var time=await DateTime.now();
    if(f_f_text=="Follow Back"){
      if(!private){
        setState(() {
          f_f_text="Unfollow";
        });
        await Firestore.instance.collection("users").document(userid).collection("follower").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          Firestore.instance.collection("users").document(user.uid).collection("follow").document(userid)
              .setData({
            "id":userid,
            "time":time,
          }).then((val){

          });
        });
      }
      else{
        setState(() {
          f_f_text="Requested";
        });
        await Firestore.instance.collection("users").document(userid).collection("f_request").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          Firestore.instance.collection("users").document(user.uid).collection("f_requested").document(userid)
              .setData({
            "id":userid,
            "time":time,
          }).then((val){

          });
        });
      }
    }
    else if(f_f_text=="Unfollow" ||f_f_text=="Requested" ){
      setState(() {
        f_f_text="Follow Back";
      });
      var user =await FirebaseAuth.instance.currentUser();
      await Firestore.instance.collection("users").document(userid).collection("f_request").document(user.uid).delete()
          .then((result){
      });

      await Firestore.instance.collection("users").document(user.uid).collection("f_requested").document(userid).delete()
          .then((result){
      });

      await Firestore.instance.collection("users").document(userid).collection("follower").document(user.uid).delete()
          .then((result){
      });
      await Firestore.instance.collection("users").document(user.uid).collection("follow").document(userid).delete()
          .then((result){
      });
    }
    else if(f_f_text=="loding.."){

    }
  }

  RemoveFollower() async{
    Navigator.pop(context);
    var user=await FirebaseAuth.instance.currentUser();

    await Firestore.instance.collection("users").document(userid).collection("follow").document(user.uid).delete()
        .then((result){
    });
    await Firestore.instance.collection("users").document(user.uid).collection("follower").document(userid).delete()
        .then((result){
    });
  }

  addtoCrush() async{
    Navigator.pop(context);
    var user=await FirebaseAuth.instance.currentUser();
    var time=await DateTime.now();

    if(crush_text=="Add to Crush list"){
      if(!private){
        setState(() {
          crush_text="Remove From Crush List";
        });
        await Firestore.instance.collection("users").document(userid).collection("crush_on_you").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          Firestore.instance.collection("users").document(user.uid).collection("crush").document(userid)
              .setData({
            "id":userid,
            "time":time,
          }).then((val){

          });
        });
      }
      else{
        setState(() {
          crush_text="Requested";
        });
        await Firestore.instance.collection("users").document(userid).collection("crush_on_you_request").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          Firestore.instance.collection("users").document(user.uid).collection("crush_requested").document(userid)
              .setData({
            "id":userid,
            "time":time,
          }).then((val){

          });
        });
      }
    }

    else if(crush_text=="Remove From Crush List" ||crush_text=="Requested" ){
      setState(() {
        crush_text="Add to Crush list";
      });
      var user =await FirebaseAuth.instance.currentUser();
      await Firestore.instance.collection("users").document(userid).collection("crush_on_you").document(user.uid).delete()
          .then((result){
      });

      await Firestore.instance.collection("users").document(user.uid).collection("crush").document(userid).delete()
          .then((result){
      });

      await Firestore.instance.collection("users").document(userid).collection("crush_on_you_request").document(user.uid).delete()
          .then((result){
      });
      await Firestore.instance.collection("users").document(user.uid).collection("crush_requested").document(userid).delete()
          .then((result){
      });
    }
  }

  addtoSecretCrush() async{
    Navigator.pop(context);
    var user=await FirebaseAuth.instance.currentUser();
    var time=await DateTime.now();
    if(S_crush_text=="Add to SecreteCrush"){
      setState(() {
        S_crush_text="Remove From SecreteCrush";
      });
      await Firestore.instance.collection("users").document(user.uid).collection("secret_crush").document(userid)
          .setData({
        "id":userid,
        "time":time,
      });
    }
    else if(S_crush_text=="Remove From SecreteCrush"){
      setState(() {
        S_crush_text="Add to SecreteCrush";
      });
      var user =await FirebaseAuth.instance.currentUser();
      await Firestore.instance.collection("users").document(user.uid).collection("secret_crush").document(userid).delete()
          .then((result){
      });
    }
  }

  CheckCrush() async{
    var user =await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(userid).collection("crush_on_you").document(user.uid)
        .get().then((result){
      if(result.data!=null){
        setState(() {
          crush_text="Remove From Crush List";
        });
      }else{
        Firestore.instance.collection("users").document(userid).collection("crush_on_you_request").document(user.uid)
            .get().then((result){
          if(result.data!=null){
            setState(() {
              crush_text="Requested";
            });
          }
          else{
            setState(() {
              crush_text="Add to Crush list";
            });
          }
        }).catchError((error){
          setState(() {
            crush_text="Error";
          });
        });
      }
    }).catchError((e){
      setState(() {
        crush_text="Error";
      });
    });
  }

  CheckSecretCrush() async{
    var user =await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(user.uid).collection("secret_crush").document(userid)
        .get().then((result){
      if(result.data!=null){
        setState(() {
          S_crush_text="Remove From SecreteCrush";
        });
      }else{
        setState(() {
          S_crush_text="Add to SecreteCrush";
        });
      }
    }).catchError((e){
      setState(() {
        S_crush_text="Add to SecreteCrush";
      });
    });
  }




  @override
  void initState() {
     getuserdata();
    CheckFollow();
    CheckCrush();
    CheckSecretCrush();
  }

  @override
  Widget build(BuildContext context) {
    return  loding?Container(height: 50.0,child:Center(child:Container(width:20.0,child: LinearProgressIndicator(backgroundColor:Colors.white,)),),)
        :user.uid==userid?Container():Padding(
      padding: const EdgeInsets.only(left: 2.0,top: 2.0   ),
      child: Container(
        decoration: BoxDecoration(
            //color: Color(0xffF9F9F9)
            borderRadius:BorderRadius.only(topLeft: Radius.circular(50.0),bottomLeft: Radius.circular(50.0))),
        height:70.0,
        child:Column(children: <Widget>[
              GestureDetector(
                onTap: (){
                  Navigator.push(context,MaterialPageRoute(builder: (builder)=>OtherUserProfile(userid)));
                },
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ImageLoad(url: img_url,hight:50,width:50.0,),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(name,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize:14.0),),
                          SizedBox(height:5.0,),
                          Text(username,style: TextStyle(color: Colors.black26,fontWeight: FontWeight.bold,fontSize: 12.0),)
                        ],
                      ),
                    ),
                    Expanded(child: Container()),
                    //IconButton(icon: Icon(Icons.keyboard_backspace,color: Colors.black45,), onPressed: (){})
                    IconButton(icon: Icon(Icons.clear,color: Colors.black54,size: 15.0,), onPressed: (){
                      return showDialog(barrierDismissible: true,context: context,builder: (BuildContext contaxt){
                        return   AlertDialog(content: Container(
                          height: 220.0,
                          child: Column(
                            children: <Widget>[
                              Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                                ImageLoad(url: img_url,hight:60,width:60.0,),
                              ],),
                              Column(
                                children: <Widget>[
                                  Text(name,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18.0),),
                                  Text(username,style: TextStyle(color: Colors.black26,fontWeight: FontWeight.bold,fontSize: 12.0),)
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(child: Text("Remove Follower"),),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(width: 200.0,child: Text("Indiz won't tell @${username} they were removed from your followers list",style: TextStyle(fontSize: 10.0),),),
                                  )
                                ],
                              ),
                              Divider(height: 1.0,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    GestureDetector(
                                        onTap: (){
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel")),
                                    VerticalDivider(width:2.0,),
                                    GestureDetector(
                                        onTap: (){
                                          RemoveFollower();
                                        },
                                        child: Text("Remove")),
                                  ],
                                ),
                              )


                            ],
                          ),
                        ),
                        );
                      }
                      );
                    }),

                    user.uid==userid?Container():GestureDetector(
                      onTap: (){
                        follow();
                      },
                      child: Container(

                          height:30.0,
                          width: 80.0,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0),color: Colors.blueAccent)
                          ,child: Center(child: Text(f_f_text,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12.0),),)
                      ),
                    ),

                    user.uid==userid?Container():GestureDetector(
                        onTap: (){
                          showDialog(barrierDismissible: true,context: context,builder: (BuildContext contaxt){
                            return   AlertDialog(content: Container(
                              height: 250.0,
                              child: Column(
                                children: <Widget>[
                                  Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                                    ImageLoad(url: img_url,hight:60,width:60.0,),
                                  ],),
                                  Column(
                                    children: <Widget>[
                                      Text(name,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18.0),),
                                      Text(username,style: TextStyle(color: Colors.black26,fontWeight: FontWeight.bold,fontSize: 12.0),)
                                    ],
                                  ),
                                  SizedBox(height: 15.0,),
                                  Divider(height: 1.0,),
                                  Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                                    GestureDetector(
                                      onTap: (){
                                        addtoCrush();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                                        child: Center(child: Text(crush_text)),
                                      ),
                                    )
                                  ],),
                                  Divider(height: 1.0,),
                                  Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                                    GestureDetector(
                                      onTap: (){
                                        addtoSecretCrush();
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                                          child: Center(child: Text(S_crush_text,),)
                                      ),
                                    )
                                  ],),
                                  Divider(height: 1.0,),
                                  Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                                          child: Center(child: Text("Cancel",),)
                                      ),
                                    )
                                  ],),

                                ],
                              ),
                            ),
                            );
                          }
                          );
                        },
                        child: Icon(Icons.more_vert,color: Colors.black54,)),

                  ],
                ),
              ),
              //  Divider(height: 1.0,)
            ],),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

