import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/OtherUserProfile.dart';
import 'package:flutter_app/algo/StringFilter.dart';
import 'package:time_ago_provider/time_ago_provider.dart';


class CommentCard extends StatefulWidget {
  var comment;
  var postid;

  CommentCard(id,pid){
    this.comment=id;
    this.postid=pid;
  }

  @override
  _CommentCardState createState() => _CommentCardState(comment,postid);
}

class _CommentCardState extends State<CommentCard> with AutomaticKeepAliveClientMixin {
  var comment;
  var postid;
  _CommentCardState(id,pid){
    this.comment=id;
    this.postid=pid;
  }

  DocumentSnapshot _documentSnapshot;

  var private=true;

  var img_url="--";

  var name="--";

  var username="--";

  bool loadding=true;


  getcomment()async {

   await Firestore.instance.collection("posts").document(postid).collection("comment").document(comment)
        .get().then((DocumentSnapshot dq){
          print(dq.data);
       _documentSnapshot=dq;
    });
   getuserdata() ;
  }


  getuserdata() async{
    await Firestore.instance.collection("users").document(_documentSnapshot.data["uid"]).get()
        .then((DocumentSnapshot dq){
      private=dq.data["private"];
      img_url=dq.data["img_url"];
      name=dq.data["name"];
      username=dq.data["username"];
    });
    await setState(() {
      loadding=false;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getcomment();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:12.0,vertical:2.0),
      child: loadding?Container():
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment:  CrossAxisAlignment.center,
        children: <Widget>[
        Flexible(child: StringFilter(text:"@"+username+": "+ _documentSnapshot.data["text"],style: TextStyle(color: Colors.black38),)),
        Padding(
          padding: const EdgeInsets.only(left: 8.0,top:6.0),
          child: Text(TimeAgo.getTimeAgo(_documentSnapshot.data["time"].millisecondsSinceEpoch),style: TextStyle(color: Colors.pink,fontSize:8.0),),
        ),
      ],
      ),
    );
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
