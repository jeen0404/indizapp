import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ImagesLoding/imageload.dart';
import 'package:flutter_app/OtherUserProfile.dart';
import 'package:flutter_app/Post/PostView.dart';
import 'package:time_ago_provider/time_ago_provider.dart';
import 'package:flutter/gestures.dart';


class TextNotification extends StatefulWidget {
  var notificationdata;
  TextNotification(data){
    this.notificationdata=data;
  }




  @override
  _TextNotificationState createState() => _TextNotificationState(this.notificationdata);
}

class _TextNotificationState extends State<TextNotification> with AutomaticKeepAliveClientMixin{
  var notificationdata;
  var loading=true;
  _TextNotificationState(data){
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
      setState(() {
        loading=false;
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
    return  Container(
      margin: EdgeInsets.all(2.0),
      decoration: BoxDecoration(color: Color(0xfffcfFfF),borderRadius: BorderRadius.circular(10.0)),
      child: loading?Container(height: 50.0,child:Center(child:Container(width:20.0,child: LinearProgressIndicator(backgroundColor:Colors.white,)),),):
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment:  CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
              onTap: (){
                Navigator.push(context,MaterialPageRoute(builder: (builder)=>OtherUserProfile(notificationdata.data["uid"])));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:ImageLoad(url: img_url,hight: 40.0,width:40.0,),
              )),
          SizedBox(width: 10.0,),
          Expanded(child: RichText(text:TextSpan(children: [
            TextSpan(text:username  ,style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold,color: Colors.black),),
            TextSpan(text:notificationdata.data["text"],style: TextStyle(fontSize:14.0,color: Colors.black,),recognizer: TapGestureRecognizer()..onTap=(){
            //  if(notificationdata.data["text"]=="liked your post." || notificationdata.data["text"]=="commented on your post."){

                       }),
            TextSpan(text:"  "+TimeAgo.getTimeAgo(notificationdata.data["time"].millisecondsSinceEpoch),style: TextStyle(color: Colors.blueAccent,fontSize:8.0),),
          ]))),
          /* Container(child: IconButton(icon: Icon(Icons.delete), onPressed: (){
              }),)*/


          Row(mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              notificationdata.data["postId"]!=null?StreamBuilder(builder: (_,postsdata){
                return !postsdata.hasData?Container():postsdata.data.data==null?Container():Padding(
                  padding: const EdgeInsets.only(left: 20.0,right: 5.0),
                  child: GestureDetector(
                    onTap: (){
                      if(notificationdata.data["postId"]!=null){
                        Navigator.push(context,MaterialPageRoute(builder: (builder)=>PostView(notificationdata.data["postId"])));
                      }
                    },
                    child: ExtendedImage.network(
                    postsdata.data["images"][0],
                    width:45.0,
                    height:45.0,
                    fit: BoxFit.fill,
                    cache: true,
                     borderRadius: BorderRadius.circular(5.0),
                     // border: Border.all(r),
                    ),
                  ),
                );
              },stream:  Firestore.instance.collection("posts").document(notificationdata.data["postId"]).snapshots(),):Container(),
            ],
          ),

          ],

      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
