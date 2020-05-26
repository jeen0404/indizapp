import 'package:flutter/material.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        centerTitle:true,
        iconTheme: IconThemeData(color: Colors.black45),
        title: Text("About",style: TextStyle(color: Colors.blueAccent),),

      ) ,

      body:CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child:  Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("""   Chat & Meet new people nearby who are as passionate about things as you are. Indiz is the best friendship chat app to make new friends nearby. This is NOT a dating app.

    This is all about you, your Interests, and people nearby. Go ahead… chat & meet new people everyday and make new friendships!
    
    Can chat privately with anyone and you can make new friends.
    Stay connected to the people who matter most in your life.
   
    - Post updates with photos,  animated gifs.
    - Respond to posts with likes, comment, share and emoji.
    - Control who sees your posts with easy-to-use privacy options.
    — Start a private conversation with your friends in messaging.
    — Or just follow, if you’re crush on him/her. No big deal.
    - or just add him/her on secret crush .

    So, Hey! If you love things that really secret, then this is will be great one."""),
              ),
            ),
          )
        ],
      )
    );
  }
}
