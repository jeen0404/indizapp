import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/homepagefragment/SearchPage.dart';
import 'package:rounded_floating_app_bar/rounded_floating_app_bar.dart';
import 'homepagefragment/ChatPage.dart';
import 'profilepage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'homepagefragment/home_fragment.dart';

class home extends StatefulWidget {
  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomeFragment(),
    SearchPage(),
    ChatPage(),
    ChatPage(),
    ChatPage(),
  ];

  var index=0;

  var home_button_color=Colors.blue;
  var search_button_color=Colors.pink;
  var like_button_color=Colors.pink;
  var chat_button_color=Colors.pink;

  var user = FirebaseAuth.instance.currentUser();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: _children[index],

      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.blueAccent,
        index: 0,
        height: 55.0,
        items: <Widget>[
          Icon(Icons.home, size:20,color: Colors.white,),
          Icon(Icons.search, size: 20,color: Colors.white,),
          Icon(Icons.add, size: 20,color: Colors.white,),
          Icon(Icons.notifications_none, size: 20,color: Colors.white,),
          Icon(Icons.chat_bubble_outline, size: 20,color: Colors.white,),
        ],
        onTap: (i) {
          setState(() {
            index=i;
          });
          //Handle button tap
        },
      ),
    );
  }
}
