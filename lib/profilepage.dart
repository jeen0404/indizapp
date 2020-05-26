
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Post/ImageView.dart';
import 'package:flutter_app/Post/PostList.dart';
import 'package:flutter_app/algo/StringFilter.dart';
import 'package:flutter_app/auth/login_page.dart';
import 'package:flutter_app/auth/mobailnoregister.dart';
import 'package:flutter_app/lists/CrushOnYou.dart';
import 'package:flutter_app/lists/Follower.dart';
import 'package:flutter_app/lists/SecretCrush.dart';
import 'package:flutter_app/other/About.dart';
import 'package:flutter_app/other/AccountVerification.dart';
import 'package:flutter_app/other/BottomBarNav.dart';
import 'package:flutter_app/setting/EditInfo.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';
import 'ImagesLoding/imageload.dart';
import 'lists/CrushList.dart';
import 'package:flutter_app/Post/PostCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lists/Follow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';


class Profile_activity extends StatefulWidget {
  @override
  _Profile_activityState createState() => _Profile_activityState();
}

class _Profile_activityState extends State<Profile_activity> {

  var sharpref;
  PageController pageviewcontroller=PageController();

 getprofiledatafromfirebase() async {
   sharpref = await SharedPreferences.getInstance();

    user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(user.uid).get().then((result){
          bio=result.data["bio"];
          profile_url=result.data["img_url"];
          username=result.data["username"];
          name=result.data["name"];
          nf_message=result.data["nf_message"];
          nf_like=result.data["nf_like"];
          nf_comment=result.data["nf_comment"];
          nf_post=result.data["nf_post"];
          nf_follow=result.data["nf_follow"];
          nf_crush=result.data["nf_crush"];
          nf_secretcrush=result.data["nf_secretcrush"];
          nf_official=result.data["nf_official"];
          private=result.data["private"];
          phone_verified=result.data["phone_verified"];
          gmail_verified=result.data["gmail_verified"];
          account_verified=result.data["account_verified"];
          is_verifyed=result.data["account_verified"];
          t_follower=result.data["t_follower"].toString();
          t_following=result.data["t_following"].toString();
          t_crush_on_you=result.data["t_crush_on_you"].toString();
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
    }).catchError((e){
      print(e.message);
      return;
    });
  }

int _per_page=10;

 List<DocumentSnapshot> _product=[];
 DocumentSnapshot _lastdocument;
 ScrollController _scrollController=ScrollController();



  _getpostsList() async{
    user =await FirebaseAuth.instance.currentUser();
      await Firestore.instance.collection("users").document(user.uid).collection("posts").orderBy("time",descending: true).getDocuments()
        .then((QuerySnapshot qn){
      print(qn.documents[0].data["id"]);
      _lastdocument=qn.documents[qn.documents.length-1];
      setState(() {
        _product=qn.documents;
        loding=false;
      });
    });
  }

  bool getingmoreproduct=false;
  bool _moreProductisavailabel=true;
  _getpostsListmore() async{
    if(_moreProductisavailabel==false){
      return 0;
    }
    if (getingmoreproduct == false) {
      getingmoreproduct=true;
      await Firestore.instance.collection("users").document(user.uid).collection("posts").orderBy("time",descending: true).startAfter(_lastdocument.data["id"]).limit(
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
  //=["https://thetempest-co.exactdn.com/wp-content/uploads/2018/07/Feature-image.jpg"];
  ///+
  List<String> posts=[];

  String profile_url="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoQrCJR3WvVUX-8ZVYO2KPcv7f-nFnnd3lKdGl9zkzbI3CyYi3Bw";

  String name="---";
  FirebaseUser user;

  String username="---";
  // ignore: non_constant_identifier_names
  bool is_verifyed=true;

  String bio="---";
  // ignore: non_constant_identifier_names
  String t_follower="---";
  // ignore: non_constant_identifier_names
  String t_following="---";
  // ignore: non_constant_identifier_names
  String t_crush_on_you="---";
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

  //notification var
  bool nf_message=false;
  bool nf_like=false;
  bool nf_comment=false;
  bool nf_post=false;
  bool nf_follow=false;
  bool nf_crush=false;
  bool nf_secretcrush=false;
  bool nf_official=false;
  bool private=false;
  bool phone_verified=false;
  bool gmail_verified=false;
  bool account_verified=false;


  var notification;
  var gridview=true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getprofiledatafromfirebase();
    _getpostsList();

    _scrollController.addListener((){
      double maxscroll=_scrollController.position.maxScrollExtent;
      double currentscroll=_scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.10;
      if(maxscroll-currentscroll <= delta){
        _getpostsListmore();
      }
    });

  }



  @override
  Widget build(BuildContext context) {
    return loding==true?Center(child: CircularProgressIndicator(),) :Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      body: PageView(
        controller: pageviewcontroller,
        children: <Widget>[
          CustomScrollView(controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight:50.0,
                floating: false,
                snap: false,
                centerTitle: true,
                leading: IconButton(icon: Icon(Icons.keyboard_backspace,color: Colors.black,), onPressed: (){
                  Navigator.pop(context);
                }),
                iconTheme: IconThemeData(color: Colors.black),
                backgroundColor: Color(0xffF9F9F9),
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
                  IconButton(icon:  Icon(Icons.settings,color: Colors.black,), onPressed:(){
                    pageviewcontroller.jumpToPage(6);
                  })
                ],
              ),

              //SliverToBoxAdapter(child: Divider(height: 1.0,),),

              SliverToBoxAdapter(
                child:Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0,top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Column(crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              GestureDetector(
                                onTap: (){
                                  getimages();
                                },
                                child: Stack(
                                  children: <Widget>[
                                   ImageLoad(url: profile_url,hight: 80.0,width:80.0,),
                                  Positioned(bottom:0.0,right:0.0,child: Container(decoration: BoxDecoration(shape:BoxShape.circle,border:Border.all(color: Colors.white,width:1.0,),color: Colors.white),child: Icon(Icons.add_circle,color: Colors.pink,size:18.0,))),
                                  ],
                                ),
                              ),
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
                                  width:70.0,
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (builder)=>PostList(user.uid)));
                                    },
                                    child: Column(children: <Widget>[
                                      Text(t_posts.toString(),style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16.0)),
                                      Text("  Posts  ",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10.0)),
                                    ],),
                                  ),
                                )

                                ,Container(
                                  width: 70.0,
                                  child: GestureDetector(
                                    onTap:(){
                                      Navigator.push(context, MaterialPageRoute(builder: (builder)=>Followerlist()));
                                    },
                                    child: Column(children: <Widget>[
                                      Text(t_follower.toString(),style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16.0)),
                                      Text(" Follower ",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10.0)),
                                    ],),
                                  ),
                                ),

                                Container(
                                  width: 70.0,
                                  child: GestureDetector(
                                    onTap:(){
                                      Navigator.push(context, MaterialPageRoute(builder: (builder)=>FollowingList()));
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
                                  width: 70.0,
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (builder)=>CrushOnYou()));
                                    },
                                    child: Column(children: <Widget>[
                                      Text(t_crush_on_you.toString(),style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16.0)),
                                      Text("crush on you",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10.0)),
                                    ],),
                                  ),
                                )

                                ,Container(
                                  width: 70.0,
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (builder)=>CrushList()));
                                    },
                                    child: Column(children: <Widget>[
                                      Text(t_crush.toString(),style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16.0)),
                                      Text("    crush   ",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10.0)),
                                    ],),
                                  ),
                                ),

                                Container(
                                  width: 70.0,
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (builder)=>SecretCrushList()));
                                    },
                                    child: Column(children: <Widget>[
                                      Text(t_secret_crush.toString(),style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16.0)),
                                      Text("Secret Crush",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10.0)),
                                    ],),
                                  ),
                                )
                              ],),
                                SizedBox(height:15.0,)
                            ],),
                          )
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(children: <Widget>[
                        Expanded(child: Container(
                            color: Colors.white,
                            child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: StringFilter(text: bio,),
                        ))),
                      ],),
                    ),

                  Row(children: <Widget>[
                    Flexible(child:Padding(
                      padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 10),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (builder)=>EditInfo(name,username,bio,profile_url)));
                        },
                        child: Container(height:40.0,
                          decoration: BoxDecoration(color: Colors.white,border: Border.all(color: Colors.black12),borderRadius:BorderRadius.circular(5.0))
                          ,child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                              Text("Profile"),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.edit,size: 16.0,),
                              ),
                            ],)
                      ),
                    ))
                    )
                  ],)
                  //  SizedBox(height: 5.0,),
                  ],
                ),
              ),

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

            ],
          ),

          Followerlist(),
          FollowingList(),
          CrushList(),
          CrushOnYou(),
          SecretCrushList(),

          CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Colors.white,
                title: Text("Settings",style: TextStyle(color: Colors.black,fontSize: 20.0,),),
              leading: IconButton(icon:Icon(Icons.arrow_back,color: Colors.black87,), onPressed:(){
                pageviewcontroller.jumpToPage(0);
              }),
              ),

              SliverToBoxAdapter(child: Divider(height: 1.0,),),
              SliverToBoxAdapter(child:
                GestureDetector(
                  onTap: (){
                    FirebaseDatabase.instance.reference().child("url").once().then((val){
                      Share.share('your friend $username  has invited you to join INDIZ. Download app from here : ${val.value}');
                    });
                  },
                  child: Row(children: <Widget>[
                    IconButton(icon:Icon(Icons.people_outline,color: Colors.black,), onPressed: null),
                    Text("Invite Your Friend",style: TextStyle(fontWeight: FontWeight.bold),)
                  ],),
                )
                ,),



              SliverToBoxAdapter(child:
                Row(children: <Widget>[
                  IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                  Text("Notification Setting",style: TextStyle(fontWeight: FontWeight.bold),)
                ],)
                ,),
              SliverToBoxAdapter(child: Divider(height: 1.0,),),
              SliverToBoxAdapter(child:
                Row(children: <Widget>[
                  SizedBox(width: 50.0,),
                  //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                  Text("Meggages Notification",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                  Expanded(child: Container()),
                  Switch(value: nf_message, onChanged:(val){
                    Firestore.instance.collection("users").document(user.uid).
                    updateData({"nf_message":val});
                  },activeTrackColor: Colors.pink,
                    activeColor: Colors.pink,),
                SizedBox(width: 10.0,)
                ],)
                ,),
              SliverToBoxAdapter(child:
                Row(children: <Widget>[
                  SizedBox(width: 50.0,),
                  //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                  Text("Like Notification",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                  Expanded(child: Container()),
                  Switch(value: nf_like, onChanged:(val){
                    Firestore.instance.collection("users").document(user.uid).
                    updateData({"nf_like":val});
                  },activeTrackColor: Colors.pink,
                    activeColor: Colors.pink,),
                SizedBox(width: 10.0,)
                ],)
                ,),
              SliverToBoxAdapter(child:
                Row(children: <Widget>[
                  SizedBox(width: 50.0,),
                  //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                  Text("Comment Notification",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                  Expanded(child: Container()),
                  Switch(value: nf_comment, onChanged:(val){
                    Firestore.instance.collection("users").document(user.uid).
                    updateData({"nf_comment":val});
                  },activeTrackColor: Colors.pink,
                    activeColor: Colors.pink,),
                SizedBox(width: 10.0,)
                ],)
                ,),
              SliverToBoxAdapter(child:
                Row(children: <Widget>[
                  SizedBox(width: 50.0,),
                  //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                  Text("Post Notification",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                  Expanded(child: Container()),
                  Switch(value:nf_post, onChanged:(val){
                    Firestore.instance.collection("users").document(user.uid).
                    updateData({"nf_post":val});
                  },activeTrackColor: Colors.pink,
                    activeColor: Colors.pink,),
                SizedBox(width: 10.0,)
                ],)
                ,),
              SliverToBoxAdapter(child:
                Row(children: <Widget>[
                  SizedBox(width: 50.0,),
                  //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                  Text("Follow Notification",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                  Expanded(child: Container()),
                  Switch(value: nf_follow, onChanged:(val){
                    Firestore.instance.collection("users").document(user.uid).
                    updateData({"nf_Follow":val});
                  },activeTrackColor: Colors.pink,
                    activeColor: Colors.pink,),
                SizedBox(width: 10.0,)
                ],)
                ,),
              SliverToBoxAdapter(child:
                Row(children: <Widget>[
                  SizedBox(width: 50.0,),
                  //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                  Text("Crush Notification",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                  Expanded(child: Container()),
                  Switch(value: nf_crush, onChanged:(val){
                    Firestore.instance.collection("users").document(user.uid).
                    updateData({"nf_crush":val});
                  },activeTrackColor: Colors.pink,
                    activeColor: Colors.pink,),
                SizedBox(width: 10.0,)
                ],)
                ,),
              SliverToBoxAdapter(child:
                Row(children: <Widget>[
                  SizedBox(width: 50.0,),
                  //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                  Text("Secret Crush Notification",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                  Expanded(child: Container()),
                  Switch(value:nf_secretcrush, onChanged:(val){
                    Firestore.instance.collection("users").document(user.uid).
                    updateData({"nf_Secretcrush":val});
                  },activeTrackColor: Colors.pink,
                    activeColor: Colors.pink,),
                SizedBox(width: 10.0,)
                ],)
                ,),
              SliverToBoxAdapter(child:
                Row(children: <Widget>[
                  SizedBox(width: 50.0,),
                  //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                  Text("Official Notification",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                  Expanded(child: Container()),
                  Switch(value: nf_official, onChanged:(val){
                    Firestore.instance.collection("users").document(user.uid).
                    updateData({"nf_official":val});
                  },activeTrackColor: Colors.pink,
                    activeColor: Colors.pink,),
                SizedBox(width: 10.0,)
                ],)
                ,),





              SliverToBoxAdapter(child:
              Row(children: <Widget>[
                IconButton(icon:Icon(Icons.lock_outline,color: Colors.black,), onPressed: null),
                Text("Privacy",style: TextStyle(fontWeight: FontWeight.bold),)
              ],)
                ,),
              SliverToBoxAdapter(child: Divider(height: 1.0,),),
              SliverToBoxAdapter(child:
              Row(children: <Widget>[
                SizedBox(width: 50.0,),
                //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                Text("Private Account",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                Expanded(child: Container()),
                Switch(value: private, onChanged:(val){
                 Firestore.instance.collection("users").document(user.uid).
                      updateData({"private":val});
                },activeTrackColor: Colors.pink,
                  activeColor: Colors.pink,),
                SizedBox(width: 10.0,)
              ],)
                ,),


           /*   SliverToBoxAdapter(child:
              Row(children: <Widget>[
                IconButton(icon:Icon(Icons.security,color: Colors.black,), onPressed: null),
                Text("Security",style: TextStyle(fontWeight: FontWeight.bold),)
              ],)
                ,),
              SliverToBoxAdapter(child: Divider(height: 1.0,),),
              SliverToBoxAdapter(child:
              Row(children: <Widget>[
                SizedBox(width: 50.0,),
                //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text("Change Password",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                ),

              ],)
                ,),
*/

              SliverToBoxAdapter(child:
              Row(children: <Widget>[
                IconButton(icon:Icon(Icons.verified_user,color: Colors.black,), onPressed: null),
                Text("Verification",style: TextStyle(fontWeight: FontWeight.bold),)
              ],)
                ,),
              SliverToBoxAdapter(child: Divider(height: 1.0,),),
              SliverToBoxAdapter(child:
              GestureDetector(
                onTap: (){
               //   Navigator.push(context,MaterialPageRoute(builder: (builder)=>AccountVerification()));
                },
                child: Row(children: <Widget>[
                  SizedBox(width: 50.0,),
                  //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                  Text("Account verification",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                  Expanded(child: Container()),
                  IconButton(icon: Icon(!account_verified?Icons.not_interested:Icons.check,color:Colors.pink), onPressed: null)
                ],),
              )
                ,),

              SliverToBoxAdapter(child:
              Row(children: <Widget>[
                SizedBox(width: 50.0,),
                //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                Text("Email verification",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                Expanded(child: Container()),
                IconButton(icon: Icon(!gmail_verified?Icons.not_interested:Icons.check,color:Colors.pink,), onPressed: null)
              ],)
                ,),
              SliverToBoxAdapter(child:
              Row(children: <Widget>[
                SizedBox(width: 50.0,),
                //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                GestureDetector(
                    onTap: (){
                      if(!phone_verified){
                        Navigator.push(context,MaterialPageRoute(builder: (builder)=>Register()),);
                      }
                    },
                    child: Text("Phone no. verification",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),)),
                Expanded(child: Container()),
                IconButton(icon: Icon(!phone_verified?Icons.not_interested:Icons.check,color:Colors.pink,), onPressed: null)
              ],)
                ,),



              SliverToBoxAdapter(child:
              Row(children: <Widget>[
                IconButton(icon:Icon(Icons.scatter_plot,color: Colors.black,), onPressed: null),
                Text("Other",style: TextStyle(fontWeight: FontWeight.bold),)
              ],)
                ,),
              SliverToBoxAdapter(child: Divider(height: 1.0,),),
              SliverToBoxAdapter(child:
              Row(children: <Widget>[
                SizedBox(width: 50.0,),
                //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context,MaterialPageRoute(builder: (builder)=>   About()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text("About",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                  ),
                ),
              ],)
                ,),

              SliverToBoxAdapter(child:
              Row(children: <Widget>[
                SizedBox(width: 50.0,),
                //IconButton(icon:Icon(Icons.notifications_none,color: Colors.black,), onPressed: null),
                GestureDetector(
                  onTap: (){
                    _launchURL();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text("Go to Website",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                  ),
                ),
              ],)
                ,),


              SliverToBoxAdapter(child:
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: Divider(height: 1.0)),
                GestureDetector(
                  onTap: (){
                    FirebaseAuth.instance.signOut();
                    GoogleSignIn().disconnect();
                    sharpref.setInt("login_status",0);
                    Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (builder)=>LoginPage()),(Route<dynamic> route)=>false);

                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 20.0),
                    child: Text("Logout",style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
                  Expanded(child: Divider(height: 1.0,)),
              ],)
                ,),


            ],
          ),


        ],
      ),

      bottomNavigationBar: BottomBarNav(4),
    );
  }

  File _image;
  getimages() async {
    return showDialog(context: context,builder: (BuildContext contaxt){
      return   AlertDialog(
        content: Container(
          height: 80.0,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  IconButton(icon: Icon(Icons.sd_storage), onPressed: () async {
                    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
                    if(image!=null){
                      Navigator.pop(context);
                      image=await _cropImage(image);
                      if(image!=null){
                        uploadimage(image);
                      }
                    }
                    // Navigator.pop(context);
                  }),
                  Text("Gallery")
                ],
              ),
              Column(
                children: <Widget>[
                  IconButton(icon: Icon(Icons.camera), onPressed: () async {
                    var image = await ImagePicker.pickImage(source: ImageSource.camera);
                    if(image!=null) {
                      image=await _cropImage(image);
                      if(image!=null){
                        uploadimage(image);
                      }
                    }
                    Navigator.pop(context);
                  }),
                  Text("camera")
                ],
              ),
            ],),
        ),
      );
    });
  }


  Future<File> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath:imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1,ratioY:1),
      maxWidth:400,
      maxHeight:400,
    );
    return croppedFile;
  }


  FirebaseStorage _storage = FirebaseStorage.instance;
  Future<String> uploadimage(var img) async{
    var user= await FirebaseAuth.instance.currentUser();
    var ref=_storage.ref().child("profileimage").child(user.uid).child("profile.jpg");
    final StorageUploadTask uploadTask = ref.putFile(img);
    final StorageTaskSnapshot downloadUrl =
    (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    setState(() {
      profile_url=url;
      _image=null;
    });
    Firestore.instance.collection("users").document(user.uid).updateData({
    "img_url":profile_url});
    return url;
  }




  _launchURL() async {
    const url = 'https://indiz.xyz/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
