import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase/Firebase.dart';
import 'package:flutter_app/other/BottomBarNav.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:flutter_app/home.dart';
import 'package:image_cropper/image_cropper.dart';

class UploadPost extends StatefulWidget {

  @override
  _UploadPostState createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var list_img=[];
  var landmark="";
  var urls=[];
  var caption="";
  List<Placemark> placemark=[];
  Position position;
  LocationData locdata;
  Widget serarchwidget=Container();
  Widget linewidget=Container();
  TextEditingController captionController=TextEditingController();



  getlocations() async{

   await Location().hasPermission().then((result){
      if(result != null){
        Location().getLocation().then((loc) async{
          locdata=loc;
          placemark = await Geolocator().placemarkFromCoordinates(loc.latitude,loc.longitude);
          setState(() {
            landmark=placemark[0].name+ " "+placemark[0].locality+" "+ placemark[0].country;
          });
        }).catchError((e){
          print(e.message);
          setState(() {
            landmark="error in getting location";
          });
        });
      }
      else{
        Location().requestPermission().then((result){
          Location().getLocation().then((loc) async{
            locdata=loc;
            placemark = await Geolocator().placemarkFromCoordinates(loc.latitude,loc.longitude);
            setState(() {
              landmark=placemark[0].name+ " "+placemark[0].locality+" "+ placemark[0].country;
            });
          }).catchError((e){
            print(e.message);
            setState(() {
              landmark="error in getting location";
            });
          });
        }).catchError((){
          setState(() {
            landmark="error in getting location";
          });
        });
      }
    }).catchError((e){
      setState(() {
        landmark="error in getting location";
      });
    });
}

  uploadpost() async{

    var time=await DateTime.now();
    String pushid=await FirebaseDatabase.instance.reference().push().key;
    FirebaseUser user=await FirebaseAuth.instance.currentUser();
    Map<String,dynamic> data = Map();
    data["userid"]=user.uid;
    data["id"]=pushid;
    data["hidden"]=false;
    data["images"]=urls;
    data["t_comment"]=0;
    data["t_like"]=0;
    data["u_time"]=time;
    data["t_view"]=0;
    data["t_report"]=0;
    data["caption"] = caption;
    if(landmark!=null && placemark.length>0) {
      data["location"] = landmark.toString();
      data["city"] = placemark[0].locality;
      data["country"] = placemark[0].country;
      data["pincode"] = placemark[0].postalCode;
      data["lat"] = locdata.latitude;
      data["long"] = locdata.longitude;
    }
    else{
      data["location"] ="";
      data["city"] = "";
      data["country"] ="";
      data["pincode"] = "";
      data["lat"] = "";
      data["long"] = "";
    }

    await Firestore.instance.collection("posts").document(pushid).setData(data).then((result){
      Firestore.instance.collection("users").document(user.uid).collection("posts").document(pushid)
          .setData({
           "id":pushid,
            "time":time,
          }).then((resul){
            Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (builder)=>HomeFragment()),(Route<dynamic> route)=>false);
      }).catchError((e){
      });
      }).catchError((e){
      print( e.message);
    });
  }

/*  uploadpostidtohashtags() async{
    if(caption==""){
      return 0;
    }
    else{
      var arry=caption.split(" ");
      arry.forEach((item){
        if(item.substring(0,1)=="_"){
          if(item.substring(1,item.length)=="#"){
          Firestore.instance.collection("hashtags").document(item.substring(1,))
            
          }
          Firestore.instance.collection("hashtags").document();
        }
      });
    }
  }*/

  uploadphotos() async{
    if(list_img.length>0){
    _onLoading();
    for(var i in list_img){
      urls.add(await DataBase().uploadimage(i));
    }
    uploadpost();
  }

  }

  void _onLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        child:Container(
          width: 200.0,
          height: 200.0,
          //decoration: BoxDecoration(color: Colors.white70,borderRadius: BorderRadius.circular(10.0),),
          child: Center(child:FlareActor("flar/progress.flr", alignment:Alignment.center, animation:"Untitled"),),
        )
    );
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getlocations();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body:CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: true,
            expandedHeight:50.0,
            backgroundColor: Colors.white,
            //centerTitle: true,
            elevation:5.0,
            title: Text("Create  Post",style: TextStyle(color: Colors.black),),
            actionsIconTheme: IconThemeData(color: Colors.black),
            leading: IconButton(icon: Icon(Icons.keyboard_backspace,color: Colors.black,), onPressed: ()=>Navigator.pop(context)),
            actions: <Widget>[
              Center(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                    onTap: (){
                      uploadphotos();
                    },
                    child: Text("Share",style: TextStyle(color: Colors.black,fontSize:18.0,fontWeight: FontWeight.bold),)),
              ))
            ],
          ),
          SliverToBoxAdapter(child: Divider(height:1.0 ,)),
          SliverToBoxAdapter(child:
            Row(
              children: <Widget>[
               Flexible(child:Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 20.0),

                 child: Container(
                  // decoration: BoxDecoration(border: BorderDirectional(bottom: BorderSide(color: Colors.grey,width: 1.0))),
                   child: TextField(
                     controller: captionController,
                     onChanged: (val){
                       caption=val;
                       TagHasTag(val);
                     },
                     maxLines: 5,
                     maxLength:250,
                     style: TextStyle(fontWeight: FontWeight.normal,fontSize:15.0),
                     decoration: InputDecoration.collapsed(hintText:"Write a caption here......",hintStyle: TextStyle(fontWeight: FontWeight.normal,fontSize:15.0)),
                   ),
                 ),
               ))
              ],
            ),),
          SliverToBoxAdapter(child:linewidget),
          SliverToBoxAdapter(child: serarchwidget,),
          SliverToBoxAdapter(child: Divider(height: 2.0,),),

        /*  SliverToBoxAdapter(child:   Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Photos :",style: TextStyle(color: Colors.black45,fontSize:15.0,fontWeight: FontWeight.bold),),
          ),),*/

          SliverToBoxAdapter(
            child: Container(
              height: 110.0,
              child: ListView.builder(itemBuilder: (_,index){
                if(index==4){
                  return Container();
                }
                if(list_img.length==index){
                 return GestureDetector(
                    onTap: (){
                      getimages();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical:20.0,horizontal: 10.0),
                      child: Container(
                        height:100.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.blueAccent,width: 0.5),
                        ),
                        child: Center(
                          child: Text("Add Photo",style:TextStyle(color: Colors.blueAccent),),//Icon(Icons.add,color: Colors.blueAccent,size: 50.0,),
                        ),
                      ),
                    ),
                  );
                }
               return Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.black45,width: 0.5),borderRadius: BorderRadius.circular(5.0)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical:5.0),
                              child: Container(height:80.0,width: 100,child: Image.file(list_img[index])),
                            ),
                          ),
                        ),

                        Positioned(
                        right: 0,
                        top: 0,
                            child: GestureDetector(
                        onTap: (){
                          setState(() {
                            list_img.removeAt(index);
                          });
                        }
                        ,child: Icon(Icons.cancel,color: Colors.black45,)))
                      ],
                    )
                  ],
                );
              },itemCount: list_img.length+1,scrollDirection: Axis.horizontal,),
            ),
          ),

          SliverToBoxAdapter(
            child: Divider(height: 1.0,),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0,left: 2.0),
              child: Row(
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Location :",style: TextStyle(color: Colors.black45,fontSize:15.0,fontWeight: FontWeight.bold),),
                    ),
                  ),

                 //Flexible(child: TextField(decoration: InputDecoration.collapsed(hintText: "Search Location"),)),
                 Expanded(child: landmark==""?Container(height:50.0,width: 15.0):Container(child: Text(landmark,style: TextStyle(color: Colors.blueAccent),),),),
                  Padding(
                    padding: const EdgeInsets.only(left:15.0),
                    child: Container(
                      height: 50.0,
                      width: 50.0,
                      child: landmark==""?Center(child:CircularProgressIndicator(),):IconButton(icon:Icon(Icons.add_location,color: Colors.pink,), onPressed: (){
                        setState(() {
                          landmark="";
                        });
                        getlocations();
                      }),
                    ),
                  )
                ],
              ),
            ),
          ),
          

          SliverToBoxAdapter(
            child: SizedBox(height:10.0,),
          ),

          SliverToBoxAdapter(child:
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    uploadphotos();
                  },
                  child: Container(height:50.0,width: 250.0,
                    decoration: BoxDecoration(color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(5.0),
                   ),

                    child: Center(child: Text("Share",style: TextStyle(color: Colors.white,fontSize: 20.0),),),),
                )
              ],
            ),)
        ],
      ),
      bottomNavigationBar: BottomBarNav(2),

    );
  }


  getimages() async {
    return showDialog(context: context,builder: (BuildContext contaxt){
      return   AlertDialog(
        content: Container(
          height: 80.0,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  IconButton(icon: Icon(Icons.sd_storage), onPressed: () async {
                    var image = await ImagePicker.pickImage(source: ImageSource.gallery,maxWidth:1000,maxHeight:1000);
                    if(image!=null){
                      Navigator.pop(context);
                      image=await _cropImage(image);
                      if(image!=null){
                        setState(() {
                          list_img.add(image);
                        });
                      }
                    }
                   // Navigator.pop(context);
                  }),
                  Text("Gallery")
                ],
              ),
              Column(
                children: <Widget>[
                  IconButton(icon: Icon(Icons.camera), onPressed: () async {
                    var image = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 1000,maxHeight:1000);
                    if(image!=null) {
                       image=await _cropImage(image);
                      setState(() {
                        list_img.add(image);
                      });
                    }
                    Navigator.pop(context);
                  }),
                  Text("camera")
                ],
              ),
            ],),
        ),
      );
    });
  }


  Future<File> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath:imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1,ratioY:1),
      maxWidth:1000,
      maxHeight:1000,
    );
    return croppedFile;
  }


  TagHasTag(text){
    var wordlist;
    var cursorPos = captionController.selection;
    print(cursorPos);
    if(text!=""){
      wordlist=text.split(' ');
      if(wordlist!=""){
       var word=wordlist[wordlist.length-1];
        if(word.length>1){
          print(word);

          if(word.substring(0,1)=="@"){
            print(word.substring(1,word.length));
             FirebaseDatabase.instance.reference().child("users").orderByChild("username").startAt(word.substring(1,word.length))
                .endAt(word.substring(1,word.length)+"\uf8ff").limitToFirst(50).once().then((DataSnapshot val){
                print(val.value);
                var list=[];
                if(val.value!=null){
                  for (var i in val.value.values){
                    list.add(i);
                  }
                  setState(() {
                    linewidget=Divider(height: 1.0,);
                    serarchwidget=Container(height: 80.0,
                    child: Column(children: <Widget>[
                      Row(mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[

                          Container(height: 30.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Searching For"+":  '"+word+"'"),
                          ),),
                        ],
                      ),
                      Container(
                          color: Colors.white,
                          height:45.0,
                          child:
                          ListView.builder(itemBuilder:(_,index){
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: (){
                                  var text=captionController.text;
                                  var text2=text.replaceAll(word,"@"+list[index]["username"]+" ");
                                  print(text);
                                  captionController.text=text2;
                                  setState(() {
                                    var cursorPos = captionController.selection;
                                    cursorPos = new TextSelection.fromPosition(
                                        new TextPosition(offset: captionController.text.length));
                                    print(cursorPos);
                                    captionController.selection = cursorPos;
                                    serarchwidget=Container();
                                    linewidget=Container();
                                  });
                                },
                                child: Container(
                                    decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 1.0),
                                        borderRadius: BorderRadius.circular(2.0)
                                    )
                                    ,child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 20.0),
                                  child: Text("@"+list[index]["username"],style: TextStyle(color: Colors.pink,fontWeight: FontWeight.bold),),
                                )),
                              ),
                            );
                          },itemCount:list.length,scrollDirection: Axis.horizontal,)
                      ),
                    ],)
                    );
                  });
                }
                else{
                  setState(() {
                    serarchwidget=Container();
                    linewidget=Container();
                  });
                }
             });
             }




          else if(word.substring(0,1)=="#"){
            var list=[];

            FirebaseDatabase.instance.reference().child("hashtag").orderByChild("username").startAt(word.substring(1,word.length))
                .endAt(word.substring(1,word.length)+"\uf8ff").limitToFirst(50).once().then((DataSnapshot val){
              print(val.value);

              if(val.value!=null){
                for (var i in val.value.values){
                  list.add(i);
                }
                setState(() {
                  linewidget=Divider(height: 1.0,);
                  serarchwidget=Container(height: 90.0,
                      child: Column(children: <Widget>[
                        Row(mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(height: 30.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Searching For"+":  '"+word+"'"),
                              ),),
                          ],
                        ),
                        Container(
                            color: Colors.white,
                            height:45.0,
                            child:
                            ListView.builder(itemBuilder:(_,index){
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: (){
                                    var text=captionController.text;
                                    var text2=text.replaceAll(word,"#"+list[index]["username"]+" ");
                                    print(text);
                                    captionController.text=text2;
                                    setState(() {
                                      var cursorPos = captionController.selection;
                                      cursorPos = new TextSelection.fromPosition(
                                          new TextPosition(offset: captionController.text.length));
                                      captionController.selection = cursorPos;
                                      serarchwidget=Container();
                                      linewidget=Container();
                                    });
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 1.0),
                                          borderRadius: BorderRadius.circular(2.0)
                                      )
                                      ,child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 20.0),
                                    child: Text("@"+list[index]["username"],style: TextStyle(color: Colors.pink,fontWeight: FontWeight.bold),),
                                  )),
                                ),
                              );
                            },itemCount:list.length,scrollDirection: Axis.horizontal,)
                        ),
                      ],)
                  );
                });
              }
              else{
                list.add({"username":word.substring(1,word.length)});
                setState(() {
                  linewidget=Divider(height: 1.0,);
                  serarchwidget=Container(height: 90.0,
                      child: Column(children: <Widget>[
                        Row(mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[

                            Container(height: 30.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Searching For"+":  '"+word+"'"),
                              ),),
                          ],
                        ),
                        Container(
                            color: Colors.white,
                            height:45.0,
                            child:
                            ListView.builder(itemBuilder:(_,index){
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: (){
                                    var text=captionController.text;
                                    var text2=text.replaceAll(word,"#"+list[index]["username"]+" ");
                                    print(text);
                                    captionController.text=text2;
                                    setState(() {
                                      var cursorPos = captionController.selection;
                                      cursorPos = new TextSelection.fromPosition(
                                          new TextPosition(offset: captionController.text.length));
                                      captionController.selection = cursorPos;
                                      serarchwidget=Container();
                                      linewidget=Container();
                                    });
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 1.0),
                                          borderRadius: BorderRadius.circular(2.0)
                                      )
                                      ,child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 20.0),
                                    child: Text("#"+list[index]["username"],style: TextStyle(color: Colors.pink,fontWeight: FontWeight.bold),),
                                  )),
                                ),
                              );
                            },itemCount:list.length,scrollDirection: Axis.horizontal,)
                        ),
                      ],)
                  );
                });
              }
            });
          }
        }else{
          setState(() {
            serarchwidget=Container();
            linewidget=Container();
          });
        }
      }
      else{
        setState(() {
          serarchwidget=Container();
        });
      }
    }
    else{
      setState(() {
        serarchwidget=Container();
        linewidget=Container();
      });
    }
  }



}
