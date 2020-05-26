import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/OtherUserProfile.dart';
import 'package:flutter_app/algo/StringFilter.dart';
import 'package:flutter_app/profilepage.dart';
import 'package:time_ago_provider/time_ago_provider.dart';

import 'package:flutter_app/Post/Commentcard.dart';


class Comment extends StatefulWidget {
  var postid;
  var post_uploaderid;
  Comment(id,{post_uploaderid=null}){
    postid=id;
    this.post_uploaderid=post_uploaderid;
  }

  @override
  _CommentState createState() => _CommentState(this.postid,post_uploaderid);
}

class _CommentState extends State<Comment> {
  var postid;
  var post_uploaderid;
  _CommentState(id,post_uploaderid) {
    postid = id;
    this.post_uploaderid=post_uploaderid;
  }

  FirebaseUser user;
  List<DocumentSnapshot> _lists = [];
  DocumentSnapshot _lastnode;
  int _perpage =25;
  var loading = true;
  ScrollController _scrollController = ScrollController();
  Widget serarchwidget=Container();
  Widget linewidget=Container();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  getuserdata() async{
    user =await FirebaseAuth.instance.currentUser();
    setState(() {
      loading=false;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserdata();
    _scrollController.addListener((){
      double maxscroll=_scrollController.position.maxScrollExtent;
      double currentscroll=_scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if(maxscroll-currentscroll < delta){
        setState(() {
          _perpage=_perpage+10;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        //centerTitle: true,
        elevation: 0.0,
        title: Text("comment",style: TextStyle(color: Colors.black),),
        leading: new IconButton(icon: Icon(Icons.keyboard_backspace), onPressed: (){
          Navigator.pop(context);
        }),
        actionsIconTheme: IconThemeData(color: Colors.black),
      ),

      body:Column(
        children: <Widget>[
          Divider(height: 1.0,),
          Flexible(child:  StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection("posts").document(postid).collection("comment").orderBy("time").limit(_perpage).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)return Column(children: <Widget>[Center(child: CircularProgressIndicator(),)],);
              return _buildList(context, snapshot.data.documents);
            },
          ),),
        //  Divider(height: 1.0,),
          Column(children: <Widget>[
            linewidget,
            serarchwidget,
            Container(
              child: Row(
                children: <Widget>[
                  Flexible(child:  Container(
                    margin: EdgeInsets.only(left: 8.0 ),
                    height: 40.0,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black12,width: 1.0,),borderRadius: BorderRadius.circular(5.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration.collapsed(hintText: "Write your comment here"),
                        controller: _textEditingController,
                        onSubmitted: _handalesubmited,

                        onChanged:(val){
                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                          if(val.length>200){
                            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("comment length must be less than 200 character",),duration:Duration(microseconds: 10),));
                          }
                          else{
                            TagHasTag(val);
                          }

                        },
                      ),
                    ),
                  ),),
                  Container(
                    child:IconButton(icon: Icon(Icons.send,size: 20.0,), onPressed:()=>_handalesubmited(_textEditingController.text)),
                  )
                ],
              ),
            ),
          ],)

        ],
      ),

    );
  }

  _sendmessage(String taxt) async{

    if(taxt.length > 0){
    var user=await FirebaseAuth.instance.currentUser();
    var time=await DateTime.now();
    var pushid =await FirebaseDatabase.instance.reference().push().key;
    await Firestore.instance.collection("posts").document(postid).collection("comment")
        .document(pushid).setData({
      "id":pushid,
      "uid":user.uid,
      "text":taxt,
      "time":time,
    });
    }
  }
  final TextEditingController _textEditingController=new TextEditingController();
  void _handalesubmited(String text){
    if(text.length>200){
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("comment length must be less than 200 character",),duration:Duration(microseconds: 10),));
    }
    else{
      _sendmessage(text);
      _textEditingController.clear();
    }
  }

  TagHasTag(text){
    var wordlist;
    if(text!=""){
      wordlist=text.split(' ');
      if(wordlist!=""){
        var word=wordlist[wordlist.length-1];
        if(word.length>1){
          print(word);

          if(word.substring(0,1)=="@"){
            print(word.substring(1,word.length));
            FirebaseDatabase.instance.reference().child("users").orderByChild("username").startAt(word.substring(1,word.length))
                .endAt(word.substring(1,word.length)+"\uf8ff").limitToFirst(50).once().then((DataSnapshot val){
              print(val.value);
              var list=[];
              if(val.value!=null){
                for (var i in val.value.values){
                  list.add(i);
                }
                setState(() {
                  linewidget=Divider(height: 1.0,);
                  serarchwidget=Container(height: 90.0,
                      child: Column(children: <Widget>[
                        Row(mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[

                            Container(height: 30.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Searching For"+":  '"+word+"'"),
                              ),),
                          ],
                        ),
                        Container(
                            color: Colors.white,
                            height:45.0,
                            child:
                            ListView.builder(itemBuilder:(_,index){
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: (){
                                    var text=_textEditingController.text;
                                    var text2=text.replaceAll(word,"@"+list[index]["username"]+" ");
                                    print(text);
                                    _textEditingController.text=text2;
                                    setState(() {
                                      var cursorPos = _textEditingController.selection;
                                      cursorPos = new TextSelection.fromPosition(
                                          new TextPosition(offset: _textEditingController.text.length));
                                      _textEditingController.selection = cursorPos;
                                      serarchwidget=Container();
                                      linewidget=Container();
                                    });
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 1.0),
                                          borderRadius: BorderRadius.circular(2.0)
                                      )
                                      ,child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 20.0),
                                    child: Text("@"+list[index]["username"],style: TextStyle(color: Colors.pink,fontWeight: FontWeight.bold),),
                                  )),
                                ),
                              );
                            },itemCount:list.length,scrollDirection: Axis.horizontal,)
                        ),
                      ],)
                  );
                });
              }
              else{
                setState(() {
                  serarchwidget=Container();
                  linewidget=Container();
                });
              }
            });
          }

          else if(word.substring(0,1)=="#"){
            var list=[];

            FirebaseDatabase.instance.reference().child("hashtag").orderByChild("username").startAt(word.substring(1,word.length))
                .endAt(word.substring(1,word.length)+"\uf8ff").limitToFirst(50).once().then((DataSnapshot val){
              print(val.value);

              if(val.value!=null){
                for (var i in val.value.values){
                  list.add(i);
                }
                setState(() {
                  linewidget=Divider(height: 1.0,);
                  serarchwidget=Container(height:90,
                      child: Column(children: <Widget>[
                        Row(mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(height: 30.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Searching For"+":  '"+word+"'"),
                              ),),
                          ],
                        ),
                        Container(
                            color: Colors.white,
                            height:45.0,
                            child:
                            ListView.builder(itemBuilder:(_,index){
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: (){
                                    var text=_textEditingController.text;
                                    var text2=text.replaceAll(word,"#"+list[index]["username"]+" ");
                                    print(text);
                                    _textEditingController.text=text2;
                                    setState(() {
                                      var cursorPos = _textEditingController.selection;
                                      cursorPos = new TextSelection.fromPosition(
                                          new TextPosition(offset: _textEditingController.text.length));
                                      _textEditingController.selection = cursorPos;
                                      serarchwidget=Container();
                                      linewidget=Container();
                                    });
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 1.0),
                                          borderRadius: BorderRadius.circular(2.0)
                                      )
                                      ,child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 20.0),
                                    child: Text("@"+list[index]["username"],style: TextStyle(color: Colors.pink,fontWeight: FontWeight.bold),),
                                  )),
                                ),
                              );
                            },itemCount:list.length,scrollDirection: Axis.horizontal,)
                        ),
                      ],)
                  );
                });
              }
              else{
                list.add({"username":word.substring(1,word.length)});
                setState(() {
                  linewidget=Divider(height: 1.0,);
                  serarchwidget=Container(height: 90.0,
                      child: Column(children: <Widget>[
                        Row(mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[

                            Container(height: 30.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Searching For"+":  '"+word+"'"),
                              ),),
                          ],
                        ),
                        Container(
                            color: Colors.white,
                            height:45.0,
                            child:
                            ListView.builder(itemBuilder:(_,index){
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: (){
                                    var text=_textEditingController.text;
                                    var text2=text.replaceAll(word,"#"+list[index]["username"]+" ");
                                    print(text);
                                    _textEditingController.text=text2;
                                    setState(() {
                                      var cursorPos = _textEditingController.selection;
                                      cursorPos = new TextSelection.fromPosition(
                                          new TextPosition(offset: _textEditingController.text.length));
                                      _textEditingController.selection = cursorPos;
                                      serarchwidget=Container();
                                      linewidget=Container();
                                    });
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 1.0),
                                          borderRadius: BorderRadius.circular(2.0)
                                      )
                                      ,child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 20.0),
                                    child: Text("#"+list[index]["username"],style: TextStyle(color: Colors.pink,fontWeight: FontWeight.bold),),
                                  )),
                                ),
                              );
                            },itemCount:list.length,scrollDirection: Axis.horizontal,)
                        ),
                      ],)
                  );
                });
              }
            });
          }
        }else{
          setState(() {
            serarchwidget=Container();
            linewidget=Container();
          });
        }
      }
      else{
        setState(() {
          serarchwidget=Container();
        });
      }
    }
    else{
      setState(() {
        serarchwidget=Container();
        linewidget=Container();
      });
    }
  }

Widget _buildList(BuildContext context, List<DocumentSnapshot> _lists) {

  return ListView.builder(itemBuilder: (_,index){

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: GestureDetector(

          onTap: (){
            if(user.uid==_lists[index].data["uid"]){
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
                                Firestore.instance.collection("posts").document(postid).collection("comment").document(_lists[index].data["id"])
                                    .delete();
                                setState(() {
                                  _lists.removeAt(index);
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
            if(user.uid==post_uploaderid){
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
                                Firestore.instance.collection("posts").document(postid).collection("comment").document(_lists[index].data["id"])
                                    .delete();
                                setState(() {
                                  _lists.removeAt(index);
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
          },
           // child: CommentCard(_lists[index].data["id"],postid)
        child: StreamBuilder(builder: (_,snap){
         return Container(  
           decoration: BoxDecoration(color: Color(0xffF9F9F9),borderRadius:BorderRadius.only(topLeft: Radius.circular(50.0),bottomLeft: Radius.circular(50.0))),

           child: !snap.hasData?Container():
           Row(
             mainAxisAlignment: MainAxisAlignment.start,
             crossAxisAlignment:  CrossAxisAlignment.center,
             children: <Widget>[
               GestureDetector(
                   onTap: (){
                     if(user.uid== _lists[index].data["uid"]){
                       Navigator.push(context,MaterialPageRoute(builder: (builder)=>Profile_activity()));
                     }else{
                       Navigator.push(context,MaterialPageRoute(builder: (builder)=>OtherUserProfile( _lists[index].data["uid"])));
                     }

                   },
                   child: Padding(
                     padding: const EdgeInsets.only(left: 10,top: 4.0,right: 4.0),
                     child: CircleAvatar(radius:20,backgroundImage:NetworkImage(snap.data["img_url"],),child: Center(child: Text(snap.data["username"].substring(0,1),style: TextStyle(color: Colors.white,fontSize:10.0),)),),
                   )),
               Column(crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.start,
                 children: <Widget>[
                   Text(snap.data["username"] +
                       "  " ,style: TextStyle(fontSize:12,color: Colors.black,fontWeight: FontWeight.bold),),
                   Text(TimeAgo.getTimeAgo(_lists[index].data["time"].millisecondsSinceEpoch),style: TextStyle(color: Colors.black,fontSize:8.0),),

                 ],),

               Flexible(child:StringFilter(text:_lists[index].data["text"])
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: GestureDetector(
                     onTap: (){
                       _textEditingController.text="@"+snap.data["username"]+" ";
                       var cursorPos = _textEditingController.selection;
                       cursorPos = new TextSelection.fromPosition(
                           new TextPosition(offset: _textEditingController.text.length));
                       _textEditingController.selection = cursorPos;
                     },
                     child: Text("Reply",style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold),)),
               )
               /* Container(child: IconButton(icon: Icon(Icons.delete), onPressed: (){
                      }),)*/
             ],
           ),
         );
        },stream: Firestore.instance.collection("users").document(_lists[index].data["uid"]).snapshots(),),
          ),
    );

  },itemCount: _lists.length,controller: _scrollController,);
}

}
