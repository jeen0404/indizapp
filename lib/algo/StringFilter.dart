import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/HashTag/Hashtagprofileview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../OtherUserProfile.dart';



class StringFilter extends StatefulWidget {

  var text=[];  // string thar user want to show in ui.. string can be raw string, web_like , username or can be #tags
  // ignore: non_constant_identifier_names
  var style;  // default text style for whole string
  // ignore: non_constant_identifier_names
  var username_style; // username text style that or words that start with character @
  // ignore: non_constant_identifier_names
  var hash_tags_style;  // hash tags .// string text style
  // ignore: non_constant_identifier_names
  var link_style;  // web link string text style
   // ignore: non_constant_identifier_names


StringFilter({
  text="",
  post="",
  style=const TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize:12.0),
  username_style=const TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 12.0) ,
  hash_tags_style=const TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 12.0),
  link_style=const TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.normal,fontStyle: FontStyle.italic,fontSize: 12.0)}){
  this.text=text.split(' ');
  this.style=style;
  this.username_style=username_style;
  this.hash_tags_style=hash_tags_style;
  this.link_style=link_style;
}

  @override
  _StringFilterState createState() => _StringFilterState();
}

class _StringFilterState extends State<StringFilter> {


  _hadalclickforusername(word){
    print(word);
      Firestore.instance.collection("users").where("username",isEqualTo: word.substring(1,word.length))
          .getDocuments().then((QuerySnapshot qn){
        if(qn.documents.length!=0){
          Navigator.push(context, MaterialPageRoute(builder: (builder)=> OtherUserProfile(qn.documents[0].data["uid"])));
        }
      });

  }

  _hadaleLinkclick(word){
      _launchURL(word);
  }

  _handalehashtagclick(String word) async{
      Navigator.push(context, MaterialPageRoute(builder: (builder)=> HashTagProfileView(word.substring(1,word.length))));

  }

  _launchURL(urls) async {
    String url = urls;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //tapGestureRecognizer_for_username.onTap();
  }


List<TextSpan> printstring(){
List<TextSpan> result=[];
   widget.text.forEach(( word){
    if(word.length==1){
      result.add(TextSpan(text: word));
    }
    else if(word.length>1){
        if(word.substring(0,1)=="@"){
          result.add(TextSpan(text:" "+ word,style: widget.username_style,recognizer: TapGestureRecognizer()..onTap=
          (){
            _hadalclickforusername(word);
          }));
        }
        else if(word.substring(0,1)=="#"){
          result.add(TextSpan(text:" "+ word,style: widget.hash_tags_style,recognizer: TapGestureRecognizer()..onTap=
          (){
            _handalehashtagclick(word);
          }));
        }
        else if(word.length>4){
          if(word.substring(0,4)=="http"){
            result.add(TextSpan(text:" "+word,style: widget.link_style,recognizer:TapGestureRecognizer()..onTap=
                (){
              _hadaleLinkclick(word);
                }));
          }
          else{
            result.add(TextSpan(text:" "+word));
          }
        }
        else{
          result.add(TextSpan(text:" "+ word));
        }

    }
    else{
      result.add(TextSpan(text: word));
    }
  });
   return result;
  //return TextSpan(text: username,style: username_style);
}





String word;

  @override
  Widget build(BuildContext context) {
   //return RichText(text: TextSpan(children: printstring()),);
     return RichText( text:TextSpan(style: widget.style,children: printstring()) );
  }
}
