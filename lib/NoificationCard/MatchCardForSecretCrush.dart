import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ImagesLoding/imageload.dart';
import 'package:flutter_app/OtherUserProfile.dart';
import 'package:flutter_app/lists/SecretCrush.dart';
import 'package:time_ago_provider/time_ago_provider.dart';


class MatchCardForSecretCrush extends StatefulWidget {
  var notificationdata;
  MatchCardForSecretCrush(data){
    this.notificationdata=data;
  }




  @override
  _MatchCardForSecretCrushState createState() => _MatchCardForSecretCrushState(this.notificationdata);
}

class _MatchCardForSecretCrushState extends State<MatchCardForSecretCrush> with AutomaticKeepAliveClientMixin{
  var notificationdata;
  var loading=true;
  _MatchCardForSecretCrushState(data){
    this.notificationdata=data;
  }


  var private=true;
  var img_url="--";
  var name="--";
  var username="--";
  var o_private=true;
  var o_img_url="--";
  var o_name="--";
  var o_username="--";

  getuserdata() async {
    /*FirebaseUser user= await FirebaseAuth.instance.currentUser();
    var otheruseruid;
    if(user.uid!=notificationdata.data["uid1"]){
      otheruseruid=notificationdata.data["uid1"];
    }{
      otheruseruid=notificationdata.data["uid2"];
    }*/
    await Firestore.instance.collection("users").document(notificationdata.data["uid2"]).get()
        .then((DocumentSnapshot dq){
      private=dq.data["private"];
      img_url=dq.data["img_url"];
      name=dq.data["name"];
      username=dq.data["username"];

    });
    await Firestore.instance.collection("users").document(notificationdata.data["uid1"]).get()
        .then((DocumentSnapshot dq){
      o_private=dq.data["private"];
      o_img_url=dq.data["img_url"];
      o_name=dq.data["name"];
      o_username=dq.data["username"];

    });
    setState(() {
      loading=false;
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
    return  Container(
      margin: EdgeInsets.all(2.0),
      decoration: BoxDecoration(color: Color(0xffEFFFFF),borderRadius: BorderRadius.circular(10.0)),
      child: loading?Container(height: 50.0,child:Center(child:Container(width:20.0,child: LinearProgressIndicator(backgroundColor:Colors.white,)),),):
   Column(children: <Widget>[
       Divider(height: 1.0,),
   Row(
   mainAxisAlignment: MainAxisAlignment.start,
       crossAxisAlignment:  CrossAxisAlignment.center,
       children: <Widget>[
         Column(children: <Widget>[
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: ImageLoad(url: img_url,hight: 40.0,width:40.0,),
           ),

           Padding(
             padding: const EdgeInsets.all(8.0),
             child: Column(children: <Widget>[
               Row(mainAxisAlignment: MainAxisAlignment.start,children: <Widget>[Text(username,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 14.0))],) ,
               //   Row(mainAxisAlignment: MainAxisAlignment.start,children: <Widget>[Text(username)],)
             ],),
           ),

       ],),

         Expanded(child: Container()),
         GestureDetector(
           onTap: (){
             Navigator.push(context,MaterialPageRoute(builder: (builder)=>SecretCrushList()));
           },
           child: Column(
             children: <Widget>[
               IconButton(icon: Icon(Icons.favorite,color: Colors.pink,), onPressed:(){
               }),
               Text("Matched",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 14.0),)
             ],
           ),
         ),
         Expanded(child: Container()),


         Column(children: <Widget>[

           GestureDetector(
             onTap: (){
               Navigator.push(context,MaterialPageRoute(builder: (builder)=>OtherUserProfile(notificationdata.data["uid1"])));
             },
             child: Padding(
               padding: const EdgeInsets.all(8.0),
               child:  ImageLoad(url:o_img_url,hight: 40.0,width:40.0,),
             ),
           ),
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: Column(children: <Widget>[
               Row(mainAxisAlignment: MainAxisAlignment.start,children: <Widget>[Text(o_username,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 14.0))],) ,
               //    Row(mainAxisAlignment: MainAxisAlignment.start,children: <Widget>[Text(o_username)],)
             ],),
           ),
      ],),


       ],
   ),
       Divider(height: 1.0,),
   ],),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
