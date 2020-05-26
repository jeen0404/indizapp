import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';




class SelectImage extends StatefulWidget {
  @override
  _SelectImageState createState() => _SelectImageState();
}

class _SelectImageState extends State<SelectImage> {
  CameraController controller;
  List<CameraDescription> cameras;


  Future<CameraController> getavailablecamera() async{
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print(e.code +"--"+ e.description);
    }
    print(cameras.toString());
    controller = CameraController(cameras[0], ResolutionPreset.high);

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    return  controller;
  }

  @override
  void initState() {
    super.initState();
   getavailablecamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     if (!controller.value.isInitialized) {
      return Container(color: Colors.pink,);
    }
    return CameraPreview(controller,);
  }

}