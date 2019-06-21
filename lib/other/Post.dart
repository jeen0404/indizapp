
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transparent_image/transparent_image.dart';
class Post extends StatefulWidget {
  var postid;
  Post(var postid){
    this.postid=postid;
  }
  @override
  _PostState createState() => _PostState(this.postid);
}

class _PostState extends State<Post> {


  _PostState(var postid){
    this.postid=postid;

  }

  var userdata;
  var postid;
  var post_u_profile_img;
  var post_u_name;
  var post_u_username;
  var user_id;

  var location;
  var hidden;
  var t_likes_on_post;
  var t_comments_on_post;
  var upload_time;
  var comments;
  var comments_time;
   var progress=true;
   //=["https://thetempest-co.exactdn.com/wp-content/uploads/2018/07/Feature-image.jpg"];


  ///
  var like_icon=Icons.favorite_border;
  var like=false;
  var dbref=FirebaseDatabase.instance.reference();

  Future<void> getuserdata() async{
        await dbref.child("posts").child(postid).once()
        .then((result){
      location=result.value["location"];
      hidden=result.value["hidden"];
      t_likes_on_post=result.value["t_likes"].toString();
      t_comments_on_post=result.value["t_comments"].toString();
      user_id=result.value["user_id"];
      upload_time=result.value["time"].toString();
      return;
    });

  }

 getpostdata() async{
    await getuserdata();
    await Firestore.instance.collection("users").document(user_id).get()
        .then((result){
        userdata=result.data;
        post_u_profile_img=result.data["img_url"];
        post_u_name=result.data["name"];
        post_u_username=result.data["name"];

    }).catchError((e){
      print(e.message);
    });
    await dbref.child("posts").child(postid).child("comments").orderByChild("id").equalTo(user_id).limitToFirst(1).once()
    .then((data){
        comments =data.value[1]["comment"];
        comments_time =data.value[1]["time"];
    });
    setState(() {
      progress=false;
    });
  }

  @override
  void initState() {
    super.initState();
    getpostdata();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: progress==true?Container(height: 500.0,child: Center(child: CircularProgressIndicator(),) ,): Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 10.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 10.0,),
                Container(height:40.0,width:
                40.0,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0),
                      boxShadow: [BoxShadow(color: Colors.black26,spreadRadius: 0.0,blurRadius:1.0)],
                      image: DecorationImage(image: NetworkImage("http://sf.co.ua/17/01/wallpaper-6f749.jpg"),fit:BoxFit.cover)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(post_u_name,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18.0),),
                      SizedBox(height:5.0,),
                      Text(location,style: TextStyle(color: Colors.black26,fontWeight: FontWeight.bold,fontSize: 12.0),)
                    ],
                  ),
                ),
                Expanded(child: Container()),
                Column(
                  children: <Widget>[
                    SizedBox(height:20.0,),
                    Text(upload_time,style: TextStyle(color: Colors.black26,fontWeight: FontWeight.bold,fontSize: 12.0),)
                  ],
                ),
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(top:5.0,bottom: 5.0          ),
                child: Stack(
                  children: <Widget>[
                    Container(
                        height: 400.0,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          //  boxShadow: [BoxShadow(color: Colors.black26,spreadRadius: 0.0,blurRadius:2.0)],
                          // image: DecorationImage(image:  NetworkImage(profile_url),fit: BoxFit.cover)
                        ),
                        child:FutureBuilder(builder: (_,snapshot){
                          if(snapshot.connectionState==ConnectionState.waiting){
                            return Center(child: CircularProgressIndicator());
                          }
                          else{
                            return ListView.builder(itemBuilder: (_,index){
                              return Padding(
                                padding: const EdgeInsets.only(right:2.0),
                                child: FadeInImage.memoryNetwork(
                                    placeholder:kTransparentImage,
                                    image: snapshot.data.value[index]
                                ),
                              );/*Image(image: NetworkImage(snapshot.data.value[index]),);*/

                            },itemCount:snapshot.data.value.length,scrollDirection:Axis.horizontal,);
                          }
                        },future:dbref.child("posts").child(postid).child("images").reference().once(),)
                    ),

                  ],
                )
            ),
            //ssssssss  Container(height: 1.0,color: Colors.black12,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width:10.0,),
                  like_widget(postid,t_likes_on_post,user_id),
                  SizedBox(width: 10.0,),
                  Icon(Icons.crop_square,color:Colors.orange,),
                  SizedBox(width:5.0,),
                  Text(t_comments_on_post,style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 18.0),),
                  Expanded(child: Container()),
                  Icon(Icons.turned_in_not,color: Colors.blue,),
                  SizedBox(width: 10.0,),
                  Icon(Icons.share,color: Colors.purple,size: 18.0,),
                  SizedBox(width: 10.0,),
                  Icon(Icons.more_horiz),
                  SizedBox(width: 10.0,),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom:20.0,left: 15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  //   Text("@"+post_u_name+" :",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                  Expanded(
                    child: Container(child: RichText(text: TextSpan(children: [
                      TextSpan(text:"@"+post_u_username+": ",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold)),
                      TextSpan(text:comments,style:TextStyle(color: Colors.black26,fontSize:12.0)),
                    ]))),
                  ),
                  //Expanded(child:Container()),
                  //  Text(comments_time,style: TextStyle(color: Colors.black26),)
                ],
              ),
            )
            //   Container(height: 1.0,color: Colors.black12,)
          ],
        ),
      ),
    );
  }
}



class like_widget extends StatefulWidget {
  var postid,t_likes,user_id;
  like_widget(var postid,t_likes,id){
    this.postid=postid;
    this.t_likes=t_likes;
    this.user_id=id;
  }
  @override
  _like_widgetState createState() => _like_widgetState(this.postid,this.t_likes,this.user_id);
}
class _like_widgetState extends State<like_widget> {
   var post_id,t_likes,user_id;
  _like_widgetState(var poostid,t_likes,id){
    this.post_id=poostid;
    this.t_likes=t_likes;
    this.user_id=id;
  }

  var like_icon=Icons.favorite_border;
  var like=false;



@override
  void initState() {
    // TODO: implement initState
  var dbref=FirebaseDatabase.instance.reference().child("posts").child(post_id).reference();
  dbref.child("likes").orderByChild("id").equalTo(user_id).reference().once()
  .then((val){
    if(val.value != null){
      setState(() {
        like=true;
        like_icon=Icons.favorite;
      });

    }
  });
  }

  @override
  Widget build(BuildContext context) {
    var dbref=FirebaseDatabase.instance.reference().child("posts").child(post_id).reference();
    return  Row(
      children: <Widget>[
        IconButton(icon:Icon(like_icon,color: Colors.pink,), onPressed: (){
          if(like == true){
            dbref.child("t_likes").once().then((val){
              setState(() {
                like_icon=Icons.favorite_border;
                like=false;
               // t_likes=t_likes-1;
              });
              dbref.update({"t_likes":int.parse(t_likes)-1});
              dbref.child("likes").orderByChild("id").equalTo(user_id).reference().remove();
            });

          }else{
            dbref.child("t_likes").once().then((val){
              setState(() {
                like_icon=Icons.favorite;
                like=true;
                //t_likes=t_likes-1;
              });
              dbref.update({"t_likes":int.parse(t_likes) + 1});
              var time=TimeOfDay.now().toString();
              dbref.child("likes").child(dbref.push().key).set({"id":user_id,"time":time}).then((val){
              });
            });
          }
        }),
        Text(t_likes,style: TextStyle(color: Colors.pink),)
      ],
    );


  }
}



