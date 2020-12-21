import 'dart:collection';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_testapp/style/Textstyle.dart';
class ImageView extends StatefulWidget {
  String thumb;

  ImageView(this.thumb);

  @override
  _ImageViewState createState() => _ImageViewState(thumb);
}

class _ImageViewState extends State<ImageView> {
  String thumb;

  _ImageViewState(this.thumb);


  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: thumb,
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.0),
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.close,
                  size: 35.0,
                  color: mainStyle.mainColor,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: FutureBuilder(
                future: getImgArray(jsonDecode(thumb)),
                builder: (context,snapshot){
                  if(snapshot.hasData){
                    List iList = snapshot.data;
                    return CarouselSlider.builder(
                        options: CarouselOptions(
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 5),
                        ),
                        itemCount: iList.length,
                        itemBuilder: (context,i){
                          return Image(
                            image: NetworkImage(iList[i]),
                            fit: BoxFit.fill,
                          );
                        });
                  }
                  return SizedBox(height: 10.0,);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


Future<List> getImgArray(imgArray) async {
  List iList = [];
  await imgArray.forEach((item){
    iList.add(item);
  });
  return iList;
}
