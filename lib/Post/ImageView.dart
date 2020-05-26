import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/Post/PostCard.dart';
import 'package:flutter_app/Post/PostList.dart';
import 'package:pinch_zoom_image/pinch_zoom_image.dart';

class PostImageView extends StatelessWidget {
  var postid;
  var index=0;
  PostImageView(var postid,{index=0}){
    this.postid=postid;
    this.index=index;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(builder:(_,snap){
     return GestureDetector(
       onTap: (){
         Navigator.push(context, MaterialPageRoute(builder: (builder)=>PostList(snap.data["userid"],postion:index+0.0)));
       },
       child: !snap.hasData?Container():
       snap.data.data==null?Container():
       PinchZoomImage(image:
       ExtendedImage.network(
         snap.data["images"][0],
         width:MediaQuery.of(context).size.width,
         height:MediaQuery.of(context).size.width,
         fit: BoxFit.fill,
         cache: true,
         shape: BoxShape.rectangle,
       ))
     );
    },stream:Firestore.instance.collection("posts").document(postid).snapshots() ,);
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


}

