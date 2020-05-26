import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/OtherUserProfile.dart';
import 'package:time_ago_provider/time_ago_provider.dart';


class SecretCrushNotification extends StatefulWidget {
  var notificationdata;
  SecretCrushNotification(data){
    this.notificationdata=data;
  }




  @override
  _SecretCrushNotificationState createState() => _SecretCrushNotificationState(this.notificationdata);
}

class _SecretCrushNotificationState extends State<SecretCrushNotification> with AutomaticKeepAliveClientMixin{
  var notificationdata;
  var loading=true;
  _SecretCrushNotificationState(data){
    this.notificationdata=data;
  }


  var private=true;
  var img_url="--";
  var name="--";
  var username="--";

  getuserdata() async {
    await Firestore.instance.collection("users").document(notificationdata.data["uid"]).get()
        .then((DocumentSnapshot dq){
      private=dq.data["private"];
      img_url=dq.data["img_url"];
      name=dq.data["name"];
      username=dq.data["username"];
    });
    await setState(() {
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
    return loading?Container(height: 50.0,child:Center(child:Container(width:20.0,child: LinearProgressIndicator(backgroundColor:Colors.white,)),),):Row(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(radius:20,backgroundColor: Colors.blueAccent,child: Text( username.substring(0,1).toUpperCase(),style: TextStyle(color: Colors.white,fontSize: 22.0),)),
      ),
      SizedBox(width: 10.0,),
      Flexible(child: RichText(text:TextSpan(children: [
       // TextSpan(text:" ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0,color: Colors.black),),
        TextSpan(text: notificationdata.data["text"],style: TextStyle(color: Colors.black,fontSize:14.0),),
        TextSpan(text:"  "+TimeAgo.getTimeAgo(notificationdata.data["time"].millisecondsSinceEpoch),style: TextStyle(color: Colors.blueAccent,fontSize:8.0),),
      ]))),

    ],);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
