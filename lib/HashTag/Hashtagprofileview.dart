import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Post/ImageView.dart';
import 'package:flutter_app/Post/PostCard.dart';


class HashTagProfileView extends StatefulWidget {
  String hashtag_name;
  HashTagProfileView(name){
    this.hashtag_name=name;
  }

  @override
  _HashTagProfileViewState createState() => _HashTagProfileViewState();
}


class _HashTagProfileViewState extends State<HashTagProfileView>  {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var gridview=true;
  FirebaseUser user;

  String follow_button_text="loading";

  checkfollow() async{
     user=await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection("hashtags").document(widget.hashtag_name).collection("follower").document(user.uid)
    .get().then((DocumentSnapshot dq){
      if(dq.data==null){
        setState(() {
           follow_button_text="Follow";
        });
      }
      else{
        setState(() {
           follow_button_text="Unfollow";
        });
      }
    });
  }
  followhashtag() async{
    
    var time=DateTime.now();

    if(follow_button_text=="Follow"){
      setState(() {
         follow_button_text="Unfollow";
      });
      Firestore.instance.collection("hashtags").document(widget.hashtag_name).collection("follower").document(user.uid)
          .setData({
        "id":user.uid,
        "time":time
      }).then((result){
        Firestore.instance.collection("users").document(user.uid).collection("hashtags_following").document(widget.hashtag_name)
            .setData({
          "id":widget.hashtag_name,
          "time":time
        });
      });
    }
    else{
      setState(() {
        follow_button_text="Follow";
      });
      Firestore.instance.document("hashtags").collection("follower").document(user.uid).delete();
      Firestore.instance.collection("users").document(user.uid).collection("hashtags_following").document(widget.hashtag_name).delete();
    }
  }

  deleteSuggestion() async{
    print("delete suggestio");
    await Firestore.instance.collection("users").getDocuments()
        .then((QuerySnapshot qn){
       qn.documents.forEach( (DocumentSnapshot dq){
         print(dq.data["name"]);
         Firestore.instance.collection("users").document(dq.data["uid"])
             .collection("Suggestion").getDocuments()
             .then((QuerySnapshot qqn){
               print("jyrdgurgliudrhgiru");
           qqn.documents.forEach((DocumentSnapshot dqq){
             print(dq.data["uid"]);
             Firestore.instance.collection("users").document(dq.data["uid"])
                 .collection("Suggestion").document(dqq.data["id"]).delete();
           });
         });
       });
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkfollow();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xffF9F9F9),
      body: CustomScrollView(
        slivers: <Widget>[

          SliverAppBar(
            floating: true,
            backgroundColor: Color(0xffF9F9F9),
            elevation: 2.0,
            ///[leading] is the icon of left side  in [SliverAppBar]
            /// In [leading ] we asian a back button to go back in previous page
            leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.black,)///back button
                //whenever back button is clicked [oppressed] function will be called
                , onPressed:(){
                  //[Pop] will pop the page or take us to previous page
                  Navigator.pop(context);
                }),
            title: Text("#"+widget.hashtag_name,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize:16.0),),
            actions: <Widget>[
              IconButton(icon: Icon(Icons.more_vert,color: Colors.black,), onPressed: (){
                return showDialog(context: context,builder:
                    (builder)=>AlertDialog(content: Container(
                  height:120.0,
                  width: 300.0,
                  child: ListView(children: <Widget>[

                    Material( // needed
                      color: Colors.white,
                      child: InkWell(
                        highlightColor: Colors.black12,
                        onTap: () {
                          Navigator.pop(context);
                          followhashtag();
                        }, // needed
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(follow_button_text,style: TextStyle(fontSize:16.0,fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                    ),

                    Material( // needed
                      color: Colors.white,
                      child: InkWell(
                        highlightColor: Colors.black12,
                        onTap: () {
                          Navigator.pop(context);
                          Firestore.instance.collection("hashtags").document(widget.hashtag_name).collection("reports")
                          .document(user.uid).setData({"id":user.uid});
                          _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.blueAccent,content: Text("your report is submitted for hashtag "+widget.hashtag_name ,style: TextStyle(color: Colors.white),)));
                        }, // needed
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("Report",style: TextStyle(fontSize:16.0,fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                    ),
                    Material( // needed
                      color: Colors.white,
                      child: InkWell(
                        highlightColor: Colors.black12,
                        onTap: () {
                          Navigator.pop(context);
                        }, // needed
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("Cancel",style: TextStyle(fontSize:16.0,fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                    ),


                  ],),
                ),
                ));
              })
            ],
          ),
          StreamBuilder<DocumentSnapshot>(builder: (_,snap){
           return !snap.hasData? SliverToBoxAdapter(child: Container(),):
               snap.data.data==null?
               SliverToBoxAdapter(child:
           Column(children: <Widget>[
             Row(children: <Widget>[
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal:20.0,vertical: 20.0),
                 child: Column(
                   children: <Widget>[
                     Stack(
                       children: <Widget>[
                         Container(
                           height:80.0,
                           width: 80.0,
                           decoration: BoxDecoration(
                               color: Colors.blueAccent,
                               borderRadius: BorderRadius.circular(10.0)
                                ,image: DecorationImage(image: NetworkImage("https://www.larutadelsorigens.cat/filelook/full/22/225582/alone-wallpapers-sad-feeling.jpg")
                               ,fit: BoxFit.cover)
                           ),
                         ),

                       ],
                     ),
                     Text("#"+widget.hashtag_name,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
                   ],
                 ),
               ),
               Expanded(child: Column(children: <Widget>[
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Text("0 posts",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                 ),
                 GestureDetector(
                   onTap: (){
                     followhashtag();
                   },
                   child: Container(width: 100,height:30,
                     decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(5.0)),
                     child: Center(child: Text(follow_button_text,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),),
                   ),
                 )
               ],)),
             ],),

           ],),):
               SliverToBoxAdapter(child:
               Column(children: <Widget>[
                 Row(children: <Widget>[
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal:20.0,vertical: 20.0),
                     child: Column(
                       children: <Widget>[
                         Stack(
                           children: <Widget>[
                             Container(
                               height:80.0,
                               width: 80.0,
                               decoration: BoxDecoration(
                                   color: Colors.blueAccent,
                                   borderRadius: BorderRadius.circular(10.0)
                                   ,image: DecorationImage(image: NetworkImage(snap.data.data["img_url"])
                                   ,fit: BoxFit.cover)
                               ),
                             ),

                           ],
                         ),
                         Text("#"+widget.hashtag_name,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
                       ],
                     ),
                   ),
                   Expanded(child: Column(children: <Widget>[
                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Text(snap.data.data["t_posts"].toString()+" posts",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                     ),
                     GestureDetector(
                       onTap:(){
                         followhashtag();
                       },
                       child: Container(width: 100,height:30,
                         decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(5.0)),
                         child: Center(child: Text(follow_button_text,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),),
                       ),
                     )
                   ],)),
                 ],),

               ],),);
          },stream: Firestore.instance.collection("hashtags").document(widget.hashtag_name).snapshots(),),



          SliverToBoxAdapter(child: Divider(height: 1.0,),),

          StreamBuilder<QuerySnapshot>(builder: (_,snap){
           return !snap.hasData?SliverToBoxAdapter(child: Container(),):
           SliverToBoxAdapter(child: Row(children: <Widget>[
             Container(
               height:30.0,
               width: MediaQuery.of(context).size.width,
               child: ListView.builder(itemBuilder:(_,index){
                 return Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 2.0),
                   child: GestureDetector(
                     onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (builder)=> HashTagProfileView(snap.data.documents[index].data["username"])));
                     },
                     child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0),
                       //border: Border.all(color: Colors.black12)
                     ),
                       child: Center(
                         child: Padding(
                           padding: const EdgeInsets.symmetric(horizontal:5.0,vertical: 4.0),
                           child: Text("#"+snap.data.documents[index].data["username"],style: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold),),
                         ),
                       ),),
                   ),
                 );
               },itemCount: snap.data.documents.length,scrollDirection: Axis.horizontal,),
             )
           ],),);
          },stream:Firestore.instance.collection("hashtags").limit(50).snapshots(),),

          SliverToBoxAdapter(child: Divider(height: 1.0,),),

          SliverToBoxAdapter(child:  Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: <Widget>[
            IconButton(icon: Icon(Icons.pages,color: Colors.black,), onPressed: (){
              if(gridview==false){
                setState(() {
                  gridview=true;
                });
              }
            }),
            IconButton(icon: Icon(Icons.menu), onPressed: (){
              if(gridview==true){
                setState(() {
                  gridview=false;
                });
              }

            }),
          ],),),

          SliverToBoxAdapter(child: Row(mainAxisAlignment: gridview?MainAxisAlignment.start:MainAxisAlignment.end,children: <Widget>[
            Container(height:4.0,color: Colors.black12,width: MediaQuery.of(context).size.width/2,)
          ],),),


          SliverToBoxAdapter(child: Divider(height: 1.0,),),


          gridview?StreamBuilder<QuerySnapshot>(builder: (_,snap){
            return !snap.hasData?SliverToBoxAdapter(child: Container(),):
                SliverGrid(delegate: SliverChildBuilderDelegate((_,index){
                  return Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: PostImageView(snap.data.documents[index].data["id"]),
                  );
                },childCount: snap.data.documents.length), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3));
          },stream: Firestore.instance.collection("hashtags").document(widget.hashtag_name).collection("posts").orderBy("time",descending: true).snapshots(),)
        :
        StreamBuilder<QuerySnapshot>(builder: (_,snap){
          return !snap.hasData?SliverToBoxAdapter(child: Container(),):
          SliverList(delegate: SliverChildBuilderDelegate((_,index){
            return PostCard(snap.data.documents[index].data["id"]);
          },childCount: snap.data.documents.length));
        },stream: Firestore.instance.collection("hashtags").document(widget.hashtag_name).collection("posts").snapshots(),),
/*
          SliverToBoxAdapter(child:Container(
            height: MediaQuery.of(context).size.height/3,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.lock_outline,size:40.0,color: Colors.black26,),
                  Text("No pots yet't with this hashtags ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
                ],
              ),
            ),
          ))*/
        ],
      ),
    );
  }

}
