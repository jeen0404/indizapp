import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/OtherUserProfile.dart';

class list_card extends StatefulWidget {
  var userid;
  list_card(useid){
    this.userid=useid;
  }
  @override
  _list_cardState createState() => _list_cardState(userid);
}

class _list_cardState extends State<list_card> with AutomaticKeepAliveClientMixin{
  var userid;

  List<String> posts=[];

  String profile_url="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoQrCJR3WvVUX-8ZVYO2KPcv7f-nFnnd3lKdGl9zkzbI3CyYi3Bw";
  String name="---";

  String username="---";
  // ignore: non_constant_identifier_names
  bool is_verifyed=true;

  bool private=false;

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

  String crush_text="loding...";
  String S_crush_text="loding...";


  _list_cardState(userid){
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
    var time=TimeOfDay.now().toString();
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

  addtoCrush() async{
    Navigator.pop(context);
    var user=await FirebaseAuth.instance.currentUser();
    var time=TimeOfDay.now().toString();

    if(crush_text=="Add to Crush list"){
      if(!private){
        setState(() {
          crush_text="Remove From Crush List";
        });
        await Firestore.instance.collection("users").document(userid).collection("crush_on_you").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          Firestore.instance.collection("users").document(user.uid).collection("crush").document(userid)
              .setData({
            "id":userid,
            "time":time,
          }).then((val){

          });
        });
      }
      else{
        setState(() {
          crush_text="Requested";
        });
        await Firestore.instance.collection("users").document(userid).collection("crush_on_you_request").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          Firestore.instance.collection("users").document(user.uid).collection("crush_requested").document(userid)
              .setData({
            "id":userid,
            "time":time,
          }).then((val){

          });
        });
      }
    }

    else if(crush_text=="Remove From Crush List" ||crush_text=="Requested" ){
      setState(() {
        crush_text="Add to Crush list";
      });
      var user =await FirebaseAuth.instance.currentUser();
      await Firestore.instance.collection("users").document(userid).collection("crush_on_you").document(user.uid).delete()
          .then((result){
      });

      await Firestore.instance.collection("users").document(user.uid).collection("crush").document(userid).delete()
          .then((result){
      });

      await Firestore.instance.collection("users").document(userid).collection("crush_on_you_request").document(user.uid).delete()
          .then((result){
      });
      await Firestore.instance.collection("users").document(user.uid).collection("crush_requested").document(userid).delete()
          .then((result){
      });
    }
  }

  addtoSecretCrush() async{
    Navigator.pop(context);
    var user=await FirebaseAuth.instance.currentUser();
    var time=TimeOfDay.now().toString();
    if(S_crush_text=="Add to SecreteCrush"){
        setState(() {
          S_crush_text="Remove From SecreteCrush";
        });
        await Firestore.instance.collection("users").document(user.uid).collection("SecreteCrush").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        });
    }
    else if(S_crush_text=="Remove From SecreteCrush"){
      setState(() {
        S_crush_text="Add to SecreteCrush";
      });
      var user =await FirebaseAuth.instance.currentUser();
      await Firestore.instance.collection("users").document(user.uid).collection("SecreteCrush").document(user.uid).delete()
          .then((result){
      });
    }
  }

  CheckCrush() async{
    var user =await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(userid).collection("crush_on_you").document(user.uid)
        .get().then((result){
      if(result.data!=null){
        setState(() {
          crush_text="Remove From Crush List";
        });
      }else{
        Firestore.instance.collection("users").document(userid).collection("crush_on_you_request").document(user.uid)
            .get().then((result){
          if(result.data!=null){
            setState(() {
              crush_text="Requested";
            });
          }
          else{
            setState(() {
              crush_text="Add to Crush list";
            });
          }
        }).catchError((error){
          setState(() {
            crush_text="Error";
          });
        });
      }
    }).catchError((e){
      setState(() {
        crush_text="Error";
      });
    });
  }

  CheckSecretCrush() async{
    var user =await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(user.uid).collection("secret_crush").document(user.uid)
        .get().then((result){
      if(result.data!=null){
        setState(() {
          S_crush_text="Remove From SecreteCrush";
        });
      }else{
        setState(() {
          S_crush_text="Add to SecreteCrush";
        });
      }
    }).catchError((e){
      setState(() {
        S_crush_text="Add to SecreteCrush";
      });
    });
  }




  var loding=true;
  var f_f_text="loding..";

  @override
  void initState() {
   // getuserdata();
    CheckFollow();
    CheckCrush();
    CheckSecretCrush();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(builder:(_,snap){
      return Container(
        height:70.0,
        child: !snap.hasData?Center(child: CircularProgressIndicator(),)
            :PageView(children: <Widget>[
         Column(children: <Widget>[
           GestureDetector(
             onTap: (){
               Navigator.push(context,MaterialPageRoute(builder: (builder)=>OtherUserProfile(userid)));
             },
             child: Row(
               children: <Widget>[
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: CircleAvatar(backgroundImage: NetworkImage(snap.data.data["img_url"],),
                     radius:25.0,
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.only(left:15.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: <Widget>[
                       Text(snap.data.data["name"],style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18.0),),
                       SizedBox(height:5.0,),
                       Text(snap.data.data["username"],style: TextStyle(color: Colors.black26,fontWeight: FontWeight.bold,fontSize: 12.0),)
                     ],
                   ),
                 ),
                 Expanded(child: Container()),
                 IconButton(icon: Icon(Icons.keyboard_backspace,color: Colors.black45,), onPressed: null)
               ],
             ),
           ),
         //  Divider(height: 1.0,)
          ],),
          Column(children: <Widget>[

            Row(
              children: <Widget>[

                IconButton(icon: Icon(Icons.chevron_left), onPressed: null),

                Flexible(child:Container(
                  height:66.0,
                  child: Center(
                    child: GestureDetector(
                      onTap: (){
                        follow();
                      },
                      child: Container(
                        margin: EdgeInsets.all(5.0),
                        height: 40.0,
                        width: 250.0,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0),color: Colors.blueAccent)
                        ,child: Center(child: Text(f_f_text,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),)),
                    ),
                  ),
                )),

                IconButton(icon: Icon(Icons.more_vert), onPressed: (){
                  showDialog(barrierDismissible: true,context: context,builder: (BuildContext contaxt){
                    return   AlertDialog(content: Container(
                      height: 230.0,
                      child: Column(
                        children: <Widget>[
                          Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                            CircleAvatar(radius: 30.0,backgroundImage: NetworkImage(snap.data.data["img_url"],))
                          ],),
                          Column(
                            children: <Widget>[
                              Text(snap.data.data["name"],style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18.0),),
                              Text(snap.data.data["username"],style: TextStyle(color: Colors.black26,fontWeight: FontWeight.bold,fontSize: 12.0),)
                            ],
                          ),
                          SizedBox(height: 15.0,),
                          Divider(height: 1.0,),
                          Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                            GestureDetector(
                              onTap: (){
                                addtoCrush();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Center(child: Text(crush_text)),
                              ),
                            )
                          ],),
                          Divider(height: 1.0,),
                          Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                            GestureDetector(
                              onTap: (){
                                addtoSecretCrush();
                              },
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Center(child: Text(S_crush_text,),)
                              ),
                            )
                          ],),
                          Divider(height: 1.0,),
                          Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                            GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Center(child: Text("Cancel",),)
                              ),
                            )
                          ],),


                        ],
                      ),
                    ),
                    );
                  }
                  );
                }),
                //IconButton(icon: Icon(Icons.delete), onPressed:(){})
              ],
            ),
          //  Divider(height: 1.0,)
          ],)
        ],),
      );
    },stream: Firestore.instance.collection("users").document(userid).snapshots(),);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

