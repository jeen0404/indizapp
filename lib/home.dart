import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app/ChatPage.dart';
import 'package:flutter_app/other/BottomBarNav.dart';
import 'package:flutter_app/other/NoFollowSuggestion.dart';
import 'package:flutter_app/Post/PostCard.dart';
import 'package:flutter_app/other/suggestionfeedCard.dart';
import 'package:share/share.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';


class HomeFragment extends StatefulWidget {
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> with AutomaticKeepAliveClientMixin{


  var dbref=Firestore.instance;
  FirebaseUser user;
  PageController pageController=PageController();

  List<String> list=[];
  List<String> storey=[];
  List<String> ads=[];
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  ScrollController _scrollController=ScrollController();


  List<DocumentSnapshot> _prodeuct=[];
  var loading=true;
  var perpage=5;
  DocumentSnapshot _lastnode;


  Future<void>  _getposts() async{
    _prodeuct.clear();
    user=await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(user.uid).collection("feed").limit(perpage).orderBy("time",descending: true).getDocuments()
        .then((QuerySnapshot qn){
          if(qn.documents.length>0) {
            setState(() {
              _prodeuct = qn.documents;
            });
            _lastnode = qn.documents[qn.documents.length - 1];
          }
        });
    setState(() {
      loading=false;
    });
    return user;
  }

  var availabe=true;
  var loadmore=true;




  bool getingmoreproduct=false;
  bool _moreProductisavailabel=true;


  getmore() async {
    if(_moreProductisavailabel==false){
      return;
    }
    if (getingmoreproduct == false) {
      getingmoreproduct=true;
      await Firestore.instance.collection("users").document(user.uid).collection("feed").limit(perpage).orderBy("time",descending: true)
      .startAfterDocument(_lastnode)
          .getDocuments()
          .
      then((QuerySnapshot qn) {
        if(qn.documents.length<perpage){
          _moreProductisavailabel=false;
        }
        _prodeuct.addAll(qn.documents);
        _lastnode = qn.documents[qn.documents.length - 1];
      });
      setState(() {
      });
      getingmoreproduct=false;
    }
  }



  messagenotification(){
    FirebaseAuth.instance.currentUser()
        .then((FirebaseUser user){

      Firestore.instance.collection("users").document(user.uid).snapshots()
          .listen((DocumentSnapshot dq){

        setState(() {
          unseen_message=dq.data["unread_message"]==null?0:dq.data["unread_message"]>99?99:dq.data["unread_message"];
        });
      });
    });
  }
  var unseen_message=0;

  @override
  void initState() {
    super.initState();
    _getposts();
    messagenotification();
    firebaseCloudMessaging_Listeners();
    _scrollController.addListener((){
      double maxscroll=_scrollController.position.maxScrollExtent;
      double currentscroll=_scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if(maxscroll-currentscroll < delta){
        getmore();
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return  PageView(controller:pageController,children: <Widget>[
    Scaffold(
    backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.pink),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        leading:  GestureDetector(onTap: (){
          FirebaseDatabase.instance.reference().child("url").once().then((val){
            Share.share('Your friend has invited you to join INDIZ. Download app from here:  ${val.value}');
          });
        },child: Container(margin: EdgeInsets.all(10.0),height:25.0,width:25.0,child: Image(image: AssetImage("assets/logo.png",)))),
        title: Container(margin:EdgeInsets.all(8.0),width: 100.0,height: 25.0,child: Image(image: AssetImage("assets/indiz.png"))),
        actionsIconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          Stack(children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: IconButton(icon: Icon(Icons.label_important), onPressed: (){
                //pageController.jumpToPage(1);
                Navigator.push(context,MaterialPageRoute(builder:(builder)=>ChatPage()));
              }),
            ),
          unseen_message==0?Container():Positioned(top:10.0,right:5.0,child:Icon(Icons.swap_horizontal_circle,size:15.0,color: Colors.pink,)),
          ],)
        ],
      ),
      body: Column(
        children: <Widget>[
          Divider(height: 1.0,),
          Flexible(child:loading?Container(): LiquidPullToRefresh(child:  ListView.builder(itemBuilder:(_,index){
            if(_prodeuct.length==0){
              return Column(
                children: <Widget>[
                  NoFollowSuggestion(),
                  Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                            onTap: (){
                              _getposts();
                            },
                        child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0),
                            color: Colors.blueAccent,
                            border: Border.all(color: Colors.blueAccent)
                        ),child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 8.0),
                          child: Text("Skip..",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                        )),
                      ),
                    )
                  ],),
                ],
              );
            }
            if(index==2){
            return StreamBuilder<QuerySnapshot>(builder:(_,snap){
              return Container(
                color: Color(0xffF7F9F9),
                child: !snap.hasData?Container():snap.data.documents.length==0?Container():Column(
                  children: <Widget>[
                  Divider(height: 1.0,),
                    Row(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Suggestion for you",style: TextStyle(fontWeight: FontWeight.bold),),
                      )
                    ],),
                        Container(height:210.0,
                        child:ListView.builder(itemBuilder: (_,index){
                          return SuggestionfeedCard(snap.data.documents[index].data["id"],deltete_option: true,);
                        },itemCount: snap.data.documents.length,scrollDirection: Axis.horizontal,) ,),

                    SizedBox(height: 20.0,),
                    Divider(height: 1.0,)
                  ],
                ),
              );
            },stream: Firestore.instance.collection("users").document(user.uid).collection("Suggestion").limit(30).snapshots(),);
            }
            return PostCard(_prodeuct[index].data["id"]);
          },itemCount:_prodeuct.length==0?1:_prodeuct.length,),scrollController:_scrollController,onRefresh:_getposts))
        ],
      ),
      bottomNavigationBar:BottomBarNav(0),
    ),
      ChatPage()
    ],
    );
  }
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) async{
       user = await FirebaseAuth.instance.currentUser();

      Firestore.instance.collection("users").document(user.uid)
     .updateData({
        "fcm_tocken":token,
      });
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }
}