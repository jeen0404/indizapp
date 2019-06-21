import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/ImageStudio/UploadProfilePhoto.dart';
import 'package:flutter_app/other/Post.dart';
import 'package:flutter_app/other/suggestionfeedCard.dart';
import '../profilepage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class HomeFragment extends StatefulWidget {
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}



class _HomeFragmentState extends State<HomeFragment> {


  var dbref=Firestore.instance;
  var user;


  List<String> list=[];
  List<String> storey=[];
  List<String> ads=[];

   _getposts() async{
    user=await FirebaseAuth.instance.currentUser();
    await dbref.collection("users").document(user.uid).collection("feed").getDocuments()
    .then((val){
      val.documents.forEach((snap){
        list.add(snap.data["id"]);
      });
      setState(() {
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseMessaging().getToken().then((tokan){
    print(tokan);
    });

  }

  @override
  Widget build(BuildContext context) {
    return  CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          floating: true,
            pinned: false,
            snap: false,
            expandedHeight:50.0,
          iconTheme: IconThemeData(color: Colors.pink),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 2.0,
          leading: GestureDetector(onTap:(){
          Navigator.push(context,MaterialPageRoute(builder: (builder)=>UploadProfilePhoto()));
          },child: new Icon(Icons.camera,color: Colors.black,)),
          actionsIconTheme: IconThemeData(color: Colors.black),
          title: SizedBox(
              height:25.0, child: Image.asset("assets/indiz.png")),
          actions: <Widget>[
            GestureDetector(
            onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile_activity()));
            },
            child: Container(
            height:50.0,
            width: 50.0,
              child: Icon(Icons.perm_identity,color: Colors.black,),
            ))
          ],
        ),
        SliverToBoxAdapter(
        child: Container(
        height: 80.0,
        child: ListView.builder(itemBuilder: (_,index){
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
            width: 80.0,
            height:80.0,
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Colors.blueAccent,width: 2.0)
              ),
              ),
          );
          },itemCount: 10,scrollDirection: Axis.horizontal,),
        ),
        ),

        SliverList(delegate: SliverChildBuilderDelegate((_,postion){
        return Post("asdfghjkl");
        },childCount:4)
        ),

        SliverToBoxAdapter(
          child: Container(
            height: 200.0,
            child: ListView.builder(itemBuilder: (_,index){
              return   SuggestionfeedCard("B8d2OnmG1oP9eNj8so1emtGVZi93");
            },itemCount: 10,scrollDirection: Axis.horizontal,),
          ),
        ),
        SliverList(delegate: SliverChildBuilderDelegate((_,postion){
        },childCount:4)
        ),
      ],
    );
  }
}

