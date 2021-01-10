import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';




import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_testapp/API%20Files/ArticleApi.dart';
import 'package:flutter_testapp/API%20Files/config.dart';
import 'package:flutter_testapp/Model/Articles.dart';
import 'package:flutter_testapp/Model/Articlesjson.dart';
import 'package:flutter_testapp/Resources/SavedArticle.dart';
import 'package:flutter_testapp/Resources/Sharedprefernces.dart';
import 'package:flutter_testapp/ui/pages/WikipediaExplorer.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_testapp/style/Textstyle.dart';
import 'Imageview.dart';



class ArticleList extends StatefulWidget {

  // final String getcid;
  // const ArticleList(this.getcid);
  @override
  _ArticleList createState() => _ArticleList();
}

class _ArticleList extends State<ArticleList> {
  ScrollController _scrollController;
  bool internet = false;
  String articleString = '';
  List<Articles> article = [];
  String text,imgurl;
  SavedArticle saved = SavedArticle();
  String cid = "1";
  List<Articles> pList = [];
  //cid = getcid;
  Future<void> isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network, make sure there is actually a net connection.
      if (await DataConnectionChecker().hasConnection) {
        setState(() {
          internet = true;
        });

        // Mobile data detected & internet connection confirmed.
       // return true;
      } else {
        // Mobile data detected but no internet connection found.
        internet = false;
        //return false;
      }
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a WIFI network, make sure there is actually a net connection.
      if (await DataConnectionChecker().hasConnection) {
        // Wifi detected & internet connection confirmed.
        setState(() {
          internet = true;
        });
       // return true;
      } else {
        // Wifi detected but no internet connection found.
        internet = false;
        //return false;
      }
    } else {
      // Neither mobile data or WIFI detected, not internet connection found.
      internet = false;
    //  return false;
    }
  }
  Future<void> checkinternet()  async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        setState(() {
          internet =true;
        });


        final snackBar = SnackBar(
          content: Text('You are online'),
          action: SnackBarAction(
            label: 'Online',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      }
    } on SocketException catch (_) {
      print('not connected');
      setState(() {
        internet =false;
      });

      final snackBar = SnackBar(
        content: Text('You are offline'),
        action: SnackBarAction(
          label: 'Offline',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }

    //return internet;
  }


  main() async {
    // Simple check to see if we have internet
    print("The statement 'this machine is connected to the Internet' is: ");
    print(await DataConnectionChecker().hasConnection);
    // returns a bool

    // We can also get an enum instead of a bool
    print("Current status: ${await DataConnectionChecker().connectionStatus}");
    // prints either DataConnectionStatus.connected
    // or DataConnectionStatus.disconnected

    // This returns the last results from the last call
    // to either hasConnection or connectionStatus
    print("Last results: ${DataConnectionChecker().lastTryResults}");

    // actively listen for status updates
    var listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          print('Data connection is available.');
          internet = true;
          break;
        case DataConnectionStatus.disconnected:
          print('You are disconnected from the internet.');
          internet = false;
          break;
      }
    });

    // close listener after 30 seconds, so the program doesn't run forever
    await Future.delayed(Duration(seconds: 30));
    await listener.cancel();
  }
  @override
  initState()  {
    // TODO: implement initState
    super.initState();

 isInternet();

  }

  Future<List<Articles>> getSavedArticles() async {
    getData("ARTICLE_DATA").then((value) {
      setState(() {
        if (value != null) {
          var json = jsonDecode(value);
          var jdata = jsonDecode(json);

          var qdata = jdata['query'];
          int imgheight;
          int imgwidth;
          String imageurl, desc;
          // for (var pagedetails in qdata) {
          var pagedata = qdata['pages'];
          for (var details in pagedata) {
            saved.imageheight = 0;
            saved.imagewidth = 0;
            saved.imageurl = "";
            saved.pageid = details[pageid];
            saved.pagetitle = details[title];

            var thumbdata = details['thumbnail'];
            //for (var details in thumbdata) {
            if (thumbdata != null) {
              saved.imageheight = thumbdata[imageheight];
              saved.imagewidth = thumbdata[imagewidth];
              saved.imageurl = thumbdata[imageurls];
            }

            //}
            var termsdata = details['terms'];

            if (termsdata != null) {
              saved.pagedescription = jsonEncode(termsdata[description]);
            }

            pList.add(Articles(imageheight: saved.imageheight,
                imageurl: saved.imageurl,
                imagewidth: saved.imagewidth,
                pagedescription: saved.pagedescription,
                pageid: saved.pageid,
                pagetitle: saved.pagetitle));
          }
        }
      });
    });
    return pList;
  }
  @override
  Widget build(BuildContext context) {
    // cid = widget.getcid;

   //checkinternet();
    return Scaffold(
      //height: _topbar ? 360.0 : 0.0,

      appBar: AppBar(
        backgroundColor: mainStyle.mainColor,


        title:  Row(
          children: [
            Text("Articles",style: mainStyle.text20White,),
          ],
        ),


      ),
      body: Column(
        children: [



          Expanded(
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: internet ?
                article.length==0 ? FutureBuilder(
                  future:  getArticles() ,
                  builder: (context,snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return SpinKitThreeBounce(
                        color: Colors.amber,
                        size: 20,
                      );
                    }
                    if(snapshot.hasData){
                      article = snapshot.data;
                      // setData("ARTICLE_DATA", snapshot.data).then((value){
                      //   // Navigator.pop(context,"TRUE");
                      // });
                      return productList();
                    }
                    return Container(
                      child: Text('No Articles'),
                    );
                  },
                ) : productList(): FutureBuilder(
                  future:  getSavedArticles() ,
                  builder: (context,snapshot){

                    if(snapshot.hasData){
                      if(article.length!=0)
                        {
                          article.clear();
                        }
                      article = snapshot.data;
                      // setData("ARTICLE_DATA", snapshot.data).then((value){
                      //   // Navigator.pop(context,"TRUE");
                      // });
                      return productList();
                    }
                    return Container(
                      child: Text('No Articles'),
                    );
                  },
                ) ,

              ),

            ),
          ),
        ],

      ),



    );
  }







  ListView productList() {
    return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: article.length,
        itemBuilder: (context, i){


          var getdesc = jsonDecode(article[i].pagedescription);
          String desc = getdesc[0];
          return GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => WikipediaExplorer(article[i].pagetitle)
              ));
            },
            child: Column(
              children: [
                Card(
                  margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: (){

                                },
                                child: Hero(
                                 tag : article[i].pageid,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2.0),

                                    child: article[i].imageurl.length!=0 ?  Image(
                                      image: NetworkImage(article[i].imageurl),
                                     
                                      width: article[i].imagewidth.toDouble(),
                                      height: article[i].imageheight.toDouble(),
                                    ) : Image.asset(PLACEHOLDER,height: 33.0,width: 50.0),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 5,),
                                      Text(article[i].pagetitle, style: mainStyle.text16,),
                                      Text(desc, style: mainStyle.text12,),
                                      SizedBox(height: 5,),

                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}