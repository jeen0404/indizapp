import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DataBase{

  //m_Ath is for user auth_data
  //mean uid
  var _mAuth=FirebaseAuth.instance;
  var _mDatabase=FirebaseDatabase.instance;
  var _mFirestore=Firestore.instance;
  var _mstorage=FirebaseStorage.instance;
  FirebaseUser _user;
  DateTime time=DateTime.now();


  Future<FirebaseUser> getcurruntuser() async{
    return await FirebaseAuth.instance.currentUser();
  }
  
  // getting user profile data
  //it will return whole profile data fields
  Future<DocumentSnapshot> myProfileData()async {
    _user=await getcurruntuser();
    return await _mFirestore.collection("users").document(_user.uid).get()
        .then((DocumentSnapshot dq){
       return dq;   
    }).catchError((e){
      print("--MYOROFILEDATA--: "+e.message);
      return null;
    });
  }
  
  
  
  // getting some other user data profile data
  //it will return whole profile data fields
  Future<DocumentSnapshot> otherUserData(otherUserId)async {
    _user=await getcurruntuser();
    return await _mFirestore.collection("users").document(otherUserId).get()
        .then((DocumentSnapshot dq){
      return dq;
    }).catchError((e){
      print("FIREBASE CLASS--MYOROFILEDATA--ERROR: "+e.message);
      return null;
    });
}




// check follow
  Future<String> CheckFollow(otheruserid) async{
    var f_f_text;
    var user =await FirebaseAuth.instance.currentUser();
    return  await Firestore.instance.collection("Follow").where('userid',isEqualTo: user.uid).where('follow',isEqualTo:otheruserid).
    getDocuments().then((result){
      if(result.documents.length > 0 ){
        if(result.documents[0].data["status"]==0)
        {
          return f_f_text="Message";
        }
        else if(result.documents[0].data["status"]==1){
          return  f_f_text="Requested";
        }
        else if(result.documents[0].data["status"]==2){
          return f_f_text="Blocked";
        }
      }
      else{
        return f_f_text="Follow";
      }
    }).catchError((e){
      print(e.message);
      return f_f_text="Follow";
    });
  }

// when you starting follow some one...
  //this method is called and data will be writes to other user
  //following or request list depend on other user privacy
  // ignore: non_constant_identifier_names
  Future<String> follow(otheruserid,private,text) async{
    var pushid=await FirebaseDatabase.instance.reference().push().key;
    var f_f_text=text;
    var user=await FirebaseAuth.instance.currentUser();
    var time=DateTime.now().toString();
    if(f_f_text=="Follow"){
      if(!private){
        f_f_text="Message";
        await Firestore.instance.collection("Follow").document(pushid).setData({
          "userid":user.uid,
          "follow":otheruserid,
          "time":time,
          "status":0,
          "push_id":pushid,
        });
        return f_f_text;
      }

      else{
        f_f_text="Requested";
        await Firestore.instance.collection("Follow").add({
          "userid":user.uid,
          "follow":otheruserid,
          "time":time,
          "status":1,
          "push_id":pushid,
        });
        return f_f_text;
      }
    }
    else if(f_f_text=="Requested" || f_f_text=="Following"){
      f_f_text="Follow";
      await Firestore.instance.collection("Follower").where('userid',isEqualTo: user.uid).where('follow',isEqualTo:otheruserid)
          .getDocuments().then((val){
        Firestore.instance.collection("Follower").document(val.documents[0].data["push_id"]);
      });
      return f_f_text;
    }
  }


  // when you Unfollow Some one some one...
  //this method is called and data will be writes to other user
  //following or request list depend on other user privacy
  // ignore: non_constant_identifier_names
  Future<String> unfollow(otheruserid) async{
    var user=await FirebaseAuth.instance.currentUser();
    var f_f_text="Follow";
    await Firestore.instance.collection("Follow").where('userid',isEqualTo: user.uid).where('follow',isEqualTo:otheruserid)
        .getDocuments().then((val){
      Firestore.instance.collection("Follow").document(val.documents[0].data["push_id"]).delete();
    });
    return f_f_text;
  }

  // check crush
  Future<String> CheckCrush(otheruserid) async{
    var f_f_text;
    var user =await FirebaseAuth.instance.currentUser();
    return  await Firestore.instance.collection("crush").where('userid',isEqualTo: user.uid).where('crushon',isEqualTo:otheruserid).
    getDocuments().then((result){
      if(result.documents.length > 0 ){
        if(result.documents[0].data["status"]==0)
        {
          return f_f_text="Remove From Crush List";
        }
        else if(result.documents[0].data["status"]==1){
          return  f_f_text="Requested";
        }
        else if(result.documents[0].data["status"]==2){
          return f_f_text="Blocked";
        }
      }
      else{
        return f_f_text="Add To Crush List";
      }
    }).catchError((e){
      print(e.message);
      return f_f_text="Add To Crush List";
    });
  }


  Future<String> addCrush(otheruserid,private,text) async{
    var pushid=await FirebaseDatabase.instance.reference().push().key;
    var f_f_text=text;

    var user=await FirebaseAuth.instance.currentUser();
    var time=DateTime.now().toString();
    if(f_f_text=="Add To Crush List"){
      if(!private){
        f_f_text="Remove From Crush List";
        await Firestore.instance.collection("crush").document(pushid).setData({
          "userid":user.uid,
          "crushon":otheruserid,
          "time":time,
          "status":0,
          "push_id":pushid,
        });
        return f_f_text;
      }

      else{
        f_f_text="Requested";
        await Firestore.instance.collection("crush").add({
          "userid":user.uid,
          "crushon":otheruserid,
          "time":time,
          "status":1,
          "push_id":pushid,
        });
        return f_f_text;
      }
    }
    else if(f_f_text=="Requested" || f_f_text=="Remove From Crush List"){
      f_f_text="Add To Crush List";
      await Firestore.instance.collection("crush").where('userid',isEqualTo: user.uid).where('crushon',isEqualTo:otheruserid)
          .getDocuments().then((val){
        Firestore.instance.collection("crush").document(val.documents[0].data["push_id"]).delete();
      });
      return f_f_text;
    }
  }



  // check crush
  Future<String> CheckSecretCrush(otheruserid) async{
    var f_f_text;
    var user =await FirebaseAuth.instance.currentUser();
    return  await Firestore.instance.collection("secretcrush").where('userid',isEqualTo: user.uid).where('secretcrushon',isEqualTo:otheruserid).
    getDocuments().then((result){
      if(result.documents.length > 0 ){
        if(result.documents[0].data["status"]==0)
        {
          return f_f_text="Remove From SecretCrush List";
        }
        else if(result.documents[0].data["status"]==1){
          return  f_f_text="Requested";
        }
        else if(result.documents[0].data["status"]==2){
          return f_f_text="Blocked";
        }
      }
      else{
        return f_f_text="Add To SecretCrush List";
      }
    }).catchError((e){
      print(e.message);
      return f_f_text="Add To SecretCrush List";
    });
  }
  Future<String> addSecretCrush(otheruserid,private,text) async{
    var pushid=await FirebaseDatabase.instance.reference().push().key;
    var f_f_text=text;

    var user=await FirebaseAuth.instance.currentUser();
    var time=DateTime.now().toString();
    if(f_f_text=="Add To SecretCrush List"){
      if(!private){
        f_f_text="Remove From SecretCrush List";
        await Firestore.instance.collection("secretcrush").document(pushid).setData({
          "userid":user.uid,
          "secretcrushon":otheruserid,
          "time":time,
          "status":0,
          "push_id":pushid,
        });
        return f_f_text;
      }

      else{
        f_f_text="Requested";
        await Firestore.instance.collection("secretcrush").add({
          "userid":user.uid,
          "secretcrushon":otheruserid,
          "push_id":pushid,
          "time":time,
          "status":1,
        });
        return f_f_text;
      }
    }
    else if(f_f_text=="Requested" || f_f_text=="Remove From SecretCrush List"){
      f_f_text="Add To SecretCrush List";
      await Firestore.instance.collection("secretcrush").where('userid',isEqualTo: user.uid).where('secretcrushon',isEqualTo:otheruserid)
          .getDocuments().then((val){
        Firestore.instance.collection("secretcrush").document(val.documents[0].data["push_id"]).delete();
      });
      return f_f_text;
    }
  }


  Future<void> RemoveCrushOnyou(otheruserid) async{
    var user=await FirebaseAuth.instance.currentUser();
     Firestore.instance.collection("crush").where("userid",isEqualTo:otheruserid).where("crushon",isEqualTo: user.uid)
        .getDocuments()
        .then((QuerySnapshot qn){
      Firestore.instance.collection("crush").document(qn.documents[0].data["push_id"]).delete();
    });
  }

  Future<void> RemoveFollowOnyou(otheruserid) async{
    var user=await FirebaseAuth.instance.currentUser();
     Firestore.instance.collection("Follow").where("userid",isEqualTo:otheruserid).where("follow",isEqualTo: user.uid)
        .getDocuments()
        .then((QuerySnapshot qn){
      Firestore.instance.collection("Follow").document(qn.documents[0].data["push_id"]).delete();
    });
  }





  Future<DocumentSnapshot> getPostData(postid) async{
    return await _mFirestore.collection("posts").document(postid)
        .get().then((DocumentSnapshot dq){
       return dq;
    }).catchError((e){
      print("FIREBASE CLASS--GETPOSTDATA--ERROR: "+e.message);
      return null;
    });
    
  }

  //upload image
  Future<String> uploadimage(var img) async{
    _user=await _mAuth.currentUser();
    var pushid= await _mDatabase.reference().push().key;
    var ref=_mstorage.ref().child("postsimg").child(_user.uid).child(pushid+".jpg");
    final StorageUploadTask uploadTask = ref.putFile(img);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    return url;
  }









}