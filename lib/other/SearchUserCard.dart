import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchUserCard extends StatefulWidget {
  var userid;
  SearchUserCard(useid){
    this.userid=useid;
  }
  @override
  _SearchUserCardState createState() => _SearchUserCardState(userid);
}

class _SearchUserCardState extends State<SearchUserCard> {
  var userid;

  List<String> posts=[];

  String profile_url="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoQrCJR3WvVUX-8ZVYO2KPcv7f-nFnnd3lKdGl9zkzbI3CyYi3Bw";

  String name="---";

  String username="---";
  // ignore: non_constant_identifier_names
  bool is_verifyed=true;

  bool private=true;

  String bio="---";
  // ignore: non_constant_identifier_names
  String t_follower="---";
  // ignore: non_constant_identifier_names
  String t_following="---";
  // ignore: non_constant_identifier_names
  String t_posts="---";
  // ignore: non_constant_identifier_names
  String t_likes="---";
  // ignore: non_constant_identifier_names
  String t_profile_visits="---";
  // ignore: non_constant_identifier_names
  String t_tags="---";
  // ignore: non_constant_identifier_names
  String t_close_friend="---";
  // ignore: non_constant_identifier_names
  String t_crush="---";
  // ignore: non_constant_identifier_names
  String t_secret_crush="---";


  _SearchUserCardState(userid){
    this.userid=userid;//other user id
  }
  getuserdata(){
    Firestore.instance.collection("users").document(userid).get().then((result){
      bio=result.data["bio"];
      profile_url=result.data["img_url"];
      username=result.data["username"];
      name=result.data["name"];
      is_verifyed=result.data["is_verifyed"];
      private=result.data["private"];
      t_follower=result.data["t_follower"].toString();
      t_following=result.data["t_following"].toString();
      t_posts=result.data["t_posts"].toString();
      t_tags=result.data["t_tags"].toString();
      t_following=result.data["t_following"].toString();
      t_crush=result.data["t_crush"].toString();
      t_profile_visits=result.data["t_profile_visits"].toString();
      t_secret_crush=result.data["t_secret_crush"].toString();
      t_likes=result.data["t_likes"].toString();
      t_close_friend=result.data["t_close_friend"].toString();

      setState(() {
        loding=false;
      });
    });
  }

  CheckFollow() async{
    var user =await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(userid).collection("follower").document(user.uid)
        .get().then((result){
      if(result.data!=null){
        setState(() {
          f_f_text="Following";
        });
      }
      else{
        Firestore.instance.collection("users").document(userid).collection("f_request").document(user.uid)
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
        }).catchError((e){
          setState(() {
            f_f_text="Error..";
          });

        });
      }
    }).catchError((e){
      setState(() {
        f_f_text="Error..";
      });
    });
  }



  follow() async{
    var user=await FirebaseAuth.instance.currentUser();
    var time=TimeOfDay.now().toString();
    if(f_f_text=="Follow"){
      if(!private){
        Firestore.instance.collection("users").document(userid).collection("follower").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          setState(() {
            f_f_text="Following";
          });
        });
      }
      else{
        Firestore.instance.collection("users").document(userid).collection("f_request").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          setState(() {
            f_f_text="Requested";
          });
        });
      }
    }
    else if(f_f_text=="Following"){
      Firestore.instance.collection("users").document(userid).collection("f_request").document(user.uid).delete()
          .then((result){
        setState(() {
          f_f_text="Follow";
        });
      });
    }
    else if(f_f_text=="Error.."){
      setState(() {
        f_f_text="loding..";
      });
    }
    else if(f_f_text=="loding.."){

    }
  }


  var loding=true;
  var f_f_text="loding..";

  @override
  void initState() {
    getuserdata();
    CheckFollow();
  }

  @override
  Widget build(BuildContext context) {
    return loding==true?Container(height: 100.0,child: Center(child:CircularProgressIndicator(),),):
    Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(height:40.0,width:
          40.0,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.0),
                boxShadow: [BoxShadow(color: Colors.black26,spreadRadius: 0.0,blurRadius:1.0)],
                image: DecorationImage(image: NetworkImage(profile_url),fit:BoxFit.cover)
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(name,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18.0),),
              SizedBox(height:5.0,),
              Text(username,style: TextStyle(color: Colors.black26,fontWeight: FontWeight.bold,fontSize: 12.0),)
            ],
          ),
        ),
        Expanded(child: Container()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap:(){
              follow();
            },
            child: Container(height:30.0,width: 100.0,decoration:BoxDecoration(border: Border.all(color: Colors.deepOrange,width: 1.0),borderRadius: BorderRadius.circular(2.0)),
              child: Center(child: Text(f_f_text,style: TextStyle(color: Colors.deepOrange),),),
            ),
          ),
        )
      ],

    );
  }
}

