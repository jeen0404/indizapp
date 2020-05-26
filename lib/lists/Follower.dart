import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_app/lists/listcardforfollower.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class Followerlist extends StatefulWidget {
  @override
  _FollowerListState createState() => _FollowerListState();
}

class _FollowerListState extends State<Followerlist> with AutomaticKeepAliveClientMixin{
  FirebaseUser user;
  List<DocumentSnapshot>  _lists=[];
  DocumentSnapshot _lastnode;
  int _perpage =25;
  var loading=true;
  var _controller= ScrollController();

  Future<void> getfollowinglist() async{

    user=await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("users").document(user.uid).collection("follower").orderBy("id").limit(_perpage).getDocuments()
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

  bool getingmoreproduct=false;
  bool _moreProductisavailabel=true;


  getmorefollowinglist() async {
    if(_moreProductisavailabel==false){
      return;
    }
    if (getingmoreproduct == false) {

      getingmoreproduct=true;
      await Firestore.instance.collection("users").document(user.uid).collection("follower").orderBy("id").startAfter([_lastnode.data["id"]]).limit(
          _perpage)
          .getDocuments()
          .
      then((QuerySnapshot qn) {
        if(_lists.length<_perpage){
          _moreProductisavailabel=false;
        }
        _lists.addAll(qn.documents);
        _lastnode = qn.documents[qn.documents.length - 1];
      });
      setState(() {
      });
      getingmoreproduct=false;
    }
  }






@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getfollowinglist();
    _controller.addListener((){
      double maxscroll=_controller.position.maxScrollExtent;
      double currentscroll=_controller.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if(maxscroll-currentscroll <= delta){
        getmorefollowinglist();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
     backgroundColor: Colors.white,
      appBar:AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,

        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Followers",style: TextStyle(color: Colors.black),),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.info_outline), onPressed: (){
            return showDialog(barrierDismissible: true,context: context,builder: (BuildContext contaxt){
              return   AlertDialog(content: Container(
                height:120.0,
                child:Center(child: Text("Your Indiz followers! you can share posts and chat with your followers listed here. Happy sharing.",
                  style: TextStyle(color:Colors.grey,fontWeight: FontWeight.bold),)),
              ),
              );
            }
            );
          })
        ],
      ) ,

      body:loading?Container(child: Center(child: CircularProgressIndicator(),),):LiquidPullToRefresh(
        //key: _refreshIndicatorKey,	// key if you want to add
          onRefresh: getfollowinglist,	// refresh callback
          scrollController:_controller ,
          child:ListView.builder(itemBuilder:(_,index){
            return _lists.length==0?Container(height: 500.0,child: Center(child: Text("Nothing to show...."),),):
            list_card_for_follower(_lists[index].data["id"]);
          },itemCount: _lists.length==0?1:_lists.length,controller: _controller,)	// scroll view
      ),
    );
  }
  // ignore: missing_return
  Future<void> __handleRefresh(){
    return null;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
