import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/ImagesLoding/imageload.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

class ChatCard extends StatefulWidget  {
  var chatid;
  var userid;
  ChatCard(id,userid){
    this.chatid=id;
    this.userid=userid;
  }
  @override
  _ChatCardState createState() => _ChatCardState(this.chatid,this.userid);
}

class _ChatCardState extends State<ChatCard> with AutomaticKeepAliveClientMixin {

  var chatid;
  var userid;
  _ChatCardState(id,userid){
    this.chatid=id;
    this.userid=userid;
  }


  var private=true;
  var img_url="--";
  var name="--";
  var username="--";
  var lastmessage="--";
  var lastmessagetime;
  var unseenmesage=0;
  bool loding=true;

  getuserdata() async{
    await Firestore.instance.collection("users").document(userid).get()
        .then((DocumentSnapshot dq){
      private=dq.data["private"];
      img_url=dq.data["img_url"];
      name=dq.data["name"];
      username=dq.data["username"];
    });
    var user= await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(user.uid).collection("chat").document(userid).snapshots().
      listen((DocumentSnapshot dq){
          lastmessage=dq.data["last_message"];
          lastmessagetime=dq.data["last_message_time"];
          setState(() {
            loding=false;
            unseenmesage=dq.data["unseen_message"]==null?0:dq.data["unseen_message"]>99?99:dq.data["unseen_message"];
          });
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
    return loding?Container(height: 50.0,child:Center(child:Container(width:20.0,child: LinearProgressIndicator(backgroundColor:Colors.white,)),),):
    Row(
      mainAxisAlignment:MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left:10.0,right: 10.0,top: 10.0),
            child: ImageLoad(url: img_url,hight: 50.0,width:50.0,),
          ),
          unseenmesage==0?Container():Positioned(top: 0.0,left:2.0,child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white,width:2.0),color: Colors.blueAccent,shape: BoxShape.circle),child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(unseenmesage.toString(),style: TextStyle(color: Colors.white,fontSize:14.0,fontWeight: FontWeight.bold),),
          ),))
      ],),

        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height:20.0,),
                  Text(username,style:TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize:15.0)),
                  Text(lastmessage.length<25?lastmessage:lastmessage.substring(0,25)+"....",style:TextStyle(color: Colors.black54,fontWeight: FontWeight.normal,fontSize:12.0)),
                ],
              ),

              Expanded(child: Container()),
              Padding(
                  padding: const EdgeInsets.only(top:26.0),
                  child:Icon(Icons.access_time,size: 10.0,color: Colors.black26,)
              ),

              Padding(
                padding: const EdgeInsets.only(top:25.0,right:8.0),

                child: Text(TimeAgo.getTimeAgo(lastmessagetime.millisecondsSinceEpoch),style: TextStyle(color: Colors.black26,fontSize: 10.0,fontWeight: FontWeight.bold),),
              ),

            ],
          ),
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
