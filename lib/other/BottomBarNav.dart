
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Notification.dart';
import 'package:flutter_app/SearchPage.dart';
import 'package:flutter_app/UploadPost.dart';
import 'package:flutter_app/home.dart';
import 'package:flutter_app/profilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class BottomBarNav extends StatefulWidget {
  var index;
  BottomBarNav(index){
    this.index=index;
  }

  @override
  _BottomBarNavState createState() => _BottomBarNavState();
}

class _BottomBarNavState extends State<BottomBarNav> {


  notification(){
     FirebaseAuth.instance.currentUser()
        .then((FirebaseUser user){
          fuser=user;
          print("----------------------------------------------");
          print(user.uid);
        Firestore.instance.collection("users").document(user.uid).snapshots()
       .listen((DocumentSnapshot dq){
         print(dq.data);

         setState(() {
           if(dq.data["unseen_notification"]>99){
             nf_value=99;
           }
           else{
             nf_value=dq.data["unseen_notification"];
           }
         });
       });
    });
  }
  var nf_value=0;

FirebaseUser fuser;
  @override
  void initState() {
    // TODO: implement initState
    notification();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      child: Column(
        children: <Widget>[
          Divider(height: 1.0,),
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.home,color:widget.index==0?Colors.black:Colors.black26,), onPressed: () {
            if(widget.index==0){
              return 0;
            }
            Navigator.push(context, MaterialPageRoute(builder: (builder)=>HomeFragment()));
          },
          ),
          IconButton(
            icon: Icon(Icons.search,color:widget.index==1?Colors.black:Colors.black26,),onPressed: () {
            if(widget.index==1){
              return 0;
            }
            Navigator.push(context, MaterialPageRoute(builder: (builder)=>SearchPage()));
          },
          ),
          IconButton(
            icon: Icon(Icons.add,color:widget.index==2?Colors.black:Colors.black26,),onPressed: () {
            if(widget.index==2){
              return 0;
            }
            Navigator.push(context, MaterialPageRoute(builder: (builder)=>UploadPost()));
          },
          ),
          Stack(children: <Widget>[
            Positioned(top: 2.0,right:2.0,child:
            nf_value==0?Container():Container(
                decoration: BoxDecoration( color:Colors.blueAccent,shape: BoxShape.circle),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(nf_value.toString(),style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                ))
            ),


            IconButton(
              icon: Icon(Icons.notifications_none,color:widget.index==3?Colors.black:Colors.black26,),onPressed: () {
              if(widget.index==3){
                return 0;
              }
              Navigator.push(context, MaterialPageRoute(builder: (builder)=>Natification()));
              Firestore.instance.collection("users").document(fuser.uid).updateData({
                "unseen_notification":0,
              });
            },
            ),
          ],),
          IconButton(
            icon: Icon(Icons.perm_identity,color:widget.index==4?Colors.black:Colors.black26,),onPressed: () {
              if(widget.index==4){
                return 0;
              }
            Navigator.push(context, MaterialPageRoute(builder: (builder)=>Profile_activity()));
          },
          ),
        ],
      )
        ],
      ),
    );
  }
}

/*
   case 0 : Navigator.push(context, MaterialPageRoute(builder: (builder)=>HomeFragment()));break;
          case 1 : Navigator.push(context, MaterialPageRoute(builder: (builder)=>SearchPage()));break;
          case 2 : Navigator.push(context, MaterialPageRoute(builder: (builder)=>UploadPost()));break;
          case 3 : Navigator.push(context, MaterialPageRoute(builder: (builder)=>HomeFragment()));break;
          case 4 : Navigator.push(context, MaterialPageRoute(builder: (builder)=>ChatPage()));break;

 */