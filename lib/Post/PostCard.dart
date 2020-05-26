import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/ImagesLoding/imageload.dart';
import 'package:flutter_app/Post/Comment.dart';
import 'package:flutter_app/Post/EditCaption.dart';
import 'package:flutter_app/Post/PostView.dart';
import 'package:flutter_app/algo/StringFilter.dart';
import 'package:flutter_app/profilepage.dart';
import 'package:time_ago_provider/time_ago_provider.dart';
import '../OtherUserProfile.dart';
import 'Commentcard.dart';
import 'package:extended_image/extended_image.dart';
import 'package:pinch_zoom_image/pinch_zoom_image.dart';



class PostCard extends StatefulWidget {
  var postid;
  PostCard(var postid){
    this.postid=postid;
  }
  @override
  _PostCardState createState() => _PostCardState(this.postid);
}

class _PostCardState extends State<PostCard> with AutomaticKeepAliveClientMixin {

  bool loading = true;
  DocumentSnapshot _product;
  DocumentSnapshot userdata;
   PageController pageController;

  var postid;

  _PostCardState(var postid) {
    this.postid = postid;
  }

  var likeicon = Icons.favorite_border;
  bool liked = false;
  FirebaseUser user;
  var time;
  var private = true;
  var varified = false;
  var img_url = "--";
  var name = "--";
  var username = "--";
  var post_report_limit = true;
  int _current = 0;



  getpostdata() async {
    user = await FirebaseAuth.instance.currentUser();
    likedata();

   await  Firestore.instance.collection("posts").document(postid)
        .snapshots()
        .listen((DocumentSnapshot dq) {
      _product = dq;
       Firestore.instance.collection("users").document(
          _product.data["userid"]).get()
          .then((DocumentSnapshot dq) {
        userdata=dq;
        private = dq.data["private"];
        img_url = dq.data["img_url"];
        name = dq.data["name"];
        username = dq.data["username"];
        varified = dq.data["account_verified"];
        loading = false;
         CheckFollow();
         CheckSecretCrush();
         CheckCrush();
      });
    });
  }

  likedata() async {
    time = await DateTime.now();
    await Firestore.instance.collection("posts").document(postid).collection(
        "likes").document(user.uid)
        .get().then((result) {
      if (result.data != null) {
        likeicon = Icons.favorite;
        liked = true;
      }
    });
    setState(() {});
  }


  @override
  void initState() {
    super.initState();
    getpostdata();
    pageController=PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: loading
          ?Container(height: 500.0,):
         Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child:Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ImageLoad(url: img_url, hight: 34, width:34)
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(children: <Widget>[
                        GestureDetector(onTap: () {
                          if(user.uid== _product.data["userid"]){
                            Navigator.push(context,MaterialPageRoute(builder: (builder)=>Profile_activity()));
                          }else{
                            Navigator.push(context,MaterialPageRoute(builder: (builder)=>OtherUserProfile( _product.data["userid"])));
                          }
                        },
                            child: Text(
                              name.length < 20 ? name : name.substring(0, 20),
                              style: TextStyle(color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0),)),
                        varified == true ? Icon(
                          Icons.verified_user, color: Colors.pink,
                          size: 12.0,) : Container(),
                      ],),
                      Text(_product.data["location"].length < 25 ? _product
                          .data["location"] : _product.data["location"].substring(
                          0, 25), style: TextStyle(color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.0),),
                      Text(TimeAgo.getTimeAgo(
                          _product.data["u_time"].millisecondsSinceEpoch),
                        style: TextStyle(
                            color: Colors.black, fontSize: 8.0),),
                    ],),

                ],
              ),
              Stack(children: <Widget>[
                GestureDetector(
                  onDoubleTap: () {
                    if (!liked) {
                      setState(() {
                        liked = true;
                        likeicon = Icons.favorite;
                      });
                      Firestore.instance.collection("posts").document(postid)
                          .collection("likes").document(user.uid)
                          .setData({"id": user.uid, "time": time});
                    } else {
                      setState(() {
                        liked = false;
                        likeicon = Icons.favorite_border;
                      });
                      Firestore.instance.collection("posts").document(postid)
                          .collection("likes").document(user.uid)
                          .delete();
                    }
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    child: PageView.builder(itemBuilder: (_,index){
                            return    PinchZoomImage(image:ExtendedImage.network(
                              _product.data["images"][index],
                              width:MediaQuery.of(context).size.width,
                              height:MediaQuery.of(context).size.width,
                              fit: BoxFit.fill,
                              cache: true,
                              shape: BoxShape.rectangle,
                            ),);
                          },itemCount:_product.data["images"].length,scrollDirection: Axis.horizontal,onPageChanged: (val){
                            setState(() {
                              _current=val;
                            });
                          },controller: pageController,),

                  ),
                ),
                _product.data["t_report"] < 10 ? Container() : !post_report_limit
                    ? Container()
                    : Container(height: MediaQuery
                    .of(context)
                    .size
                    .width,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  color: Colors.black,
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          post_report_limit = false;
                        });
                      },
                      child: Center(child: Text(
                        "Sensitive content tap to see",
                        style: TextStyle(color: Colors.white),),)),
                ),


              ],),
              Row(
                children: <Widget>[
                  IconButton(onPressed: () {
                    if (!liked) {
                      setState(() {
                        liked = true;
                        likeicon = Icons.favorite;
                      });
                      Firestore.instance.collection("posts").document(postid)
                          .collection("likes").document(user.uid)
                          .setData({"id": user.uid, "time": time});
                    } else {
                      setState(() {
                        liked = false;
                        likeicon = Icons.favorite_border;
                      });
                      Firestore.instance.collection("posts").document(postid)
                          .collection("likes").document(user.uid)
                          .delete();
                    }
                  }, icon: Icon(likeicon, color: Colors.pink, size: 25.0,)),
                  GestureDetector(onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (builder) => PostView(_product.data["id"])));
                  },
                      child: Text(_product.data["t_like"].toString() + " likes",
                        style: TextStyle(color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0),)),
                  IconButton(onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (builder) => Comment(postid,
                          post_uploaderid: _product.data["userid"],)));
                  },
                      icon: Icon(
                        Icons.crop, color: Colors.black, size: 25.0,)),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (builder) => Comment(postid,
                              post_uploaderid: _product.data["userid"],)));
                      }
                      ,
                      child: Text(
                        _product.data["t_comment"].toString() + " comments",
                        style: TextStyle(color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0),)),
                  Expanded(child: Container()),
                  //  IconButton(icon:Icon(Icons.turned_in_not), onPressed: null),
                  Flexible(
                    child: Container(
                      height: 15.0,
                      child: ListView.builder(itemBuilder: (_, index) {
                        if (_product.data["images"].length == 1) {
                          return Container();
                        }
                        return Container(
                          width: 5.0,
                          height: 5.0,
                          margin: EdgeInsets.only(right: 4.0, top: 6.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _current == index ? Colors.black : Colors
                                  .black12
                          ),
                        );
                      },
                        itemCount: _product.data["images"].length,
                        scrollDirection: Axis.horizontal,),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.more_vert), onPressed: () {
                    return showDialog(context: context, builder:
                        (builder) =>
                        AlertDialog(content: Container(
                            height: user.uid == _product.data["userid"]
                                ? 250
                                : 150, width: 250.0, child:
                        ListView(children: <Widget>[
                          Material( // needed
                            color: Colors.white,
                            child: InkWell(
                              highlightColor: Colors.black12,
                              onTap: () {
                                Navigator.pop(context);
                                Firestore.instance.collection("posts")
                                    .document(postid).collection("report")
                                    .document(user.uid).setData({
                                  "uid": user.uid,
                                  "time": time,
                                })
                                    .then((val) {
                                  Firestore.instance.collection("users")
                                      .document(user.uid).collection("feed")
                                      .document(postid)
                                      .delete();
                                  setState(() {
                                    post_report_limit = true;
                                  });
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      backgroundColor: Colors.purple,
                                      content: Text("Post is Reported!..",
                                        style: TextStyle(
                                            color: Colors.white),)));
                                });
                              }, // needed
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text("Report", style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),),
                                ),
                              ),
                            ),
                          ),
                          user.uid == _product.data["userid"]
                              ?Material( // needed
                            color: Colors.white,
                            child: InkWell(
                              highlightColor: Colors.black12,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (builder) => EditCaption(_product,userdata)));
                              }, // needed
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text("Edit Caption", style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),),
                                ),
                              ),
                            ),
                          ):Container(),

                          user.uid == _product.data["userid"]
                              ? Material( // needed
                            color: Colors.white,
                            child: InkWell(
                              highlightColor: Colors.black12,
                              onTap: () {
                                Navigator.pop(context);
                                Firestore.instance.collection("users")
                                    .document(_product.data["userid"]).collection(
                                    "posts")
                                    .document(postid)
                                    .delete();
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    backgroundColor: Colors.purple,
                                    content: Text(
                                      "Post will be removed Soon!",
                                      style: TextStyle(
                                          color: Colors.white),)));
                              }, // needed
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text("Delete Posts",
                                    style: TextStyle(fontSize: 16.0,
                                        fontWeight: FontWeight.bold),),
                                ),
                              ),
                            ),
                          )
                              : Container(),

                          Material( // needed
                            color: Colors.white,
                            child: InkWell(
                              highlightColor: Colors.black12,
                              onTap: () {
                                follow();
                              }, // needed
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(f_f_text, style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),),
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
                                  child: Text(crush_text, style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),),
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
                                  child: Text(S_crush_text, style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),),
                                ),
                              ),
                            ),
                          ),
                        ],)
                        ),
                        ));
                  }
                  )
                ],
              ),


              _product.data["caption"] == "" ? Container() :
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0, left: 12.0),
                child: Row(children: <Widget>[
                  // Flexible(child: Text(snap.data["caption"])),
                  Flexible(child: StringFilter(text: _product.data["caption"],))
                ],),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (builder) => PostView(_product.data["id"],showcomment: true,)));

                },
                child: Row(
                  children: <Widget>[
                    StreamBuilder<QuerySnapshot>(builder: (_, comments) {
                      return Expanded(
                        child: !comments.hasData ? Container()
                            : comments.data.documents.length == 0
                            ? Container()
                            :
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 14.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text("Comments", style: TextStyle(
                                      color: Colors.black38,
                                      fontWeight: FontWeight.bold),),
                                  Flexible(child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Divider(),
                                  )),
                                ],
                              ),
                            ),
                            CommentCard(
                                comments.data.documents[0].data["id"], postid),
                            comments.data.documents.length > 1
                                ? CommentCard(
                                comments.data.documents[1].data["id"], postid)
                                : Container(),

                          ],),
                      );
                    },
                      stream: Firestore.instance.collection("posts").document(
                          postid).collection("comment").limit(2).orderBy(
                          "time", descending: true).snapshots(),),
                  ],
                ),
              ),
              Divider(),
            ],),
      ),
    );
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


  String crush_text = "loding...";
  String S_crush_text = "loding...";
  var loding = true;
  var f_f_text = "loding..";


  CheckFollow() async {
    var user = await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(_product.data["userid"])
        .collection("follower").document(user.uid)
        .get()
        .then((result) {
      if (result.data != null) {
        setState(() {
          f_f_text = "Unfollow";
        });
      }
      else {
        Firestore.instance.collection("users").document(_product.data["userid"])
            .collection("f_request").document(user.uid)
            .get()
            .then((result) {
          if (result.data != null) {
            setState(() {
              f_f_text = "Requested";
            });
          } else {
            setState(() {
              f_f_text = "Follow";
            });
          }
        }).catchError((e) {
          setState(() {
            f_f_text = "Error..";
          });
        });
      }
    }).catchError((e) {
      setState(() {
        f_f_text = "Error..";
      });
    });
  }

  follow() async {
    Navigator.pop(context);
    var user = await FirebaseAuth.instance.currentUser();
    var time = await DateTime.now();
    if (f_f_text == "Follow") {
      if (!private) {
        setState(() {
          f_f_text = "Unfollow";
        });
        await Firestore.instance.collection("users").document(
            _product.data["userid"]).collection("follower").document(user.uid)
            .setData({
          "id": user.uid,
          "time": time,
        }).then((val) {
          Firestore.instance.collection("users").document(user.uid).collection(
              "follow").document(_product.data["userid"])
              .setData({
            "id": _product.data["userid"],
            "time": time,
          }).then((val) {

          });
        });
      }
      else {
        setState(() {
          f_f_text = "Requested";
        });
        await Firestore.instance.collection("users").document(
            _product.data["userid"]).collection("f_request").document(user.uid)
            .setData({
          "id": user.uid,
          "time": time,
        }).then((val) {
          Firestore.instance.collection("users").document(user.uid).collection(
              "f_requested").document(_product.data["userid"])
              .setData({
            "id": _product.data["userid"],
            "time": time,
          }).then((val) {

          });
        });
      }
    }
    else if (f_f_text == "Unfollow" || f_f_text == "Requested") {
      setState(() {
        f_f_text = "Follow";
      });
      var user = await FirebaseAuth.instance.currentUser();
      await Firestore.instance.collection("users").document(
          _product.data["userid"]).collection("f_request").document(user.uid)
          .delete()
          .then((result) {});

      await Firestore.instance.collection("users").document(user.uid)
          .collection("f_requested").document(_product.data["userid"]).delete()
          .then((result) {});

      await Firestore.instance.collection("users").document(
          _product.data["userid"]).collection("follower").document(user.uid)
          .delete()
          .then((result) {});
      await Firestore.instance.collection("users").document(user.uid)
          .collection("follow").document(_product.data["userid"]).delete()
          .then((result) {});
    }
    else if (f_f_text == "loding..") {

    }
  }

  addtoCrush() async {
    Navigator.pop(context);
    var user = await FirebaseAuth.instance.currentUser();
    var time = await DateTime.now();
    if (crush_text == "Add to Crush list") {
      if (!private) {
        setState(() {
          crush_text = "Remove From Crush List";
        });
        await Firestore.instance.collection("users").document(
            _product.data["userid"]).collection("crush_on_you").document(
            user.uid)
            .setData({
          "id": user.uid,
          "time": time,
        }).then((val) {
          Firestore.instance.collection("users").document(user.uid).collection(
              "crush").document(_product.data["userid"])
              .setData({
            "id": _product.data["userid"],
            "time": time,
          }).then((val) {});
        });
      }
      else {
        setState(() {
          crush_text = "Requested";
        });
        await Firestore.instance.collection("users").document(
            _product.data["userid"]).collection("crush_on_you_request")
            .document(user.uid)
            .setData({
          "id": user.uid,
          "time": time,
        })
            .then((val) {
          Firestore.instance.collection("users").document(user.uid).collection(
              "crush_requested").document(_product.data["userid"])
              .setData({
            "id": _product.data["userid"],
            "time": time,
          }).then((val) {});
        });
      }
    }
    else
    if (crush_text == "Remove From Crush List" || crush_text == "Requested") {
      setState(() {
        crush_text = "Add to Crush list";
      });
      var user = await FirebaseAuth.instance.currentUser();
      await Firestore.instance.collection("users").document(
          _product.data["userid"]).collection("crush_on_you").document(user.uid)
          .delete()
          .then((result) {});
      await Firestore.instance.collection("users").document(user.uid)
          .collection("crush").document(_product.data["userid"]).delete()
          .then((result) {});
      await Firestore.instance.collection("users").document(
          _product.data["userid"]).collection("crush_on_you_request").document(
          user.uid).delete()
          .then((result) {});
      await Firestore.instance.collection("users").document(user.uid)
          .collection("crush_requested").document(_product.data["userid"])
          .delete()
          .then((result) {});
    }
  }

  addtoSecretCrush() async {
    Navigator.pop(context);
    var user = await FirebaseAuth.instance.currentUser();
    var time = await DateTime.now();
    if (S_crush_text == "Add to SecreteCrush") {
      setState(() {
        S_crush_text = "Remove From SecreteCrush";
      });
      await Firestore.instance.collection("users").document(user.uid)
          .collection("secret_crush").document(_product.data["userid"])
          .setData({
        "id": _product.data["userid"],
        "time": time,
      });
    }
    else if (S_crush_text == "Remove From SecreteCrush") {
      setState(() {
        S_crush_text = "Add to SecreteCrush";
      });
      var user = await FirebaseAuth.instance.currentUser();
      await Firestore.instance.collection("users").document(user.uid)
          .collection("secret_crush").document(_product.data["userid"]).delete()
          .then((result) {});
    }
  }

  CheckCrush() async {
    var user = await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(_product.data["userid"])
        .collection("crush_on_you").document(user.uid)
        .get()
        .then((result) {
      if (result.data != null) {
        setState(() {
          crush_text = "Remove From Crush List";
        });
      } else {
        Firestore.instance.collection("users").document(_product.data["userid"])
            .collection("crush_on_you_request").document(user.uid)
            .get()
            .then((result) {
          if (result.data != null) {
            setState(() {
              crush_text = "Requested";
            });
          }
          else {
            setState(() {
              crush_text = "Add to Crush list";
            });
          }
        }).catchError((error) {
          setState(() {
            crush_text = "Error";
          });
        });
      }
    }).catchError((e) {
      setState(() {
        crush_text = "Error";
      });
    });
  }

  CheckSecretCrush() async {
    var user = await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(user.uid).collection(
        "secret_crush").document(_product.data["userid"])
        .get().then((result) {
      if (result.data != null) {
        setState(() {
          S_crush_text = "Remove From SecreteCrush";
        });
      } else {
        setState(() {
          S_crush_text = "Add to SecreteCrush";
        });
      }
    }).catchError((e) {
      setState(() {
        S_crush_text = "Add to SecreteCrush";
      });
    });
  }


}
