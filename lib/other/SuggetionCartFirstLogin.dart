import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/OtherUserProfile.dart';

class SuggestionCartForFirstLogin extends StatefulWidget {
  var userid;
  SuggestionCartForFirstLogin(useid){
    this.userid=useid;
  }
  @override
  _SuggestionCartForFirstLoginState createState() => _SuggestionCartForFirstLoginState(userid);
}

class _SuggestionCartForFirstLoginState extends State<SuggestionCartForFirstLogin> with AutomaticKeepAliveClientMixin{
  var userid;

  List<String> posts=[];

  String profile_url="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoQrCJR3WvVUX-8ZVYO2KPcv7f-nFnnd3lKdGl9zkzbI3CyYi3Bw";

  String name="---";

  String username="---";
  // ignore: non_constant_identifier_names
  bool is_verifyed=true;

  bool private=true;

  String bio="---";

  FirebaseUser user;


  _SuggestionCartForFirstLoginState(userid){
    this.userid=userid;//other user id
  }
  getuserdata() async{
    user=await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(userid).get().then((result){
      bio=result.data["bio"];
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
     user =await FirebaseAuth.instance.currentUser();
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
    return   loding==true?Container(height: 200.0,child:Center(child:Container(width:20.0,child: LinearProgressIndicator(backgroundColor:Colors.white,)),),):
    user.uid==userid?Container():Container(
        height:200.0,
        width: 140.0,
        decoration: BoxDecoration(
          //   border: Border.all(color: Colors.blueAccent,width: 1.0),
            borderRadius: BorderRadius.circular(5.0)
            ,image:   DecorationImage(image: NetworkImage(profile_url),fit:BoxFit.cover)
        ),
        child:Container(
          decoration:BoxDecoration(color: Colors.black54,borderRadius: BorderRadius.circular(5.0)),
          child: Column(

            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context,MaterialPageRoute(builder: (builder)=>OtherUserProfile(userid)));
                        },
                        child: Container(height:50.0,width:50.0,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                              border: Border.all(color: Colors.white,width: 1.0),
                              boxShadow: [BoxShadow(color: Colors.black26,spreadRadius: 0.0,blurRadius:1.0)],
                              image: DecorationImage(image: NetworkImage(profile_url),fit:BoxFit.cover)
                          ),
                        ),
                      ),
                    ),
                  ]
              ),
              SizedBox(height:45.0,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  is_verifyed==true? Icon(Icons.verified_user,color: Colors.white70,size:15.0,):Container(),
                  Text(name,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18.0),),
                  SizedBox(height:5.0,),
                  Text(username,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12.0),)
                ],
              ),
              SizedBox(height:20.0,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: (){
                    follow();
                  },
                  child: Container(height:30.0,width: 100.0,decoration:BoxDecoration(border: Border.all(color: Colors.white,width: 1.0),borderRadius: BorderRadius.circular(2.0)),
                    child: Center(child: Text(f_f_text,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),),
                  ),
                ),

              )
            ],
          ),
        )
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
