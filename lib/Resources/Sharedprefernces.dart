import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future setData (String key,String val) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString(key, val);
}

Future<String> getData(key) async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  String val = pref.getString(key);
  return val;
}