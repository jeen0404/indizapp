import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ImagesLoding/imageload.dart';
import 'package:flutter_app/OtherUserProfile.dart';

class SuggestionfeedCard extends StatefulWidget {
  var userid;
  var dletetebutton=false;
  SuggestionfeedCard(useid,{deltete_option=false}){
    this.userid=useid;
    this.dletetebutton=deltete_option;
  }
  @override
  _SuggestionfeedCardState createState() => _SuggestionfeedCardState(userid);
}

class _SuggestionfeedCardState extends State<SuggestionfeedCard> with AutomaticKeepAliveClientMixin{
  var userid;

  FirebaseUser user;
  List<String> posts=[];

  String profile_url="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoQrCJR3WvVUX-8ZVYO2KPcv7f-nFnnd3lKdGl9zkzbI3CyYi3Bw";

  String name="---";

  String username="---";
  // ignore: non_constant_identifier_names
  bool is_verifyed=true;

  bool private=true;

  String bio="---";


  _SuggestionfeedCardState(userid){
    this.userid=userid;//other user id
  }
  getuserdata() async{
    user=await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(userid).get().then((result){
      profile_url=result.data["img_url"];
      username=result.data["username"];
      name=result.data["name"];
      is_verifyed=result.data["account_verified"];
      private=result.data["private"];
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
          f_f_text="Unfollow";
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
    var time=await DateTime.now();
    if(f_f_text=="Follow"){
      if(!private){
        setState(() {
          f_f_text="Unfollow";
        });
        await Firestore.instance.collection("users").document(userid).collection("follower").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          Firestore.instance.collection("users").document(user.uid).collection("follow").document(userid)
              .setData({
            "id":userid,
            "time":time,
          }).then((val){

          });
        });
      }
      else{
        setState(() {
          f_f_text="Requested";
        });
        await Firestore.instance.collection("users").document(userid).collection("f_request").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          Firestore.instance.collection("users").document(user.uid).collection("f_requested").document(userid)
              .setData({
            "id":userid,
            "time":time,
          }).then((val){

          });
        });
      }
    }
    else if(f_f_text=="Unfollow" ||f_f_text=="Requested" ){
      setState(() {
        f_f_text="Follow";
      });
      var user =await FirebaseAuth.instance.currentUser();
      await Firestore.instance.collection("users").document(userid).collection("f_request").document(user.uid).delete()
          .then((result){
      });

      await Firestore.instance.collection("users").document(user.uid).collection("f_requested").document(userid).delete()
          .then((result){
      });

      await Firestore.instance.collection("users").document(userid).collection("follower").document(user.uid).delete()
          .then((result){
      });
      await Firestore.instance.collection("users").document(user.uid).collection("follow").document(userid).delete()
          .then((result){
      });
    }
    else if(f_f_text=="loding.."){

    }
    Firestore.instance.collection("users").document(user.uid).collection("Suggestion").document(userid).delete();
  }


  var loding=true;
  var f_f_text="loding..";

  @override
  void initState() {
    super.initState();
    getuserdata();
    CheckFollow();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return loding==true?Container():user.uid==userid?Container():Padding(
      padding: const EdgeInsets.all(2.0),
      child:
      Container(
        decoration:BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(5.0),border: Border.all(color: Colors.black54,width:0.2)),
        child: Column(
          children: <Widget>[
            Flexible(
              child: Container(
                child: Row(mainAxisAlignment: MainAxisAlignment.end,children: <Widget>[
                  SizedBox(width: 130.0,),
                 !widget.dletetebutton?Container():GestureDetector(
                    onTap: (){
                      Firestore.instance.collection("users").document(user.uid).collection("Suggestion").document(userid).delete();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.clear,color: Colors.black26,size: 15.0
                        ,),
                    ),
                  )
          ],),
              ),
            ),
             Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context,MaterialPageRoute(builder: (builder)=>OtherUserProfile(userid)));
                    },
                    child:  ImageLoad(url: profile_url,hight: 70.0,width:70.0,),
                  ),
                ),
              ]
          ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(name,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 14.0),),
                ),
                SizedBox(height:5.0,),
                Text(username,style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 12.0),)
              ],
            ),
            SizedBox(height:10.0,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: (){

                  follow();
                },
                child: Container(height:30.0,width:120.0,decoration:BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(5.0)),
                  child: Center(child: Text(f_f_text,style: TextStyle(fontSize:12.0,color: Colors.white,fontWeight: FontWeight.bold),),),
                ),
              ),

            )
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
