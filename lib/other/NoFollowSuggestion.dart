import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/other/SuggetionCartFirstLogin.dart';
class NoFollowSuggestion extends StatefulWidget {
  @override
  _NoFollowSuggestionState createState() => _NoFollowSuggestionState();
}

class _NoFollowSuggestionState extends State<NoFollowSuggestion> with AutomaticKeepAliveClientMixin {
  
 List<DocumentSnapshot> _prodeuct;
 var loading=true;
  FirebaseUser user;
  getlist() async{
    user= await FirebaseAuth.instance.currentUser();
   await Firestore.instance.collection("users").orderBy("t_follower",descending: true).limit(20).getDocuments()
        .then((QuerySnapshot qn){
       _prodeuct=qn.documents;
       print(_prodeuct[0]);
       setState(() {
         loading=false;
       });
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getlist();
  }

  @override
  Widget build(BuildContext context) {
    return loading?Container(height: 50.0,child:Center(child:Container(width:20.0,child: LinearProgressIndicator(backgroundColor:Colors.white,)),),):
        Container(height: MediaQuery.of(context).size.height-180.0,child:
            CustomScrollView(
              slivers: <Widget>[
                SliverGrid(delegate: SliverChildBuilderDelegate((_,index){
                  return Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: SuggestionCartForFirstLogin(_prodeuct[index].data["uid"]),
                  );
                },childCount: _prodeuct.length), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1,))
              ],
            ),
            /*Center(child: SuggestionfeedCard(_prodeuct[index].data["uid"]),);*/
        );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
