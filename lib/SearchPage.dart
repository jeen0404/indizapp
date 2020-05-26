import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/other/BottomBarNav.dart';
import 'package:flutter_app/Post/PostCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/other/SearchUserCard.dart';
import 'package:flutter_app/other/suggestionfeedCard.dart';
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin {

  var view=0;
  var page_limeit=10;
  var textcontoller=TextEditingController();
  List<DocumentSnapshot> feed=[];
  DocumentSnapshot _lastnode;
  var searchuserid = [];
  var intersts=[
    "Photography",
    "Art",
    "Design",
    "Travel",
    "Food drink",
    "Architecture",
    "space x",
    "Education",
    "bikes lovers"];
  FirebaseUser user;

  ScrollController _scrollController = ScrollController();
  loadFeed() async{
    await Firestore.instance.collection("posts").orderBy("u_time",descending: true).limit(page_limeit).getDocuments()
        .then((val){
          val.documents.forEach((DocumentSnapshot dq){
            Firestore.instance.collection("users").document(dq.data["userid"]).get()
            .then((DocumentSnapshot rq){
              print(rq.data["username"]);
              if(rq.data["private"]){
              }
              else{
                setState(() {
                  feed.add(dq);
                });
              }
            });
          });
      _lastnode=val.documents[val.documents.length-1];
    });
   await setState(() {
      view=1;
    });
  }


  bool getingmoreproduct=false;
  bool _moreProductisavailabel=true;


  loadFeedmore() async {
    if(_moreProductisavailabel==false){
      return;
    }
    if (getingmoreproduct == false) {
      getingmoreproduct=true;
      await Firestore.instance.collection("posts").orderBy("u_time",descending: true).startAfterDocument(_lastnode).limit(
          page_limeit)
          .getDocuments()
          .
      then((QuerySnapshot qn) {
        if(qn.documents.length<page_limeit){
          _moreProductisavailabel=false;
        }
        qn.documents.forEach((DocumentSnapshot dq){
          Firestore.instance.collection("users").document(dq.data["userid"]).get()
              .then((DocumentSnapshot rq){
            print(rq.data["username"]);
            if(rq.data["private"]){
            }
            else{
              setState(() {
                feed.add(dq);
              });
            }
          });
        });
        _lastnode = qn.documents[qn.documents.length - 1];
      });
      setState(() {

      });
      getingmoreproduct=false;
    }
  }




  SearchUsername(var queryText) async{
    searchuserid.clear();
    await FirebaseDatabase.instance.reference().child("users").orderByChild("username").startAt(queryText)
        .endAt(queryText+"\uf8ff").limitToFirst(50).once().then((val){
          for (var i in val.value.values){
        searchuserid.add(i["uid"]);
        searchuserid=searchuserid.toSet().toList();
        setState(() {
          view=2;
        });
      }
      if(searchuserid.length==0){
        setState(() {
          view=3;
        });
      }
    });
  }



 setview(){
    if(view==0){
      return 1;
    }
    else if(view==1){
      return feed.length;
    }
    else if(view==2){
      return searchuserid.length;
    }
    else if(view==3){
      return 1;
    }
  }


@override
  void initState() {
    // TODO: implement initState
  loadFeed();
  _scrollController.addListener((){
    double maxscroll=_scrollController.position.maxScrollExtent;
    double currentscroll=_scrollController.position.pixels;
    double delta = MediaQuery.of(context).size.height * 0.25;
    if(maxscroll-currentscroll < delta){
      if(view==1){
        loadFeedmore();
      }
    }
  });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            snap: true,
            iconTheme: IconThemeData(color: Colors.black45),
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            actionsIconTheme: IconThemeData(color: Colors.black),
            leading: IconButton(icon: Icon(Icons.arrow_back), onPressed:(){Navigator.pop(context);}),
            title: Container(
              height:40.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0)
              ),
              child: Padding(
                padding: const EdgeInsets.only(top:5.0),
                child: TextField(
                  onChanged: (value){
                    if(value.length==0){
                      setState(() {
                        view=1;
                      });
                    }
                    else{
                      SearchUsername(value.toLowerCase());
                      setState(() {
                        view=3;
                      });
                    }
                  },
                  controller: textcontoller,
                  style: TextStyle(color: Colors.blueAccent,fontSize:20.0),
                  decoration: InputDecoration.collapsed(
                    hintText: "Search",
                    hintStyle: TextStyle(color: Colors.black26,fontSize:20.0 ,fontWeight: FontWeight.bold),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              IconButton(icon: Icon(Icons.clear), onPressed: (){
                textcontoller.clear();setState(() {
                  view=1;
                });
              })
            ],
          ),

          SliverToBoxAdapter(child: Divider(height: 1.0,),),


          SliverList(delegate: SliverChildBuilderDelegate((_,index){
            if(view==0){
              return Container(height: 500.0,color: Colors.white,child: Center(child: CircularProgressIndicator(),),);
            }
            else if(view==1){
              /*if(index==4 || index==15){
                return StreamBuilder<QuerySnapshot>(builder:(_,snap){
                  return Column(
                    children: <Widget>[
                      Row(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Suggestion for you",style: TextStyle(fontWeight: FontWeight.bold),),
                        )
                      ],),
                      !snap.hasData?Container(height: 250.0,child: Center(child: CircularProgressIndicator(),),):
                      Container(height:220.0,
                        child:ListView.builder(itemBuilder: (_,index){
                          return SuggestionfeedCard(snap.data.documents[index].data["uid"]);
                        },itemCount: snap.data.documents.length,scrollDirection: Axis.horizontal,) ,),
                    ],
                  );
                },stream: Firestore.instance.collection("users").document(user.uid).collection("Suggestion").limit(30).snapshots(),);
              }*/
              return PostCard(feed[index].data["id"]);
            }
            else if(view==2){

              return  SearchUserCard(searchuserid[index]);
            }
            else if(view == 3){
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0,vertical: 50.0),
                child: Container(width: 250.0,height: 50.0,decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent,width: 1.0))
                  ,child:Center(child: Text("No Match Found"),)
                  ,),
              );
            }
          },childCount:setview(),))

        ],controller: _scrollController,
      ),

      bottomNavigationBar: BottomBarNav(1),

    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

/*

 */

/*

 */

