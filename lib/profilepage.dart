
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'other/Post.dart';
import 'setting/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Profile_activity extends StatefulWidget {
  @override
  _Profile_activityState createState() => _Profile_activityState();
}

class _Profile_activityState extends State<Profile_activity> {

  var pref = SharedPreferences.getInstance();

 getprofiledatafromfirebase() async {
    user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(user.uid).get().then((result){
          bio=result.data["bio"];
          profile_url=result.data["img_url"];
          username=result.data["username"];
          name=result.data["name"];
          is_verifyed=result.data["is_verifyed"];
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
    }).catchError((e){
      print(e.message);
      return;
    });
  }

int _per_page=1;

 List<DocumentSnapshot> _product=[];
 DocumentSnapshot _lastdocument;
 ScrollController _scrollController=ScrollController();

_getpostsList() async{
    var user=await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(user.uid).collection("posts").getDocuments()
    .then((QuerySnapshot qn){
      _product=qn.documents;
     //   _lastdocument=qn.documents[qn.documents.length-1];
      //print(_lastdocument);
      setState(() {
        loding=false;
      });
    });
  }

  _getpostsListmore() async{
    var user=await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(user.uid).collection("posts").startAfter([_lastdocument]).limit(_per_page).getDocuments()
        .then((QuerySnapshot qn){
      _product.addAll(qn.documents);
      _lastdocument=qn.documents[qn.documents.length-1];
    });
  }


  var loding=true;
  //=["https://thetempest-co.exactdn.com/wp-content/uploads/2018/07/Feature-image.jpg"];
  ///
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getprofiledatafromfirebase();
    _getpostsList();
    
    _scrollController.addListener((){
      double maxscroll=_scrollController.position.maxScrollExtent;
      double currentscroll=_scrollController.position.maxScrollExtent;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if(maxscroll-currentscroll <= delta){
        _getpostsListmore();
      }
    });

  }



  @override
  Widget build(BuildContext context) {

    return loding==true?Center(child: CircularProgressIndicator(),) :Scaffold(
      body: CustomScrollView(controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight:600.0,
            floating: false,
            snap: false,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.blueAccent,
            title: Container(
                child: Row(
                  children: <Widget>[
                    Text("",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                  ],
                )
            ),

            actions: <Widget>[
              IconButton(icon:  Icon(Icons.gamepad,), onPressed:(){
                Navigator.push(context, MaterialPageRoute(builder: (builder)=>Setting()));
              })
            ],

            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(color: Colors.blueAccent,
                child:
                Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top:90.0),
                          child: Container(
                            height:80.0,
                            width: 80.0,
                            decoration: BoxDecoration(color: Colors.white,shape: BoxShape.circle
                                ,image: DecorationImage(image: NetworkImage(profile_url))
                            ),
                          ),
                        ),

                      ],
                    ),

                    SizedBox(height: 5.0,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(name,style: TextStyle(color: Colors.white,fontSize: 18.0,fontWeight: FontWeight.bold),),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child:is_verifyed==true? Icon(Icons.verified_user,color: Colors.white,size:14.0,):Container(),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(username,style: TextStyle(color: Colors.white70,fontStyle:FontStyle.normal ,fontSize:14.0,fontWeight: FontWeight.bold),)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54,width: 1.0),
                            borderRadius: BorderRadius.only(topRight:Radius.circular(20.0),bottomLeft:Radius.circular(20.0))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(bio,style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(height:55.0,
                          width:110.0,decoration: BoxDecoration(
                              border: Border.all(color: Colors.white,width: 1),
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Follower",style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(),
                                  child: Text(t_follower,style:TextStyle(color: Colors.yellowAccent,fontWeight: FontWeight.bold),),
                                ),
                              ),

                            ],
                          ),
                        ),

                        Container(height:55.0,
                          width:110.0,decoration: BoxDecoration(
                              border: Border.all(color: Colors.white,width: 1),
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Following",style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(),
                                  child: Text(t_following,style:TextStyle(color: Colors.yellowAccent,fontWeight: FontWeight.bold),),
                                ),
                              ),

                            ],
                          ),
                        ),

                        Container(height:55.0,
                          width:110.0,decoration: BoxDecoration(
                              border: Border.all(color: Colors.white,width: 1),
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Posts",style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(),
                                  child: Text(t_posts,style:TextStyle(color: Colors.yellowAccent,fontWeight: FontWeight.bold),),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),



                    SizedBox(height: 10.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(height:55.0,
                          width:110.0,decoration: BoxDecoration(
                              border: Border.all(color: Colors.white,width: 1),
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Likes",style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(),
                                  child: Text(t_likes,style:TextStyle(color: Colors.yellowAccent,fontWeight: FontWeight.bold),),
                                ),
                              ),

                            ],
                          ),
                        ),

                        Container(height:55.0,
                          width:110.0,decoration: BoxDecoration(
                              border: Border.all(color: Colors.white,width: 1),
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Profile Visit",style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(),
                                  child: Text(t_profile_visits,style:TextStyle(color: Colors.yellowAccent,fontWeight: FontWeight.bold),),
                                ),
                              ),

                            ],
                          ),
                        ),

                        Container(height:55.0,
                          width:110.0,decoration: BoxDecoration(
                              border: Border.all(color: Colors.white,width: 1),
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Tags",style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(),
                                  child: Text(t_tags,style:TextStyle(color: Colors.yellowAccent,fontWeight: FontWeight.bold),),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(height:55.0,
                          width:110.0,decoration: BoxDecoration(
                              border: Border.all(color: Colors.white,width: 1),
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Close Friend",style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(),
                                  child: Text(t_close_friend,style:TextStyle(color: Colors.yellowAccent,fontWeight: FontWeight.bold),),
                                ),
                              ),

                            ],
                          ),
                        ),

                        Container(height:55.0,
                          width:110.0,decoration: BoxDecoration(
                              border: Border.all(color: Colors.white,width: 1),
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Crush",style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(),
                                  child: Text(t_crush,style:TextStyle(color: Colors.yellowAccent,fontWeight: FontWeight.bold),),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(height:55.0,
                          width:110.0,decoration: BoxDecoration(
                              border: Border.all(color: Colors.white,width: 1),
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Secret Crush",style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(),
                                  child: Text(t_secret_crush,style:TextStyle(color: Colors.yellowAccent,fontWeight: FontWeight.bold),),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            ),
          ),

          SliverList(delegate: SliverChildBuilderDelegate((_,index){
            if(index==0){
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    Text("Posts",style: TextStyle(color: Colors.black45,fontSize: 20.0,fontWeight: FontWeight.bold),),
                    Expanded(child: Container()),
                    Icon(Icons.list,color: Colors.black26,)
                  ],
                ),
              );
            }
            else{

              return Post(_product[index-1].data["id"]);
            }
          },childCount:_product.length+1))

        ],
      ),
    );
  }
}
