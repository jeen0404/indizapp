import 'package:flutter/material.dart';

class AccountVerification extends StatefulWidget {
  @override
  _AccountVerificationState createState() => _AccountVerificationState();
}

class _AccountVerificationState extends State<AccountVerification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: Colors.white,
          centerTitle:true,
          iconTheme: IconThemeData(color: Colors.black45),
          title: Text("About",style: TextStyle(color: Colors.blueAccent),),
          leading: IconButton(icon: Icon(Icons.arrow_back,), onPressed: (){
            Navigator.pop(context);
          }),

        ) ,

        body:CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child:  Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("""----------"""),
                ),
              ),
            )
          ],
        )
    );
  }
}
