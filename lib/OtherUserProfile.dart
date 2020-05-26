
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ImagesLoding/imageload.dart';
import 'package:flutter_app/Messages.dart';
import 'package:flutter_app/Post/ImageView.dart';
import 'package:flutter_app/Post/PostList.dart';
import 'package:flutter_app/algo/StringFilter.dart';
import 'package:flutter_app/other/suggestionfeedCard.dart';
import 'listforotheruser/CrushListForOtherUser.dart';
import 'listforotheruser/CrushOnYouListForOtheruser.dart';
import 'listforotheruser/FollowListForOtherUser.dart';
import 'listforotheruser/FollowerListForOtherUser.dart';
import 'package:flutter_app/Post/PostCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase/Firebase.dart';


class OtherUserProfile extends StatefulWidget {
  var otheruserid;
  OtherUserProfile(var id){
    this.otheruserid=id;
  }
  @override
  _OtherUserProfileState createState() => _OtherUserProfileState(otheruserid);
}

class _OtherUserProfileState extends State<OtherUserProfile> with AutomaticKeepAliveClientMixin {

  var otheruserid;
  _OtherUserProfileState(var id){
    this.otheruserid=id;
  }


  getprofiledatafromfirebase() async {
    user=await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(otheruserid).get().then((result){
     print(result.data);
     print("----------------------------------------------------------------------");
      bio=result.data["bio"];
      profile_url=result.data["img_url"];
      username=result.data["username"];
      uid=result.data["uid"];
      gender=result.data["gender"];
      name=result.data["name"];
      is_verifyed=result.data["account_verified"];
      private=result.data["private"];
      t_follower=result.data["t_follower"].toString();
      t_following=result.data["t_following"].toString();
      t_posts=result.data["t_posts"].toString();
     t_crush_on_you=result.data["t_crush_on_you"].toString();
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
     CheckFollow();
     CheckCrush();
     CheckSecretCrush();
    }).catchError((e){
      print(e.message);
      return;
    });
  }
  
  addVisiters() async{

    FirebaseUser user=await FirebaseAuth.instance.currentUser();
    if(user.uid!=otheruserid){
      var time=await DateTime.now();
      var push_id=await FirebaseDatabase.instance.reference().push().key;
      await Firestore.instance.collection("users").document(otheruserid).collection("profile_visits")
          .document(push_id).setData({
        "id":user.uid,
        "time":time,
        "push_id":push_id,
      });
    }

    
  }


  CheckFollow() async{
    var user =await FirebaseAuth.instance.currentUser();
   await Firestore.instance.collection("users").document(otheruserid).collection("follower").document(user.uid)
        .get().then((result){
      if(result.data!=null){
        setState(() {
          f_f_text="Message";
        });
      }
      else{
        Firestore.instance.collection("users").document(otheruserid).collection("f_request").document(user.uid)
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

   await _getpostsList();
  }

  follow() async{
    var user=await FirebaseAuth.instance.currentUser();
    var time=TimeOfDay.now().toString();
    if(f_f_text=="Follow"){
      if(!private){
        setState(() {
          f_f_text="Message";
        });
        await Firestore.instance.collection("users").document(otheruserid).collection("follower").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          Firestore.instance.collection("users").document(user.uid).collection("follow").document(otheruserid)
              .setData({
            "id":otheruserid,
            "time":time,
          }).then((val){

          });
        });
      }
      else{
        setState(() {
          f_f_text="Requested";
        });
        await Firestore.instance.collection("users").document(otheruserid).collection("f_request").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          Firestore.instance.collection("users").document(user.uid).collection("f_requested").document(otheruserid)
              .setData({
            "id":otheruserid,
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
      await Firestore.instance.collection("users").document(otheruserid).collection("f_request").document(user.uid).delete()
          .then((result){
      });

      await Firestore.instance.collection("users").document(user.uid).collection("f_requested").document(otheruserid).delete()
          .then((result){
      });

      await Firestore.instance.collection("users").document(otheruserid).collection("follower").document(user.uid).delete()
          .then((result){
      });
      await Firestore.instance.collection("users").document(user.uid).collection("follow").document(otheruserid).delete()
          .then((result){
      });
    }
    else if(f_f_text=="loding.."){

    }  else if(f_f_text=="Message"){
      Navigator.push(context,MaterialPageRoute(builder: (builder)=>Messages(otheruserid)));

    }
  }

  unfollow() async{
    setState(() {
      f_f_text="Follow";
    });
    var user =await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(otheruserid).collection("f_request").document(user.uid).delete()
        .then((result){
    });

    await Firestore.instance.collection("users").document(user.uid).collection("f_requested").document(otheruserid).delete()
        .then((result){
    });

    await Firestore.instance.collection("users").document(otheruserid).collection("follower").document(user.uid).delete()
        .then((result){
    });
    await Firestore.instance.collection("users").document(user.uid).collection("follow").document(otheruserid).delete()
        .then((result){
    });
  }

  CheckCrush() async{
    var user =await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(otheruserid).collection("crush_on_you").document(user.uid)
        .get().then((result){
      if(result.data!=null){
        setState(() {
          crush_text="Remove From Crush List";
        });
      }else{
        Firestore.instance.collection("users").document(otheruserid).collection("crush_on_you_request").document(user.uid)
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

  addtoCrush() async{
    var user=await FirebaseAuth.instance.currentUser();
    var time=await DateTime.now();
    if(crush_text=="Add to Crush list"){
      if(!private){
        setState(() {
          crush_text="Remove From Crush List";
        });
        await Firestore.instance.collection("users").document(otheruserid).collection("crush_on_you").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          Firestore.instance.collection("users").document(user.uid).collection("crush").document(otheruserid)
              .setData({
            "id":otheruserid,
            "time":time,
          }).then((val){
          });
        });
      }
      else{
        setState(() {
          crush_text="Requested";
        });
        await Firestore.instance.collection("users").document(otheruserid).collection("crush_on_you_request").document(user.uid)
            .setData({
          "id":user.uid,
          "time":time,
        }).then((val){
          Firestore.instance.collection("users").document(user.uid).collection("crush_requested").document(otheruserid)
              .setData({
            "id":otheruserid,
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
      await Firestore.instance.collection("users").document(otheruserid).collection("crush_on_you").document(user.uid).delete()
          .then((result){
      });
      await Firestore.instance.collection("users").document(user.uid).collection("crush").document(otheruserid).delete()
          .then((result){
      });
      await Firestore.instance.collection("users").document(otheruserid).collection("crush_on_you_request").document(user.uid).delete()
          .then((result){
      });
      await Firestore.instance.collection("users").document(user.uid).collection("crush_requested").document(otheruserid).delete()
          .then((result){
      });
    }
  }

  CheckSecretCrush() async{
    var user =await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(user.uid).collection("secret_crush").document(otheruserid)
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

  addtoSecretCrush() async{
    var user=await FirebaseAuth.instance.currentUser();
    var time=await DateTime.now();
    if(S_crush_text=="Add to SecreteCrush"){
      setState(() {
        S_crush_text="Remove From SecreteCrush";
      });
      await Firestore.instance.collection("users").document(user.uid).collection("secret_crush").document(otheruserid)
          .setData({
        "id":otheruserid,
        "time":time,
      });
    }
    else if(S_crush_text=="Remove From SecreteCrush"){
      setState(() {
        S_crush_text="Add to SecreteCrush";
      });
      var user =await FirebaseAuth.instance.currentUser();
      await Firestore.instance.collection("users").document(user.uid).collection("secret_crush").document(otheruserid).delete()
          .then((result){
      });
    }
  }

var crush_text="Loding...";
var f_f_text="Loding...";
var S_crush_text="Loding...";

  int _per_page=5;
  List<DocumentSnapshot> _product=[];
  DocumentSnapshot _lastdocument;
  ScrollController _scrollController=ScrollController();

  _getpostsList() async{
    if(private){
      if(f_f_text=="Message"){
       return await Firestore.instance.collection("users").document(otheruserid).collection("posts").orderBy("time",descending: true).getDocuments()
            .then((QuerySnapshot qn){
          print(qn.documents[0].data["id"]);
          _lastdocument=qn.documents[qn.documents.length-1];
          setState(() {
            _product=qn.documents;
            loding=false;
          });
        });
      }else{
      return _product=[];
    }
    }
    else{
      return  await Firestore.instance.collection("users").document(otheruserid).collection("posts").orderBy("time",descending: true).getDocuments()
          .then((QuerySnapshot qn){
        print(qn.documents[0].data["id"]);
        _lastdocument=qn.documents[qn.documents.length-1];

        setState(() {
          _product=qn.documents;
          loding=false;
        });
      });
    }
  }

  bool getingmoreproduct=false;
  bool _moreProductisavailabel=true;

  _getpostsListmore() async{
    if(private){
      if(f_f_text=="Message"){
        if(_moreProductisavailabel==false){
          return 0;
        }
        if (getingmoreproduct == false) {
          getingmoreproduct=true;
          await Firestore.instance.collection("users").document(otheruserid).collection("posts").orderBy("time",descending: true).startAfter(_lastdocument.data["id"]).limit(
              _per_page)
              .getDocuments()
              .
          then((QuerySnapshot qn) {
            if(qn.documents.length<_per_page){
              _moreProductisavailabel=false;
            }
            _product.addAll(qn.documents);
            _lastdocument = qn.documents[qn.documents.length - 1];
          });
          setState(() {

          });
          getingmoreproduct=false;
        }
      }
      else{
        return _product=[];

      }

    }
     if(_moreProductisavailabel==false){
      return 0;
    }
    if (getingmoreproduct == false) {
      getingmoreproduct=true;
      await Firestore.instance.collection("users").document(otheruserid).collection("posts").orderBy("time",descending: true).startAfter(_lastdocument.data["id"]).limit(
          _per_page)
          .getDocuments()
          .
      then((QuerySnapshot qn) {
        if(qn.documents.length<_per_page){
          _moreProductisavailabel=false;
        }
        _product.addAll(qn.documents);
        _lastdocument = qn.documents[qn.documents.length - 1];
      });
      setState(() {

      });
      getingmoreproduct=false;
    }

  }

  var loding=true;
  List<String> posts=[];

  String profile_url="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoQrCJR3WvVUX-8ZVYO2KPcv7f-nFnnd3lKdGl9zkzbI3CyYi3Bw";

  String name="---";
  FirebaseUser user;

  String username="---";
  String uid="---";
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
  String t_crush_on_you="---";
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

  var gridview=true;
  //
  bool showSuggetionlist=false;

  var gender="male";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getprofiledatafromfirebase();
    addVisiters();
    _scrollController.addListener((){
      double maxscroll=_scrollController.position.maxScrollExtent;
      double currentscroll=_scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if(maxscroll-currentscroll <= delta){
        _getpostsListmore();
      }
    });

  }



  @override
  Widget build(BuildContext context) {
    super.build(context);
    return loding==true?Center(child: CircularProgressIndicator(),) :Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      body: CustomScrollView(controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Color(0xffF9F9F9),
            expandedHeight:50.0,
            floating: false,
            snap: false,
            centerTitle: true,

            iconTheme: IconThemeData(color: Colors.black),
            leading: IconButton(icon: Icon(Icons.keyboard_backspace), onPressed:(){
              Navigator.pop(context);
            }),
            title: Container(
                child: Row(
                  children: <Widget>[
                    Text(username,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                    SizedBox(width: 5.0,),
                    is_verifyed==true? Icon(Icons.verified_user,color: Colors.pink,size:14.0,):Container(),
                  ],
                )
            ),

            actions: <Widget>[
              IconButton(icon:  Icon(Icons.more_vert,), onPressed:(){
                if(user.uid==otheruserid){
                  return 0;
                }
                return showDialog(context: context,builder:
                    (builder)=>AlertDialog(content: Container(
                      height: 150.0,
                      width: 300.0,
                      child: ListView(children: <Widget>[

                        Material( // needed
                          color: Colors.white,
                          child: InkWell(
                            highlightColor: Colors.black12,
                            onTap: () {
                              Navigator.pop(context);
                              unfollow();
                            }, // needed
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text("Unfollow",style: TextStyle(fontSize:16.0,fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ),
                        ),

                        Material( // needed
                          color: Colors.white,
                          child: InkWell(
                            highlightColor: Colors.black12,
                            onTap: () {
                              addtoCrush();
                            }, // needed
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(crush_text,style: TextStyle(fontSize:16.0,fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ),
                        ),

                        Material( // needed
                          color: Colors.white,
                          child: InkWell(
                            highlightColor: Colors.black12,
                            onTap: () {
                              addtoSecretCrush();
                            }, // needed
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(S_crush_text,style: TextStyle(fontSize:16.0,fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ),
                        ),

                        Material( // needed
                          color: Colors.white,
                          child: InkWell(
                            highlightColor: Colors.black12,
                            onTap: () {
                             Navigator.pop(context);
                            }, // needed
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text("Cancel",style: TextStyle(fontSize:16.0,fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ),
                        ),


                      ],),
                    ),
                ));

              })
            ],
          ),

          SliverToBoxAdapter(
            child:Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:10.0,top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ImageLoad(url: profile_url,hight: 80.0,width:80.0,),
                         RichText(text: TextSpan(
                              children: [
                                TextSpan(text: name.substring(0,1).toUpperCase(),style: TextStyle(color: Colors.black,fontSize: 14.0,fontWeight: FontWeight.bold)),
                                TextSpan(text: name.substring(1,name.length),style: TextStyle(color: Colors.black,fontSize: 14.0,fontWeight: FontWeight.bold)),
                              ]
                          )),
                        ],
                      ),

                      SizedBox(width:10.0,),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: <Widget>[

                              Container(
                                width: 70.0,
                                child: GestureDetector(
                                  onTap: (){
                                    if(private){
                                      if(f_f_text=="Message"){
                                       return Navigator.push(context, MaterialPageRoute(builder: (builder)=>PostList(otheruserid)));
                                      }
                                      else{
                                        return 0;
                                      }
                                    }
                                    return Navigator.push(context, MaterialPageRoute(builder: (builder)=>PostList(otheruserid)));
                                  },
                                  child: Column(children: <Widget>[
                                    Text(t_posts.toString(),style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16.0)),
                                    Text("  Posts  ",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10.0)),
                                  ],),
                                ),
                              )

                              ,Container(
                                width:70.0,
                                child: GestureDetector(
                                  onTap:(){
                                    if(private){
                                      if(f_f_text=="Message"){
                                        return Navigator.push(context, MaterialPageRoute(builder: (builder)=>FollowerlistForOtherUser(otheruserid)));;
                                      }
                                      else{
                                        return 0;
                                      }
                                    }
                                   return Navigator.push(context, MaterialPageRoute(builder: (builder)=>FollowerlistForOtherUser(otheruserid)));
                                  },
                                  child: Column(children: <Widget>[
                                    Text(t_follower.toString(),style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16.0)),
                                    Text(" Follower ",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10.0)),
                                  ],),
                                ),
                              ),

                              Container(
                                width:70.0,
                                child: GestureDetector(
                                  onTap:(){
                                    if(private){
                                      if(f_f_text=="Message"){
                                        return Navigator.push(context, MaterialPageRoute(builder: (builder)=>FollowListForOtherUser(otheruserid)));;
                                      }
                                      else{
                                        return 0;
                                      }
                                    }
                                   return Navigator.push(context, MaterialPageRoute(builder: (builder)=>FollowListForOtherUser(otheruserid)));
                                  },
                                  child: Column(children: <Widget>[
                                    Text(t_following.toString(),style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16.0)),
                                    Text(" Following ",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10.0)),
                                  ],),
                                ),
                              )
                            ],),

                            SizedBox(height:10.0,),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: <Widget>[

                              Container(
                                width:70.0,
                                child: GestureDetector(
                                  onTap: (){
                                    if(private){
                                      if(f_f_text=="Message"){
                                        return Navigator.push(context, MaterialPageRoute(builder: (builder)=>CrushOnYouForOtherUser(otheruserid)));;
                                      }
                                      else{
                                        return 0;
                                      }
                                    }
                                    Navigator.push(context, MaterialPageRoute(builder: (builder)=>CrushOnYouForOtherUser(otheruserid)));
                                  },
                                  child: Column(children: <Widget>[
                                    Text(t_crush_on_you.toString(),style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16.0)),
                                    Text( gender=="male"?"Crush on Him":"Crush on Her",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10.0)),
                                  ],),
                                ),
                              )

                              ,Container(
                                width: 70.0,
                                child: GestureDetector(
                                  onTap: (){
                                    if(private){
                                      if(f_f_text=="Message"){
                                        return Navigator.push(context, MaterialPageRoute(builder: (builder)=>CrushListforotheruser(otheruserid)));;
                                      }
                                      else{
                                        return 0;
                                      }
                                    }
                                    Navigator.push(context, MaterialPageRoute(builder: (builder)=>CrushListforotheruser(otheruserid)));
                                  },
                                  child: Column(children: <Widget>[
                                    Text(t_crush.toString(),style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16.0)),
                                    Text( gender=="male"?"His Crush":"Her Crush",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10.0)),
                                  ],),
                                ),
                              ),

                              Container(
                                width: 70.0,
                                child: Column(children: <Widget>[
                                  Text(t_profile_visits.toString().toString(),style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16.0)),
                                  Text("Profile Visits",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10.0)),
                                ],),
                              )
                            ],),
                            SizedBox(height:15.0,)
                          ],),
                      )
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 8.0,right:8.0),
                  child: Row(children: <Widget>[
                    Expanded(child: Container(
                    color: Colors.white,
                        child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: StringFilter(text: bio,),
                    ))),
                  ],),
                ),

                user.uid==otheruserid?Container():Row(children: <Widget>[
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left:10.0,top: 10.0,bottom: 10.0),
                      child: GestureDetector(
                        onTap: (){
                          follow();
                        },
                        child: Container(height:40.0,
                          decoration: BoxDecoration(color: Colors.white,border: Border.all(color: Colors.black12),borderRadius:BorderRadius.circular(5.0))
                          ,child: Center(child: Text(f_f_text,style: TextStyle(fontSize:10.0,fontWeight:FontWeight.bold)),),),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left:5.0,top: 10.0,bottom: 10.0,),
                    child: GestureDetector(
                      onTap: (){
                        addtoCrush();
                      },
                      child: Container(height:40.0,
                        decoration: BoxDecoration(color: Colors.white,border: Border.all(color: Colors.black12),borderRadius:BorderRadius.circular(5.0))
                        ,child: Center(child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal:5.0),
                          child: Text(crush_text,style: TextStyle(fontSize:10.0,fontWeight:FontWeight.bold),),
                        ),),),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left:5.0,top: 10.0,bottom: 10.0),
                    child: GestureDetector(
                      onTap: (){
                        addtoSecretCrush();
                      },
                      child: Container(height:40.0,
                        decoration: BoxDecoration(color: Colors.white,border: Border.all(color: Colors.black12),borderRadius:BorderRadius.circular(5.0))
                        ,child: Center(child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(S_crush_text,style: TextStyle(fontSize:10.0,fontWeight:FontWeight.bold)),
                        ),),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0,right: 5.0),
                    child: GestureDetector(
                      onTap: (){
                        if(showSuggetionlist==true){
                          setState(() {
                            showSuggetionlist=false;
                          });
                        }
                        else{
                          setState(() {
                            showSuggetionlist=true;
                          });
                        }
                      },
                      child: Container(height:40.0,width:25.0,
                      decoration: BoxDecoration(color: Colors.white,border: Border.all(color: Colors.black12),borderRadius:BorderRadius.circular(5.0)),
                      child: Center(child: Icon(!showSuggetionlist?Icons.arrow_drop_down:Icons.arrow_drop_up,color: Colors.black,)),
                      ),
                    ),
                  )
                ],)
                //  SizedBox(height: 5.0,),
              ],
            ),
          ),



          SliverToBoxAdapter(child:showSuggetionlist?StreamBuilder<QuerySnapshot>(builder:(_,snap){
            return  !snap.hasData?Container():snap.data.documents.length==0?Container():Column(
              children: <Widget>[
                Row(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Suggestion From "+ name,style: TextStyle(fontWeight: FontWeight.bold),),
                  )
                ],),
                Container(height:200.0,
                  child:ListView.builder(itemBuilder: (_,index){
                    return SuggestionfeedCard(snap.data.documents[index].data["id"]);
                  },itemCount: snap.data.documents.length,scrollDirection: Axis.horizontal,) ,),
              ],
            );
          },stream: Firestore.instance.collection("users").document(otheruserid).collection("Suggestion").limit(20).snapshots(),):Container()),

          SliverToBoxAdapter(child: Divider(height: 1.0,),),

          SliverToBoxAdapter(child:  Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: <Widget>[
            IconButton(icon: Icon(Icons.pages,color: Colors.black,), onPressed: (){
              if(gridview==false){
                setState(() {
                  gridview=true;
                });
              }


            }),
            IconButton(icon: Icon(Icons.menu), onPressed: (){
              if(gridview==true){
                setState(() {
                  gridview=false;
                });
              }

            }),
          ],),),

          SliverToBoxAdapter(child: Row(mainAxisAlignment: gridview?MainAxisAlignment.start:MainAxisAlignment.end,children: <Widget>[
            Container(height:4.0,color: Colors.black12,width: MediaQuery.of(context).size.width/2,)
          ],),),


          SliverToBoxAdapter(child: Divider(height: 1.0,),),
          gridview?SliverGrid(delegate:SliverChildBuilderDelegate((_,index){
            return Padding(
              padding: const EdgeInsets.all(0.3),
              child: PostImageView(_product[index].data["id"],index: index,),
            );
          },childCount:_product.length), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3))
          :SliverList(delegate:SliverChildBuilderDelegate((_,index){
            return Padding(
              padding: const EdgeInsets.all(0.3),
              child: PostCard(_product[index].data["id"]),
            );
          },childCount:_product.length)),

          SliverToBoxAdapter(child:private?f_f_text=="Follow"?Container(
            height: MediaQuery.of(context).size.height/3,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.lock_outline,size:40.0,color: Colors.black26,),
                  Text("Private Account",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
                ],
              ),
            ),
          ):Container():Container(),)




         

        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
