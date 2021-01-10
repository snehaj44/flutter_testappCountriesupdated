import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter_testapp/Model/Articles.dart';
import 'package:flutter_testapp/Model/Articlesjson.dart';
import 'package:flutter_testapp/Model/Countries.dart';
import 'package:flutter_testapp/Model/Regions.dart';
import 'package:flutter_testapp/Resources/Sharedprefernces.dart';
import 'package:http/http.dart' as http;
import 'package:kt_dart/collection.dart';
import 'config.dart';



Future<List<Regions>> getRegions() async {
  HttpClient httpClient = new HttpClient();

  HttpClientRequest request = await httpClient.getUrl(
      Uri.parse(Countries_API_URL));
  request.headers.set('Content-type', 'application/json');

  // request.add(utf8.encode(json.encode(body)));
  HttpClientResponse response = await request.close();
  httpClient.close();
  // final response = await http.get(API_URL+'Products/getCatProducts/'+cid);

  List<Regions> pList = [];
  if (response.statusCode == 200) {
    //final data = jsonDecode(response.toString());
    var reply = await response.transform(utf8.decoder).join();
    setData("Countries_DATA",jsonEncode(reply));

    print("See reply");
    print(reply);
    var jdata = jsonDecode(reply);



    for(var details in jdata){

      String creg = details['region'];

      // var langdetails = details['languages'];
      // //for (var details in thumbdata) {
      // if(langdetails!=null) {
      //   for(var lang in langdetails) {
      //     langname = lang['name'];
      //   }
      // }


      pList.add(Regions(regions: creg));
    }
  }
  // }

  return pList;
  //}
}
