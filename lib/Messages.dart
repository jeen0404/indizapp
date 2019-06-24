import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

class Messages extends StatefulWidget {
  var other_user_id;
  Messages(id){
    this.other_user_id=id;
  }
  @override
  _MessagesState createState() => _MessagesState(this.other_user_id);
}

class _MessagesState extends State<Messages> {
  var other_user_id;
  _MessagesState(id) {
    this.other_user_id = id;
  }
  var loding=true;

  List<String> posts=[];

  String profile_url="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoQrCJR3WvVUX-8ZVYO2KPcv7f-nFnnd3lKdGl9zkzbI3CyYi3Bw";

  String name="---";
  FirebaseUser user;

  String username="---";
  bool is_verifyed=true;
  bool private=true;

  String bio="---";
  String t_follower="---";
  String t_following="---";
  String t_posts="---";
  String t_likes="---";
  String t_profile_visits="---";
  String t_tags="---";
  String t_close_friend="---";
  String t_crush="---";
  String t_secret_crush="---";
  int _per_page=50;
  String chat_id;

  List<DocumentSnapshot> _product=[];
  DocumentSnapshot _lastdocument;
  ScrollController _scrollController=ScrollController();
  var message="";





  getprofiledata() async {
    user=await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(other_user_id).get().then((result){
      profile_url=result.data["img_url"];
      username=result.data["username"];
      name=result.data["name"];
      is_verifyed=result.data["is_verifyed"];
      private=result.data["private"];
      setState(() {
        loding=false;
      });
     checkChat();
    }).catchError((e){
      print(e.message);
      return;
    });
  }



  checkChat() async{
    await Firestore.instance.collection("users").document(user.uid).collection("chat").document(other_user_id)
        .get().then((result){
          if(result.data!=null){
            chat_id=result.data["id"];
            setState(() {

            });
          }
          else{
            setState(() {
              loding=false;
            });
          }
    });
  }


  _sendmessage(String taxt,{type=0,image}) async{
    {
      print("wait.........");
      print(message.length);
        if(taxt.length > 0){
          if(chat_id != null) {
            print("wait......... again");
            var time=await DateTime.now();
            var pushid =FirebaseDatabase.instance.reference().push().key;
           await Firestore.instance.collection("chats").document(chat_id).collection("chat")
                .document(pushid).setData({
              "pushid":pushid,
              "id":user.uid,
              "message":taxt,
              "time":time,
              "image":image,
              "type":0,
            }).then((result){
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
           }).catchError((error){
              print(error.toString());
            });
          }
          else{
            print("wait......... please");
            chat_id=FirebaseDatabase.instance.reference().push().key;
           await Firestore.instance.collection("users").document(user.uid).collection("chat").document(other_user_id)
                .setData({
              "id":chat_id,
              "img_url":profile_url,
            }).catchError((e){
              print("e --"+e.message);
           });
           await Firestore.instance.collection("users").document(other_user_id).collection("chat").document(user.uid)
                .setData({
              "id":chat_id,
              "img_url":profile_url,
            }).catchError((er){
              print("er --"+er.message);
           });
           _sendmessage(taxt);
          }
        }

    }
  }






  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getprofiledata();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:AppBar(
          backgroundColor: Colors.white,
          centerTitle:true,
          iconTheme: IconThemeData(color: Colors.black45),
          title: Text(username,style: TextStyle(color: Colors.blueAccent),),
          actions: <Widget>[
            Container(height: 30.0,width:55.0,child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(backgroundImage: NetworkImage(profile_url),),
            ),)
          ],
        ) ,
    body:Column(
      children: <Widget>[
        Flexible(child:  StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("chats").document(chat_id).collection("chat").orderBy("time").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            return _buildList(context, snapshot.data.documents);
          },
        ),),
                  Container(
                    height: 60.0,
                    margin: EdgeInsets.symmetric(horizontal:8.0),
                      child: Row(
                      children: <Widget>[
                      Flexible(child:  Container(
                        height: 40.0,
                        decoration: BoxDecoration(border: Border.all(color: Colors.black45,width: 1.0,),borderRadius: BorderRadius.circular(10.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                          decoration: InputDecoration.collapsed(hintText: "send a message"),
                          controller: _textEditingController,
                          onSubmitted: _handalesubmited,
                            onChanged:(val)=> _scrollController.jumpTo(_scrollController.position.maxScrollExtent),
                  ),
                        ),
                      ),),
                  Container(
                      child:IconButton(icon: Icon(Icons.send), onPressed:()=>_handalesubmited(_textEditingController.text)),
                  )
                  ],
                  )
                  ),
      ],
    )
    );
  }
  final TextEditingController _textEditingController=new TextEditingController();
  void _handalesubmited(String text){
    _sendmessage(text);
    _textEditingController.clear();
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView.builder(itemBuilder: (context,index){
      if(index==snapshot.length-1){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
      if(snapshot[index].data["id"]==user.uid){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10.0,right: 10.0),
              width: 200.0,child:
            Container(decoration: BoxDecoration(borderRadius:BorderRadius.only(bottomLeft: Radius.circular(10.0),
              topLeft: Radius.circular(10.0),bottomRight: Radius.circular(10.0)
            ),border: Border.all(color: Colors.black12,width: 1.0)),child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20.0),
              child: Text(snapshot[index].data["message"],strutStyle: StrutStyle(forceStrutHeight: false),),
            )),alignment: Alignment.centerRight,),
            Padding(
              padding: const EdgeInsets.only(
                  right: 10.0),
              child: Text(TimeAgo.getTimeAgo(snapshot[index].data["time"].millisecondsSinceEpoch),style: TextStyle(fontSize:6.0),),
            ),
          ],
        );
      }
      else{
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: CircleAvatar(radius:6,backgroundImage: NetworkImage(profile_url),),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0),
              width: 200.0,child:
            Container(decoration: BoxDecoration(borderRadius:BorderRadius.only(bottomLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),bottomRight: Radius.circular(10.0)
            ),border: Border.all(color: Colors.black12,width: 1.0)),child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20.0),
              child: Text(snapshot[index].data["message"],strutStyle: StrutStyle(forceStrutHeight: false),),
            )),alignment: Alignment.centerLeft,),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(TimeAgo.getTimeAgo(snapshot[index].data["time"].millisecondsSinceEpoch),style: TextStyle(fontSize:6.0),),
            ),
          ],
        );
      }
      },itemCount: snapshot.length,controller: _scrollController,);

  }

}
