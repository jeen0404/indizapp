import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Messages.dart';
import 'package:flutter_app/lists/list_cardforfollowandcrush.dart';
import 'package:flutter_app/other/ChatCard.dart';
import 'package:flutter_app/other/SendMessageChatPageCart.dart';
import 'package:flutter_app/other/SuggetionCartFirstLogin.dart';

class ChatPage extends StatefulWidget  {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with AutomaticKeepAliveClientMixin {

FirebaseUser user;
bool loading=true;
List<DocumentSnapshot> _chats=[];
List<DocumentSnapshot> _suggestionchat=[];
List<DocumentSnapshot> _followmore=[];


getuser() async{
  user =await  FirebaseAuth.instance.currentUser();
  setState(() {
    loading=false;
  });
  Firestore.instance.collection("users").document(user.uid).updateData({"unread_message":0});
 await Firestore.instance.collection("users").document(user.uid).collection("follow").limit(50).getDocuments()
  .then((QuerySnapshot qn){
    if(qn.documents.length>0){
      setState(() {
        _suggestionchat=qn.documents;
      });
    }
 });
  Firestore.instance.collection("users").document(user.uid).collection("Suggestion").limit(50).getDocuments()
      .then((QuerySnapshot qn){
    setState(() {
      _followmore=qn.documents;
    });
  });
}
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuser();
  }


  List<Widget> chatlist=[];
  chatlistwedget(List<DocumentSnapshot> dq){
    dq.forEach((item){
      chatlist.add(GestureDetector(onTap:(){
        Navigator.push(context, MaterialPageRoute(builder: (builder)=>Messages(item.data["s_id"])));
      },child: ChatCard(item.data["id"],item.data["s_id"])));
    });
    return chatlist;
  }

  @override
  Widget build(BuildContext context) {
      super.build(context);
    return Scaffold(
      backgroundColor:Colors.white,
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          snap: true,
          pinned: true,
          floating: true,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          //centerTitle: true,
          elevation: 0.0,
          title: Text("Messages",style: TextStyle(color: Colors.black),),
          leading: new IconButton(icon: Icon(Icons.keyboard_backspace), onPressed: (){
            Navigator.pop(context);
          }),
          actionsIconTheme: IconThemeData(color: Colors.black),
        ),

        SliverToBoxAdapter(child: Divider(height: 1.0,),),


       /* SliverList(delegate:SliverChildBuilderDelegate((_,index){
         return GestureDetector(
           onTap: (){
             Navigator.push(context, MaterialPageRoute(builder: (builder)=>Messages(_chats[index].data["s_id"])));
           },
           child: _chats.length==0?Container(
              height: MediaQuery.of(context).size.height/4,
              child: Center(child: Text("No Chats yet..."),),
            )
             :ChatCard(_chats[index].data["id"],_chats[index].data["s_id"]),
         );

        },childCount: _chats.length==0?1:_chats.length)),*/

         loading?SliverToBoxAdapter(child: Container(),):StreamBuilder<QuerySnapshot>(builder:(_,snap){
          return !snap.hasData?SliverToBoxAdapter(child:Container(
            height: MediaQuery.of(context).size.height/4,
            child: Center(child: Text("No Chats yet..."),),
          ) ):
              SliverList(delegate:SliverChildListDelegate(chatlistwedget(snap.data.documents)),);

        },stream:Firestore.instance.collection("users").document(user.uid).collection("chat").orderBy("last_message_time",descending:true).snapshots(),),



        SliverToBoxAdapter(child:SizedBox(height: 20.0,)),
        SliverToBoxAdapter(child: Divider(height: 1.0,),),
        SliverToBoxAdapter(child: Row(mainAxisAlignment: MainAxisAlignment.start,children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:_suggestionchat.length==0?Text("Suggestion"): Text("New followers"),
          )
        ],),),

        SliverList(delegate:SliverChildBuilderDelegate((_,index){
         return _suggestionchat.length==0?list_card(_followmore[index].data["id"]): GestureDetector(
           onTap: (){
             Navigator.push(context, MaterialPageRoute(builder: (builder)=>Messages(_suggestionchat[index].data["s_id"])));
           },
           child: SendMessageChatPageCard(_suggestionchat[index].data["id"]),
         );
        },childCount: _suggestionchat.length==0?_followmore.length:_suggestionchat.length)),



        SliverToBoxAdapter(child:SizedBox(height: 20.0,)),
        _suggestionchat.length==0?SliverToBoxAdapter(child: Container(),):SliverToBoxAdapter(child: Row(mainAxisAlignment: MainAxisAlignment.start,children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:Text("Suggestion")
          )
        ],),),
        SliverList(delegate: SliverChildBuilderDelegate((_,index){

          return list_card(_followmore[index].data["id"]);

        },childCount: _suggestionchat.length==0?0:_followmore.length))

      ],),
    );
  }

  @override
  bool get wantKeepAlive => true;

}


/*
* loading?Center(child: CircularProgressIndicator(),):Column(
        children: <Widget>[
          Divider(height: 1.0,),
          Flexible(
            child:StreamBuilder<QuerySnapshot>(builder:(_,snap){
              return !snap.hasData?Center(child: CircularProgressIndicator(),)
                  :
              ListView.builder(itemBuilder: (_,postion){
                return
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (builder)=>Messages(snap.data.documents[postion].data["s_id"])));
                    },
                    child: Container(
                      height: 78.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child:PageView(children: <Widget>[
                        GestureDetector(
                            onDoubleTap: (){
                              showDialog(context: context,builder: (BuildContext contaxt){
                                return AlertDialog(content:Row(children: <Widget>[
                                  GestureDetector(
                                      onTap: (){
                                        showDialog(context: context,builder: (BuildContext contaxt){
                                          return AlertDialog(content:Row(children: <Widget>[
                                            Flexible(child: Text("are you sure you want to delete chat.")),
                                            GestureDetector(
                                                onTap: (){
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  Firestore.instance.collection("users").document(user.uid).collection("chat").document(snap.data.documents[postion].data["s_id"])
                                                      .delete().then((result){
                                                    Firestore.instance.collection("users").document(snap.data.documents[postion].data["s_id"]).collection("chat").document(user.uid)
                                                        .delete().then((result){
                                                      Firestore.instance.collection("chats").document(snap.data.documents[postion].data["id"]).delete()
                                                          .then((result){
                                                        setState(() {
                                                          snap.data.documents.removeAt(postion);
                                                        });
                                                      });
                                                    });

                                                  });
                                                },
                                                child: CircleAvatar(radius: 30.0,backgroundColor: Colors.blueAccent,child: Text("Ok",style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold),)))
                                          ]
                                            ,),
                                          )
                                          ;});
                                      },
                                      child: Text("Delete Chat",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
                                ],));
                              });
                            },
                            child: ChatCard(snap.data.documents[postion].data["id"],snap.data.documents[postion].data["s_id"])),

                      ],)
                    ),
                  );
              },itemCount: snap.data.documents.length,);
            },stream:Firestore.instance.collection("users").document(user.uid).collection("chat").orderBy("last_message_time",descending:true).snapshots(),),
          ),
        ],
      ),
* */