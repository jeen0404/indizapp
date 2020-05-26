import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class Webviews extends StatelessWidget {
  var link;
  Webviews(id){
    this.link=id;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:   WebView(
        initialUrl:"https://indiz.xyz/",
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
