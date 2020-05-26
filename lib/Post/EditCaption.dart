import 'package:flutter/material.dart';


class EditCaption extends StatefulWidget {

  var postdata;
  var userdata;

  EditCaption(this.postdata,this.userdata){}
  @override
  _EditCaptionState createState() => _EditCaptionState(this.postdata,this.userdata);
}

class _EditCaptionState extends State<EditCaption>  with AutomaticKeepAliveClientMixin {
  var postdata;
  var userdata;
  _EditCaptionState(this.postdata,this.userdata){}



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: CustomScrollView(
        slivers: <Widget>[


          SliverAppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: IconButton(icon: Icon(Icons.keyboard_backspace,color: Colors.black,), onPressed:(){Navigator.pop(context);}),
            title: Row(
              children: <Widget>[
                Container(
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(color: Colors.black,width:0.20)),
                    child: CircleAvatar(radius:14.0,backgroundImage: NetworkImage(userdata.data["img_url"]),)),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                    Text(userdata.data["name"],style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 14.0),),
                  ],),
                )
              ],

            ),
            actions: <Widget>[
              //  IconButton(icon: Icon(Icons.more_vert,color: Colors.black,), onPressed: null)
            ],
          ),





        ],

      ),

    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive =>true;
}
