import 'dart:core';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class UploadProfilePhoto extends StatefulWidget {

  @override
  _UploadProfilePhotoState createState() => _UploadProfilePhotoState();
}

class _UploadProfilePhotoState extends State<UploadProfilePhoto> {
  static const platform = const MethodChannel('samples.flutter.io/imagelist');

  var _image;
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }



  List imgs;
  var progress=true;


  @override
  void initState() {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: progress==true?Container(child: Center(child: CircularProgressIndicator(),),):
      ListView.builder(itemBuilder:(_,index){
        return Row(
          children: <Widget>[
            Container(height: 100.0,width:100.0,child: Image.file(File(imgs[index][""]))),
          ],
        );

      },itemCount: imgs.length,),
    );
  }
}