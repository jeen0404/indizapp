import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ImagesLoding/imageload.dart';
import 'package:flutter_app/OtherUserProfile.dart';

import '../Messages.dart';

class SendMessageChatPageCard extends StatefulWidget {
  var userid;
  SendMessageChatPageCard(useid){
    this.userid=useid;
  }

  @override
  _SearchUserCardState createState() => _SearchUserCardState(userid);
}

class _SearchUserCardState extends State<SendMessageChatPageCard> with AutomaticKeepAliveClientMixin{

  var userid;

  _SearchUserCardState(userid){
    this.userid=userid;//other user id
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
  FirebaseUser user;

  getuserdata() async{
    user=await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(userid).get()
        .then((DocumentSnapshot dq){
      private=dq.data["private"];
      img_url=dq.data["img_url"];
      name=dq.data["name"];
      username=dq.data["username"];
    });
    await setState(() {
      loding=false;
    });
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserdata();
  }

  @override
  Widget build(BuildContext context) {
    return loding?Container(height: 70.0,child:Center(child:Container(width:20.0,child: LinearProgressIndicator(backgroundColor:Colors.white,)),),):
    user.uid==userid?Container():GestureDetector(
      onTap: (){
        Navigator.push(context,MaterialPageRoute(builder: (builder)=>OtherUserProfile(userid)));
      },
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ImageLoad(url: img_url,hight:50.0,width:50.0,),
          ),
          Padding(
            padding: const EdgeInsets.only(left:15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(name,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 14.0),),
                SizedBox(height:5.0,),
                Text(username,style: TextStyle(color: Colors.black26,fontWeight: FontWeight.bold,fontSize: 12.0),)
              ],
            ),
          ),
          Expanded(child: Container()),
          //  IconButton(icon: Icon(Icons.keyboard_backspace,color: Colors.black45,), onPressed: null)

          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (builder)=>Messages(userid)));
            },
            child: Container(
                height: 30.0,
                width: 70.0,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0),color: Colors.blueAccent)
                ,child: Center(child: Text("Message",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12.0),),)),
          ),
          SizedBox(width: 20.0,)
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

