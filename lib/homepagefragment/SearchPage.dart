import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/other/Post.dart';
import 'package:flutter_app/other/SearchUserCard.dart';
import 'package:flutter_app/other/suggestionfeedCard.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  var view=0;
  var page_limeit=10;
  var feed = [];
  var searchuserid = [];

  loadFeed() async{
    await FirebaseDatabase.instance.reference().child("posts").orderByChild("postid").limitToFirst(page_limeit).once().then((val){
      for (var i in val.value.values){
        feed.add(i["post_id"]);
        print(i);
        setState(() {
          view=1;
        });
      }
    });
  }
  
  SearchUsername(var queryText) async{
    await FirebaseDatabase.instance.reference().child("users").orderByChild("username").startAt(queryText)
        .endAt(queryText+"\uf8ff").once().then((val){
      searchuserid.clear();
          for (var i in val.value.values){
        searchuserid.add(i["uid"]);
        setState(() {
          view=2;
        });
      }
      if(searchuserid.length==0){
        setState(() {
          view=3;
        });
      }
      print(view);
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
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          floating: true,
          pinned: false,
          snap: false,
          expandedHeight:70.0,
          iconTheme: IconThemeData(color: Colors.pink),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 2.0,

          actionsIconTheme: IconThemeData(color: Colors.black),

          title: Container(
            height:40.0,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black12,width: 1.0),
                borderRadius: BorderRadius.circular(5.0)
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: TextField(
                onChanged: (value){
                  if(value.length==0){
                    setState(() {
                      view=1;
                    });
                  }
                  else{
                    SearchUsername(value);
                    setState(() {
                      view=3;
                    });
                  }


                },
                style: TextStyle(color: Colors.blueAccent,fontSize: 12.0),
                decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(color: Colors.black26,fontSize: 12.0 ,fontWeight: FontWeight.bold),
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.search,color: Colors.black,)
                ),
              ),
            ),
          ),
        ),

        SliverList(delegate: SliverChildBuilderDelegate((_,index){
          if(view==0){
            return Container(height: 500.0,color: Colors.white,child: Center(child: CircularProgressIndicator(),),);
          }
          else if(view==1){
            return GestureDetector(onTap: (){
              setState(() {
                view=2;
              });
            },child: Post(feed[index]));
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
        },childCount: setview()),)


      ],
    );
  }
}
