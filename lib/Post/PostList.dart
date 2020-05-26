import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/Post/PostCard.dart';

class PostList extends StatefulWidget {

  /// [userid] is user id of users
  ///  of any hash tags
  var userid;
  var postion;
  /// [PostList] constructor is here
  PostList(userid,{postion=0.0}){
    this.userid=userid;
    this.postion=postion*500;
    /// assigning the constructor [ref] value to class var [ref]
  }

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController=ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController= ScrollController();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      /// * here we using [CustomScrollView] so that we can show multiple cards in single list
      body: CustomScrollView(
        /// children of list is asian inside [slivers<Widget>]
        slivers: <Widget>[
          /// [SliverAppBar] is app_bar or Toolbar of this page
          SliverAppBar(
            floating: true,
            backgroundColor: Color(0xffF9F9F9),
            elevation: 2.0,
            ///[leading] is the icon of left side  in [SliverAppBar]
            /// In [leading ] we asian a back button to go back in previous page
            leading: IconButton(icon: Icon(Icons.keyboard_backspace,color: Colors.black,)///back button
              //whenever back button is clicked [oppressed] function will be called
                , onPressed:(){
              //[Pop] will pop the page or take us to previous page
                Navigator.pop(context);
                }),
            title: Text("Posts",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 14.0),),

          ),

          SliverToBoxAdapter(child: Divider(height: 1.0,),),


          /// [StreamBuilder] will fetch data form from given ref and that assign to list
          /// [builder:(_,snap)] here [_] is context
          /// [builder:(_,snap)] here [snap] is snap is hold the data of stream in [QuerySnapshot] type
          StreamBuilder<QuerySnapshot>(builder:(_,snap){

                if(!snap.hasData){
                    return SliverToBoxAdapter(child: Container(),);
                }
                else{
                  return  SliverList(delegate: SliverChildBuilderDelegate((_,index){
                    return PostCard(snap.data.documents[index].data["id"]);
                  },childCount: snap.data.documents.length),);
                }

          },stream: Firestore.instance.collection("users").document(widget.userid).collection("posts").orderBy("time",descending: true).snapshots(),)
        ],controller: _scrollController,semanticChildCount:2,
      ),

      floatingActionButton:widget.postion/500==0?Container(): FloatingActionButton(onPressed:(){
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        _scrollController.jumpTo(widget.postion);
        /*_scrollController.animateTo(widget.postion,
            duration: Duration(milliseconds:1000), curve: Curves.easeOut);*/
      },
      backgroundColor: Colors.white30,
        child: IconButton(icon: Icon(Icons.pages), onPressed: null),
      )
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
