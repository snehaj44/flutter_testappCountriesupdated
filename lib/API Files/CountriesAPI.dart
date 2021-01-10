import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter_testapp/Model/Articles.dart';
import 'package:flutter_testapp/Model/Articlesjson.dart';
import 'package:flutter_testapp/Model/Countries.dart';
import 'package:flutter_testapp/Model/languages.dart';
import 'package:flutter_testapp/Resources/Sharedprefernces.dart';
import 'package:http/http.dart' as http;
import 'config.dart';



Future<List<Countries>> getCountries() async {
  HttpClient httpClient = new HttpClient();

  HttpClientRequest request = await httpClient.getUrl(
      Uri.parse(Countries_API_URL));
  request.headers.set('Content-type', 'application/json');

  // request.add(utf8.encode(json.encode(body)));
  HttpClientResponse response = await request.close();
  httpClient.close();
  // final response = await http.get(API_URL+'Products/getCatProducts/'+cid);

  List<Countries> pList = [];

  if (response.statusCode == 200) {
    //final data = jsonDecode(response.toString());
    var reply = await response.transform(utf8.decoder).join();
    setData("Countries_DATA",jsonEncode(reply));

    print("See reply");
    print(reply);
    var jdata = jsonDecode(reply);

    print("See jdata");
    print(jdata);
    String langname;
    for(var details in jdata){
      String cname = details['name'];
      String ccode = details['alpha3Code'];
      String creg = details['region'];
      String ccapital = details['capital'];
      var cborder = details['borders'];

      var langdetails = details['languages'];
      List<String> lList = [];
      //for (var details in thumbdata) {
      if(langdetails!=null) {
        for(var lang in langdetails) {
          String langname = lang['name'];
          lList.add(langname);
        }
      }
      String flagimg = details['flag'];
print("See lang");
print(lList.toString());

      pList.add(Countries(region: creg, countryname: cname, capitalname: ccapital, languages: lList.toString(), flagimage: flagimg, countrycode: ccode, borders: cborder.toString()));

    }
  }
    // }

    return pList;
  //}
}
