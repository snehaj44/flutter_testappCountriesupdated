import 'package:flutter/cupertino.dart';

class Articles {
  final int pageid;
  final String pagedescription;
  final String pagetitle;
  final int imagewidth;
  final int imageheight;
  final String imageurl;

  Articles({
    @required this.pageid, @required this.pagedescription, @required this.pagetitle, @required this.imageheight, @required  this.imageurl,
    @required this.imagewidth,

  });
}
