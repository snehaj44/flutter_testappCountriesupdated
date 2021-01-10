import 'package:flutter/cupertino.dart';

class Countries {

  final String id;
  final String region;
  final String countryname;
  final String capitalname;
  final String languages;
  final String flagimage;
  final String countrycode;
  final String borders;
  bool operator ==(Object other) => identical(this, other) || (other as Countries).id == id;

  int get hashCode => id.hashCode;
  Countries({
    @required this.region, @required this.countryname, @required this.capitalname, @required this.languages, @required  this.flagimage,
    @required this.countrycode,@required this.borders,@required this.id,

  });
}
