import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/OtherUserProfile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:time_ago_provider/time_ago_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pinch_zoom_image/pinch_zoom_image.dart';

import 'ImagesLoding/imageload.dart';

class Messages extends StatefulWidget {
  var other_user_id;
  Messages(id){
    this.other_user_id=id;
  }
  @override
  _MessagesState createState() => _MessagesState(this.other_user_id);
}

class _MessagesState extends State<Messages> with AutomaticKeepAliveClientMixin{
  var other_user_id;
  _MessagesState(id) {
    this.other_user_id = id;
  }
  var loding=true;

  List<String> posts=[];

  String profile_url="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoQrCJR3WvVUX-8ZVYO2KPcv7f-nFnnd3lKdGl9zkzbI3CyYi3Bw";
  String m_profile_url="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoQrCJR3WvVUX-8ZVYO2KPcv7f-nFnnd3lKdGl9zkzbI3CyYi3Bw";

  FirebaseUser user;

  String name="";
  String username="";
  String chat_id;

  String m_name="";
  String m_username="";
  var per_page=20;

  ScrollController _scrollController=ScrollController();
  var message="";
  var image;


  getuserdata() async{

    await Firestore.instance.collection("users").document(other_user_id).get()
        .then((DocumentSnapshot dq){
      // m_=dq.data["private"];
      profile_url=dq.data["img_url"];
      name=dq.data["name"];
      username=dq.data["username"];
    });
    setState(() {
    });
    user= await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(user.uid).get()
        .then((DocumentSnapshot dq){
      m_profile_url=dq.data["img_url"];
      m_name=dq.data["name"];
      m_username=dq.data["username"];
    });
    Firestore.instance.collection("users").document(user.uid).collection("chat").document(other_user_id)
    .updateData({"unseen_message":0});

    checkChat();
  }



  var _storageref=FirebaseStorage.instance;

  uploadimage(var img) async{
    var user= await FirebaseAuth.instance.currentUser();
    var pushid=FirebaseDatabase.instance.reference().push().key;
    var ref=_storageref.ref().child("chating").child(chat_id).child(user.uid).child(pushid+".jpg");
    final StorageUploadTask uploadTask = ref.putFile(img);
    final StorageTaskSnapshot downloadUrl =
    (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    _sendmessage("Photo",image: url,type:1);
  }


  checkChat() async{
    await Firestore.instance.collection("users").document(user.uid).collection("chat").document(other_user_id)
        .get().then((result){
      if(result.data!=null){
        setState(() {
          chat_id=result.data["id"];
        });
      }
      else{
      }
    });
  }


  _sendmessage(String taxt,{type=0,String image=""}) async{
    {
      print("wait.........");
      var time=await DateTime.now();
      if(taxt.length > 0){
        if(chat_id != null) {
          var pushid =FirebaseDatabase.instance.reference().push().key;
          await Firestore.instance.collection("chats").document(chat_id).collection("chat")
              .document(pushid).setData({
            "pushid":pushid,
            "s_id":user.uid,
            "r_id":other_user_id,
            "message":taxt,
            "time":time,
            "image":image,
            "type":type,
            "seen":false,
          }).then((result){
            Firestore.instance.collection("users").document(user.uid).collection("chat").document(other_user_id)
                .updateData({
              "last_message":taxt,
              "last_message_time":time,
            }).then((result){
              Firestore.instance.collection("users").document(other_user_id).collection("chat").document(user.uid)
                  .updateData({
                "last_message":taxt,
                "last_message_time":time,
              }).then((result){
              });
            });
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }).catchError((error){
            print(error.toString());
          });
        }
        else{
          chat_id=FirebaseDatabase.instance.reference().push().key;
          await Firestore.instance.collection("users").document(user.uid).collection("chat").document(other_user_id)
              .setData({
            "id":chat_id,
            "last_message":taxt,
            "last_message_time":time,
            "s_id":other_user_id,
          }).then((result){
            Firestore.instance.collection("users").document(other_user_id).collection("chat").document(user.uid)
                .setData({
              "id":chat_id,
              "last_message":taxt,
              "last_message_time":time,
              "s_id":user.uid,
            }).then((result){
              _sendmessage(taxt);
            });

          });
        }
      }
    }
  }

  var f_f_text="loading";
  var f_f_text2="loading";
  CheckFollow() async{
    var user =await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(other_user_id).collection("follower").document(user.uid)
        .get().then((result){
      if(result.data!=null){
        setState(() {
          f_f_text="Unfollow";
        });
      }
      else{
        Firestore.instance.collection("users").document(other_user_id).collection("f_request").document(user.uid)
            .get().then((result){
          if(result.data!=null){
            setState(() {
              f_f_text="Requested";
            });
          }else{
            setState(() {
              f_f_text="Follow";
            });
          }
        });
      }
    });
    print(f_f_text);
  }
  CheckFollow2() async{
    var user =await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(user.uid).collection("follower").document(other_user_id)
        .get().then((result){
      if(result.data!=null){
        setState(() {
          f_f_text2="Unfollow";
        });
      }
      else{
        Firestore.instance.collection("users").document(user.uid).collection("f_request").document(other_user_id)
            .get().then((result){
          if(result.data!=null){
            setState(() {
              f_f_text2="Requested";
            });
          }else{
            setState(() {
              f_f_text2="Follow";
            });
          }
        });
      }
    });
    print(f_f_text2);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserdata();
    CheckFollow();
    CheckFollow2();

    _scrollController.addListener((){
      double maxscroll=_scrollController.position.minScrollExtent;
      double currentscroll=_scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if(currentscroll-maxscroll <= delta){
       setState(() {
         per_page=per_page+10;
       });
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
        appBar:AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(icon: Icon(Icons.keyboard_backspace,color: Colors.black,), onPressed: (){
            Navigator.pop(context);
          }),
          title: GestureDetector(
              onTap: (){
                if(user.uid== other_user_id){
                  Navigator.push(context,MaterialPageRoute(builder: (builder)=>other_user_id));
                }else{
                  Navigator.push(context,MaterialPageRoute(builder: (builder)=>OtherUserProfile( other_user_id)));
                }
                },
              child: Text(username,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
          actions: <Widget>[
            GestureDetector(
              onTap: (){
                if(user.uid== other_user_id){
                  Navigator.push(context,MaterialPageRoute(builder: (builder)=>other_user_id));
                }else{
                  Navigator.push(context,MaterialPageRoute(builder: (builder)=>OtherUserProfile( other_user_id)));
                }
              },
              child: Container(height: 30.0,width:55.0,child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ImageLoad(url: profile_url,hight:30,width:30.0,),
              ),),
            )
          ],
        ) ,
        body:Column(
          children: <Widget>[
            Flexible(child:  StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("chats").document(chat_id).collection("chat").orderBy("time").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)return Column(children: <Widget>[Center(child: CircularProgressIndicator(),)],);
                return _buildList(context, snapshot.data.documents);
              },
            ),),
            Divider(height: 1.0,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical:8.0),
              child: f_f_text=="Unfollow" && f_f_text2=="Unfollow"?
              Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: (){
                        showDialog(context: context,builder: (BuildContext contaxt){
                          return   AlertDialog(
                            content: Container(
                              height: 80.0,
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      IconButton(icon: Icon(Icons.sd_storage), onPressed: () async {
                                        var image = await ImagePicker.pickImage(source: ImageSource.gallery,maxHeight:1000.0,maxWidth:1000.0 );
                                        Navigator.pop(context);
                                        uploadimage(image);
                                      }),
                                      Text("Gallery")
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      IconButton(icon: Icon(Icons.camera), onPressed: () async {
                                        var image = await ImagePicker.pickImage(source: ImageSource.camera,maxHeight:1000.0,maxWidth:1000.0);
                                        Navigator.pop(context);
                                        uploadimage(image);
                                      }),
                                      Text("camera")
                                    ],
                                  ),
                                ],),
                            ),
                          );
                        }
                        );
                      }
                   ,child:Padding(
                     padding: const EdgeInsets.all(4.0),
                     child: Icon(Icons.camera,color: Colors.black54),
                   )),
                  Flexible(child:  Container(
                    height: 40.0,
                    decoration: BoxDecoration(color: Color(0xffF0F0F0),
                     //   border: Border.all(color: Colors.black45,width: 1.0,),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),

                      child: TextField(
                        decoration: InputDecoration.collapsed(hintText: "send a message",),
                        controller: _textEditingController,
                        onSubmitted: _handalesubmited,
                        onChanged:(val)=> _scrollController.jumpTo(_scrollController.position.maxScrollExtent),
                      ),
                    ),
                  ),),
                  Container(
                    child:GestureDetector(onTap: (){
                      _handalesubmited(_textEditingController.text);
                    },child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.send),
                    )),
                  )
                ],
              ):f_f_text=="loading"?Container(): Container(
                height: 50.0,
                child:  Center(child: Text(f_f_text=="Follow"?"It seems.. you are not following ${name}":f_f_text2=="Follow"?"It seems.. ${name} is not following you":"Something Went Wrong..",),)
              ),
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
      if(snapshot[index].data["s_id"]==user.uid){

        if(snapshot[index].data["type"]==1){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        showDialog(context: context,builder: (BuildContext contaxt){
                          return    AlertDialog(content: Container(
                            height:40.0,
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);
                                    Firestore.instance.collection("chats").document(chat_id).collection("chat").document(snapshot[index].data["pushid"]).delete();
                                  },
                                  child:   Material( // needed
                                    color: Colors.white,
                                    child: InkWell(
                                      highlightColor: Colors.black12,
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text("Unsend",style: TextStyle(fontSize:16.0,fontWeight: FontWeight.bold),),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          );
                        });
                      },
                      child: PinchZoomImage(image:Image.network(snapshot[index].data["image"],height: 250.0,width: 200.0,fit: BoxFit.cover,)),
                      /*Container(
                        width: 200.0,
                        height: 250.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey,width: 0.5),
                          image: DecorationImage(image: NetworkImage(snapshot[index].data["image"]),fit: BoxFit.cover)
                        ),
                      ),*/
                    )
                  ],
                ),
              ),
              snapshot[index].data["seen"]==null?Container():snapshot[index].data["seen"]?Icon(Icons.done_all,color: Colors.blue,size: 8.0,):Icon(Icons.check,size:8.0,),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10.0,right: 10.0),
              width:MediaQuery.of(context).size.width/1.3
              ,child:
            GestureDetector(
              onTap: (){
                showDialog(context: context,builder: (BuildContext contaxt){
                  return   AlertDialog(content: Container(
                    height:40.0,
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                            Firestore.instance.collection("chats").document(chat_id).collection("chat").document(snapshot[index].data["pushid"]).delete();
                          },
                          child:   Material( // needed
                            color: Colors.white,
                            child: InkWell(
                              highlightColor: Colors.black12,
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text("Unsend",style: TextStyle(fontSize:16.0,fontWeight: FontWeight.bold),),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  );
                });
              },
              child: Container(decoration: BoxDecoration(borderRadius:BorderRadius.only(bottomLeft: Radius.circular(10.0),
                  topLeft: Radius.circular(10.0),bottomRight: Radius.circular(10.0)
              ),
                  //border: Border.all(color: Colors.black12,width: 1.0)
                color:  Color(0xffF0F0F0),
              ),child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20.0),
                child: Text(snapshot[index].data["message"],style: TextStyle(color: Colors.black,fontSize: 18.0),),
              )),
            ),alignment: Alignment.centerRight,),
            Row(mainAxisAlignment: MainAxisAlignment.end,crossAxisAlignment: CrossAxisAlignment.center,children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    right: 10.0),
                child: Text(TimeAgo.getTimeAgo(snapshot[index].data["time"].millisecondsSinceEpoch),style: TextStyle(fontSize:6.0),),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0,right: 20.0,bottom: 8.0),
                child: snapshot[index].data["seen"]==null?Container():snapshot[index].data["seen"]?Icon(Icons.done_all,color: Colors.blue,size:8.0,):Icon(Icons.check,size: 8.0,),
              ),
            ],)

          ],
        );
      }


      else{
        Firestore.instance.collection("chats").document(chat_id).collection("chat")
            .document(snapshot[index].data["pushid"]).updateData({"seen":true});
        if(snapshot[index].data["type"]==1){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:  PinchZoomImage(image:Image.network(snapshot[index].data["image"],height: 250.0,width: 200.0,fit: BoxFit.cover,))
                  )
                ],
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 25.0,),
            Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: ImageLoad(url: profile_url,hight:30,width:30.0,),
                ),

                Container(
                  margin: EdgeInsets.only(left: 10.0),
                  width: MediaQuery.of(context).size.width/1.3
                  ,child:
                Container(decoration: BoxDecoration(
      borderRadius:BorderRadius.only(bottomLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),bottomRight: Radius.circular(10.0)
                ),
                    border: Border.all(color: Colors.black12,width: 1.0)
      ),child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20.0),
                  child: Text(snapshot[index].data["message"],style: TextStyle(fontSize: 18.0),),
                )),alignment: Alignment.centerLeft,),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(TimeAgo.getTimeAgo(snapshot[index].data["time"].millisecondsSinceEpoch),style: TextStyle(fontSize:6.0),),
            ),
           ],
        );
      }
    },itemCount: snapshot.length,controller: _scrollController,);

  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
