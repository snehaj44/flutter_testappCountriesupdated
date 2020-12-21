import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter_testapp/Model/Articles.dart';
import 'package:flutter_testapp/Model/Articlesjson.dart';
import 'package:flutter_testapp/Resources/Sharedprefernces.dart';
import 'package:http/http.dart' as http;
import 'config.dart';



Future<List<Articles>> getArticles() async {
  HttpClient httpClient = new HttpClient();

  HttpClientRequest request = await httpClient.getUrl(
      Uri.parse(Article_API_URL));
  request.headers.set('Content-type', 'application/json');

  // request.add(utf8.encode(json.encode(body)));
  HttpClientResponse response = await request.close();
  httpClient.close();
  // final response = await http.get(API_URL+'Products/getCatProducts/'+cid);

  List<Articles> pList = [];
  if (response.statusCode == 200) {
    String reply = await response.transform(utf8.decoder).join();
    setData("ARTICLE_DATA",jsonEncode(reply));
    var jdata = jsonDecode(reply);

    var qdata = jdata['query'];
    int imgheight ;
    int imgwidth ;
    String imageurl ,desc;
   // for (var pagedetails in qdata) {
      var pagedata = qdata['pages'];
      for (var details in pagedata) {



        imgheight = 0;
        imgwidth = 0;
        imageurl = "";

        int id = details[pageid];
       String name = details[title];

        var thumbdata = details['thumbnail'];
        //for (var details in thumbdata) {
        if(thumbdata!=null) {
           imgheight = thumbdata[imageheight];
           imgwidth = thumbdata[imagewidth];
           imageurl = thumbdata[imageurls];
        }
        //}
        var termsdata = details['terms'];
        // for (var details in termsdata) {
      //  var  desc = termsdata[description];
        if(termsdata!=null) {
         desc = jsonEncode(termsdata[description]);
       //  desc = desc.replaceAll("\\p{P}","");
       }


        pList.add(Articles(imageheight: imgheight,
            imageurl: imageurl,
            imagewidth: imgwidth,
            pagedescription: desc,
            pageid: id,
            pagetitle: name));
      }
   // }

    return pList;
  }
}
