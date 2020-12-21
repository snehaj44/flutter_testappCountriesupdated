import 'package:flutter/material.dart';
import 'package:flutter_testapp/API%20Files/config.dart';
import 'package:flutter_testapp/style/Textstyle.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class WikipediaExplorer extends StatefulWidget {
  final String gettitle;
  const WikipediaExplorer(this.gettitle);
  @override
  _WikipediaExplorerState createState() => _WikipediaExplorerState(gettitle);
}

class _WikipediaExplorerState extends State<WikipediaExplorer> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  final Set<String> _favorites = Set<String>();
  final String gettitle ;

  _WikipediaExplorerState(this.gettitle);
  @override
  Widget build(BuildContext context) {
    var uri = WIKI_URL + gettitle;
    var encoded = Uri.encodeFull(uri);
    return Scaffold(
      appBar: AppBar(
        title: Text(gettitle),
        backgroundColor: mainStyle.mainColor,
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.

      ),
      body: WebView(

        initialUrl: encoded ,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),

    );
  }
}