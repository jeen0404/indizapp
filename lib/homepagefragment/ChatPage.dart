import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../profilepage.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          floating: true,
          pinned: false,
          snap: false,
          expandedHeight:120.0,
          iconTheme: IconThemeData(color: Colors.pink),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 2.0,
          leading: new Icon(Icons.people_outline,color: Colors.black,),
          actionsIconTheme: IconThemeData(color: Colors.black),


          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:60.0),
                child: Container(
                  height:40.0,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12,width: 1.0),
                      borderRadius: BorderRadius.circular(5.0)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextField(
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
            ),
          ),
        ),

        SliverList(delegate:SliverChildBuilderDelegate((_,postion){
          return Container(
            height: 78.0,
            decoration: BoxDecoration(
              color: Colors.white,
             // border: Border(top: BorderSide(color: Colors.pink,width: 1.0))
            ),
            child: Row(
              mainAxisAlignment:MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height:50.0,
                    width: 50.0,
                    decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent,width: 1.0),
                      shape: BoxShape.circle
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage("https://mobirise.com/bootstrap-template/profile-template/assets/images/timothy-paul-smith-256424-1200x800.jpg"),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(height:20.0,),
                          Text("Jivan Patel",style:TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize:15.0)),
                          Text("@Jivan_Patel",style:TextStyle(color: Colors.black54,fontWeight: FontWeight.normal,fontSize:12.0)),
                        ],
                      ),
                      Expanded(child: Container()),
                      Padding(
                        padding: const EdgeInsets.only(top:30.0),
                        child:Icon(Icons.timeline,color: Colors.black26,)
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:25.0),
                        child: Text("3h ago",style: TextStyle(color: Colors.black26,fontWeight: FontWeight.bold),),
                      )
                    ],
                  ),
                ),



              ],
            ),
          );

        },childCount: 15)
        )

      ],
    );
  }
}
