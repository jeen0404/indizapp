import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ImagesLoding/imageload.dart';
import 'package:flutter_app/OtherUserProfile.dart';
import 'package:time_ago_provider/time_ago_provider.dart';


class FollowRequestNotification extends StatefulWidget {
  var notificationdata;
  FollowRequestNotification(data){
    this.notificationdata=data;
  }




  @override
  _FollowRequestNotificationState createState() => _FollowRequestNotificationState(this.notificationdata);
}

class _FollowRequestNotificationState extends State<FollowRequestNotification> with AutomaticKeepAliveClientMixin{
  var notificationdata;
  var loading=true;
  _FollowRequestNotificationState(data){
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
    return  loading?Container(height: 50.0,child:Center(child:Container(width:20.0,child: LinearProgressIndicator(backgroundColor:Colors.white,)),),):
    Row(children: <Widget>[
      GestureDetector(
        onTap: (){
          Navigator.push(context,MaterialPageRoute(builder: (builder)=>OtherUserProfile(notificationdata.data["uid"])));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:ImageLoad(url: img_url,hight: 40.0,width:40.0,),  ),
      ),
      SizedBox(width: 10.0,),
      Flexible(child: RichText(text:TextSpan(children: [
        TextSpan(text: username+"  " ,style: TextStyle(fontSize: 14.0,color: Colors.black,fontWeight: FontWeight.bold),),
        TextSpan(text:notificationdata.data["text"],style: TextStyle(color: Colors.black,fontSize:14.0),),
        TextSpan(text:TimeAgo.getTimeAgo(notificationdata.data["time"].millisecondsSinceEpoch),style: TextStyle(color: Colors.blueAccent,fontSize:8.0),),
      ]))),
    ],);
  }
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
