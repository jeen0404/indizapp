import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/OtherUserProfile.dart';
import 'package:flutter_app/Post/Comment.dart';
import 'package:flutter_app/algo/StringFilter.dart';
import 'package:flutter_app/lists/list_cardforfollowandcrush.dart';
import 'package:flutter_app/profilepage.dart';
import 'package:pinch_zoom_image/pinch_zoom_image.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

class PostView extends StatefulWidget {

  var postid;
  var showcomment;
  PostView(postdata,{showcomment=false}){
    this.postid=postdata;
    this.showcomment=showcomment;
  }

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> with AutomaticKeepAliveClientMixin {


 var  likes=false;
 FirebaseUser user;
 var time;
 var likeicon=Icons.favorite_border;
 bool liked=true;
 var likeview=true;


 likedata()async{
  var user=await FirebaseAuth.instance.currentUser();
   time=await DateTime.now();
   await Firestore.instance.collection("posts").document(widget.postid).collection("likes").document(user.uid)
       .get().then((result){
     if(result.data!=null){
       likeicon=Icons.favorite;
       liked=true;
     }
   });
   setState(() {
   });
 }

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    likeview=widget.showcomment?false:true;
    likedata();
  }

 @override
  Widget build(BuildContext context) {
   super.build(context);

    return Scaffold(backgroundColor: Colors.white,
    body:StreamBuilder(builder: (_,postsnapshot){
     return !postsnapshot.hasData?Container()
          :
      StreamBuilder(builder:(_,userdata){
        return !userdata.hasData?Container():
        CustomScrollView(
          slivers: <Widget>[

            SliverAppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              leading: IconButton(icon: Icon(Icons.keyboard_backspace,color: Colors.black,), onPressed:(){Navigator.pop(context);}),
              title: Row(
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          border: Border.all(color: Colors.black,width:0.20)),
                      child: CircleAvatar(radius:14.0,backgroundImage: NetworkImage(userdata.data["img_url"]),)),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                      Text(userdata.data["name"],style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 14.0),),
                    ],),
                  )
                ],

              ),
              actions: <Widget>[
              //  IconButton(icon: Icon(Icons.more_vert,color: Colors.black,), onPressed: null)
              ],
            ),

            /*    SliverToBoxAdapter(child:Column(
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(snap.data["name"],style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20.0),),
                  ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("@"+snap.data["username"],style:TextStyle(color: Colors.pink,fontSize:14.0),)
                  ],)
                ],
              ),),*/


            SliverToBoxAdapter(child:  Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: PageView.builder(itemBuilder: (_,index){
                return  Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0)
                      ,image: DecorationImage(image: NetworkImage(postsnapshot.data["images"][index]))),),
                );
              },itemCount: postsnapshot.data["images"].length,scrollDirection: Axis.horizontal,),
            ),),

            SliverToBoxAdapter(child: Divider(height: 1.0,),),
            SliverToBoxAdapter(child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: <Widget>[
              Row(children: <Widget>[
                IconButton(onPressed: (){
                  if(!liked){
                    setState(() {
                      liked=true;
                      likeicon=Icons.favorite;

                    });
                    Firestore.instance.collection("posts").document(widget.postid).collection("likes").document(user.uid)
                        .setData({"id":user.uid,"time":time});
                  }else{
                    setState(() {
                      liked=false;
                      likeicon=Icons.favorite_border;
                    });
                    Firestore.instance.collection("posts").document(widget.postid).collection("likes").document(user.uid)
                        .delete();
                  }
                },icon:Icon(likeicon,color:Colors.pink,size:25.0,)
                )
                ,GestureDetector(
                    onTap: (){
                      if(likeview==false){
                        setState(() {
                          likeview=true;
                        });

                      }
                    },
                    child: Text(postsnapshot.data["t_like"].toString()+" Likes",style: TextStyle(color: Colors.pink,fontWeight: FontWeight.bold),))],),
              Row(children: <Widget>[
                IconButton(icon: Icon(Icons.crop),onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder:(builder)=>Comment(widget.postid,post_uploaderid: postsnapshot.data["userid"],)));
                },),
                GestureDetector(
                    onTap: (){
                      if(likeview==true){
                        setState(() {
                          likeview=false;
                        });
                      }
                    },
                    child: Text(postsnapshot.data["t_comment"].toString()+" Comments",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)))],)
            ]),),


            SliverToBoxAdapter(child: Row(mainAxisAlignment: likeview?MainAxisAlignment.start:MainAxisAlignment.end,children: <Widget>[
                Container(height:4.0,color: Colors.black12,width: MediaQuery.of(context).size.width/2,)
            ],),),
            SliverToBoxAdapter(child: Divider(height: 1.0,),),

           likeview? SliverToBoxAdapter(child: Row(mainAxisAlignment: MainAxisAlignment.start,children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20.0,bottom: 8.0),
                child: Text("liked by",style: TextStyle(fontSize: 22.0),),
              )
            ],),):SliverToBoxAdapter(child: Row(mainAxisAlignment: MainAxisAlignment.start,children: <Widget>[
                Padding(
                padding: const EdgeInsets.only(left: 20.0,bottom: 8.0),
                child: Text("Comments",style: TextStyle(fontSize: 22.0),),
                )
                ],),),



            likeview?StreamBuilder<QuerySnapshot>(builder:(_,likes_snapshot){
            return !likes_snapshot.hasData?SliverToBoxAdapter(child: Container(),)
            :
            SliverList(delegate: SliverChildBuilderDelegate((_,index){
              return list_card(likes_snapshot.data.documents[index].data["id"]);
            },childCount: likes_snapshot.data.documents.length));
            },stream: Firestore.instance.collection("posts").document(widget.postid).collection("likes").snapshots(),)
                :StreamBuilder<QuerySnapshot>(builder:(_,comments_snapshot){
              return !comments_snapshot.hasData?SliverToBoxAdapter(child: Container(),)
                  :
              SliverList(delegate: SliverChildBuilderDelegate((_,index){

                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: GestureDetector(

                    onTap: (){
                      if(userdata.data["uid"]==comments_snapshot.data.documents[index].data["uid"]){
                        return showDialog(barrierDismissible: true,context: context,builder: (BuildContext contaxt){
                          return   AlertDialog(content: Container(
                            height:30.0,
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 5.0,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    GestureDetector(
                                        onTap: (){
                                          Navigator.pop(context);
                                          Firestore.instance.collection("posts").document(widget.postid).collection("comment").document(comments_snapshot.data.documents[index].data["id"])
                                              .delete();
                                          setState(() {
                                            userdata.data.removeAt(index);
                                          });
                                        },
                                        child: Text("Delete")),
                                    VerticalDivider(width: 2.0,color: Colors.black,),

                                    GestureDetector(
                                        onTap: (){
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel")),
                                  ],
                                )


                              ],
                            ),
                          ),
                          );
                        }
                        );
                      }
                  /*    if(user.uid==postsnapshot.data["userid"]){
                        return showDialog(barrierDismissible: true,context: context,builder: (BuildContext contaxt){
                          return   AlertDialog(content: Container(
                            height:30.0,
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 5.0,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    GestureDetector(
                                        onTap: (){
                                          Navigator.pop(context);
                                          Firestore.instance.collection("posts").document(widget.postid).collection("comment").document(userdata.data[index].data["id"])
                                              .delete();
                                          setState(() {
                                            userdata.data.removeAt(index);
                                          });
                                        },
                                        child: Text("Delete")),
                                    VerticalDivider(width: 2.0,color: Colors.black,),

                                    GestureDetector(
                                        onTap: (){
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel")),
                                  ],
                                )


                              ],
                            ),
                          ),
                          );
                        }
                        );
                      }*/
                    },
                    // child: CommentCard(_lists[index].data["id"],postid)
                    child: StreamBuilder(builder: (_,comment_user_data){
                      return Container(
                        decoration: BoxDecoration(color: Color(0xffF9F9F9),borderRadius:BorderRadius.only(topLeft: Radius.circular(50.0),bottomLeft: Radius.circular(50.0))),
                        child: !comment_user_data.hasData?Container():
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment:  CrossAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                                onTap: (){
                                  if(user.uid==comment_user_data.data["uid"]){
                                    Navigator.push(context,MaterialPageRoute(builder: (builder)=>Profile_activity()));
                                  }else{
                                    Navigator.push(context,MaterialPageRoute(builder: (builder)=>OtherUserProfile(comment_user_data.data["uid"])));
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10,top: 4.0,right: 4.0),
                                  child: CircleAvatar(radius:20,backgroundImage:NetworkImage(comment_user_data.data["img_url"],),child: Center(child: Text(comment_user_data.data["username"].substring(0,1),style: TextStyle(color: Colors.white,fontSize:10.0),)),),
                                )),
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(comment_user_data.data["username"] +
                                    "  " ,style: TextStyle(fontSize:12,color: Colors.black,fontWeight: FontWeight.bold),),
                                Text(TimeAgo.getTimeAgo(comments_snapshot.data.documents[index].data["time"].millisecondsSinceEpoch),style: TextStyle(color: Colors.black,fontSize:8.0),),

                              ],),

                            Flexible(child:StringFilter(text:comments_snapshot.data.documents[index].data["text"])
                            ),

                          ],
                        ),
                      );
                    },stream: Firestore.instance.collection("users").document(comments_snapshot.data.documents[index].data["uid"]).snapshots(),),
                  ),
                );

              },childCount: comments_snapshot.data.documents.length));
            },stream: Firestore.instance.collection("posts").document(widget.postid).collection("comment").orderBy("time").snapshots(),),


          ],
        );
      },stream: Firestore.instance.collection("users").document(postsnapshot.data["userid"]).snapshots(),);
    },stream: Firestore.instance.collection("posts").document(widget.postid).snapshots())



    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
