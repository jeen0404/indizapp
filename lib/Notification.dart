import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/NoificationCard/FollowRequestNatification.dart';
import 'package:flutter_app/NoificationCard/MatchCardForSecretCrush.dart';
import 'package:flutter_app/NoificationCard/SecretCrushNotification.dart';
import 'package:flutter_app/NoificationCard/textnotification.dart';
import 'package:flutter_app/other/BottomBarNav.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';


class Natification extends StatefulWidget {
  @override
  _NatificationState createState() => _NatificationState();
}

class _NatificationState extends State<Natification> {

  FirebaseUser user;


  List<DocumentSnapshot>  _lists=[];
  DocumentSnapshot _lastnode;
  int _perpage =25;
  var loading=true;
  var _controller= ScrollController();


  accept_crush(userid) async{
    var time=await DateTime.now();
    await Firestore.instance.collection("users").document(userid).collection("crush").document(user.uid)
        .setData({
      "id":user.uid,
      "time":time,
    }).then((val){
      Firestore.instance.collection("users").document(user.uid).collection("crush_on_you").document(userid)
          .setData({
        "id":userid,
        "time":time,
      }).then((val){

      });
    });
    removetocrush(userid);
  }
  removetocrush(userid) async{
    await Firestore.instance.collection("users").document(userid).collection("crush_requested").document(user.uid).delete()
        .then((result){
    });
    await Firestore.instance.collection("users").document(user.uid).collection("crush_on_you_request").document(userid).delete()
        .then((result){
    });
  }

  acceptFollow(userid)async
  {
    var time=await DateTime.now();
    await Firestore.instance.collection("users").document(userid).collection("follow").document(user.uid)
        .setData({
      "id":user.uid,
      "time":time,
    }).then((val){
      Firestore.instance.collection("users").document(user.uid).collection("follower").document(userid)
          .setData({
        "id":userid,
        "time":time,
      }).then((val){

      });
    });

    RemoveFollow(userid);
  }
  RemoveFollow(userid) async{
    await Firestore.instance.collection("users").document(userid).collection("f_requested").document(user.uid).delete()
        .then((result){
    });

    await Firestore.instance.collection("users").document(user.uid).collection("f_request").document(userid).delete()
        .then((result){
    });
  }


  Future<void> getNotoficationlist() async{
    user=await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(user.uid).collection("Notification").orderBy("id",descending: true).limit(_perpage).getDocuments()
        .then((QuerySnapshot qn){
      if(qn.documents.length!=0){
        _lists.clear();
        setState(() {
          _lists=qn.documents;
          _lastnode=qn.documents[qn.documents.length-1];
        });
      }
      setState(() {
        loading=false;
      });
    });
    return _lists;
  }

  var loadmorelist=true;
  var lodinglist=false;

  getnotificationlistmore() async{
   if(!loadmorelist){
     return 0;
   }
    if(lodinglist=true){
    loadmorelist=false;
    await Firestore.instance.collection("users").document(user.uid).collection("Notification").orderBy("id",descending: true).startAfter([_lastnode.data["id"]]).limit(_perpage)
        .getDocuments().
    then((QuerySnapshot qn){
      if(qn.documents.length <_perpage){
        loadmorelist=false;
      }
      _lists.addAll(qn.documents);
      _lists.toSet().toList();
      _lastnode=qn.documents[qn.documents.length-1];
    });
    setState(() {
    });
    loadmorelist=true;
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotoficationlist();
    _controller.addListener((){
      double maxscroll=_controller.position.maxScrollExtent;
      double currentscroll=_controller.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if(maxscroll-currentscroll < delta){
        getnotificationlistmore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black45),
        title: Text("Notification",style: TextStyle(color: Colors.black),),
      ) ,
      body:loading?Container(child: Center(child: CircularProgressIndicator(),),):
      LiquidPullToRefresh(
      child:ListView.builder(itemBuilder: (_,index){


        if(_lists[index].data["type"]==0){
          return Column(
            children: <Widget>[
              TextNotification(_lists[index]),
            //  Divider(height:0.2 )
            ],
          );
        }


        else if(_lists[index].data["type"]==1){
          return Column(
            children: <Widget>[
              SecretCrushNotification(_lists[index]),
           //   Divider(height:0.2 )
            ],
          );
        }


        else if(_lists[index].data["type"]==2){
          return Column(
            children: <Widget>[
              Row(children: <Widget>[
              Flexible(child: FollowRequestNotification(_lists[index]),),

              IconButton(icon: Icon(Icons.more_vert), onPressed:(){
                return showDialog(barrierDismissible: true,context: context,builder: (BuildContext contaxt){
                  return   AlertDialog(content: Container(
                    height:40.0,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);
                                    acceptFollow(_lists[index].data["uid"]);
                                    Firestore.instance.collection("users").document(user.uid).collection("Notification").document(_lists[index].data["id"])
                                        .delete();
                                    setState(() {
                                      _lists.removeAt(index);
                                    });
                                  },
                                  child: Text("Accept")),
                              GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);
                                    Firestore.instance.collection("users").document(user.uid).collection("Notification").document(_lists[index].data["id"])
                                        .delete();
                                    RemoveFollow(_lists[index].data["uid"]);
                                    setState(() {
                                      _lists.removeAt(index);
                                    });
                                  },
                                  child: Text("Remove")),
                            ],
                          ),
                        )


                      ],
                    ),
                  ),
                  );
                }
                );
              })
              ],),
            //  Divider(height:0.2 )
            ],
          );
        }

        else if(_lists[index].data["type"]==3){
          return Column(
            children: <Widget>[
              Row(children: <Widget>[
              Flexible(child: SecretCrushNotification(_lists[index]),),

              IconButton(icon: Icon(Icons.more_vert), onPressed:(){
                return showDialog(barrierDismissible: true,context: context,builder: (BuildContext contaxt){
                  return   AlertDialog(content: Container(
                    height:40.0,
                    width: 150.0,
                    child: Column(
                     children: <Widget>[
                       Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                           children: <Widget>[
                             GestureDetector(
                                 onTap: (){
                                   Navigator.pop(context);
                                   Firestore.instance.collection("users").document(user.uid).collection("Notification").document(_lists[index].data["id"])
                                       .delete();
                                   accept_crush(_lists[index].data["uid"]);
                                   setState(() {
                                     _lists.removeAt(index);
                                   });
                                 },
                                 child: Text("Accept")),
                             GestureDetector(
                                 onTap: (){
                                   Navigator.pop(context);
                                   Firestore.instance.collection("users").document(user.uid).collection("Notification").document(_lists[index].data["id"])
                                       .delete();
                                   removetocrush(_lists[index].data["uid"]);
                                   setState(() {
                                     _lists.removeAt(index);
                                   });
                                 },
                                 child: Text("Remove")),
                           ],
                         ),
                       )


                     ],
                      ),
                  ),
                  );
                }
                );
              })
              ],),
           //   Divider(height:0.2 )
            ],
          );
        }
        else if(_lists[index].data["type"]==4){
          return Column(
            children: <Widget>[
              MatchCardForSecretCrush(_lists[index]),
            ],
          );
        }
      },itemCount:_lists.length,), onRefresh: getNotoficationlist,scrollController: _controller,),

      bottomNavigationBar:BottomBarNav(3),

    );
  }




}
