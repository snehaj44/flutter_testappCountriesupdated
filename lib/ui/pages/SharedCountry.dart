import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';




import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_testapp/API%20Files/ArticleApi.dart';
import 'package:flutter_testapp/API%20Files/CountriesAPI.dart';
import 'package:flutter_testapp/API%20Files/config.dart';
import 'package:flutter_testapp/Model/Articles.dart';
import 'package:flutter_testapp/Model/Articlesjson.dart';
import 'package:flutter_testapp/Model/Countries.dart';
import 'package:flutter_testapp/Resources/SavedArticle.dart';
import 'package:flutter_testapp/Resources/SavedCountry.dart';
import 'package:flutter_testapp/Resources/Sharedprefernces.dart';
import 'package:flutter_testapp/ui/pages/WikipediaExplorer.dart';
import 'package:http/http.dart';
import 'package:kt_dart/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_testapp/style/Textstyle.dart';
import 'Imageview.dart';



class SharedCountry extends StatefulWidget {

  final String getborder;
  const SharedCountry(this.getborder);
  @override
  _SharedCountry createState() => _SharedCountry();
}

class _SharedCountry extends State<SharedCountry> {
  ScrollController _scrollController;
  bool internet = false;
  String articleString = '';
  List<Countries> region = [];
  String text,imgurl;
  SavedCountry saved = SavedCountry();
  String getregions = "1";
  List<Articles> pList = [];
  List<Countries>Sharedborder=[];
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

  Future<List<Countries>> getSavedCountries() async {
    getData("Countries_DATA").then((value) {
      setState(() {
        if (value != null) {
          var json = jsonDecode(value);
          var jdata = jsonDecode(json);
          var langname;
          for(var details in jdata){
            String cname = details['name'];
            String ccode = details['cioc'];
            String creg = details['region'];
            String ccapital = details['capital'];
            String cborder = details['borders'];

            var langdetails = details['languages'];
            //for (var details in thumbdata) {
            if(langdetails!=null) {
              for(var lang in langdetails) {
                langname = lang['name'];
              }
            }
            String flagimg = jsonEncode(details['flag']);

            region.add(Countries(region: creg, countryname: cname, capitalname: ccapital, languages: langname.toString(), flagimage: flagimg, countrycode: ccode, borders: cborder));


          }
        }
      });
    });
    return region;
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
              Text("Countries",style: mainStyle.text20White,),
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
                  child: region.length==0 ? FutureBuilder(
                    future:  getCountries() ,
                    builder: (context,snapshot){
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return SpinKitThreeBounce(
                          color: Colors.amber,
                          size: 20,
                        );
                      }
                      if(snapshot.hasData){
                        region = snapshot.data;
                        var records = mutableListFrom(region);
                        final border = widget.getborder.substring(1, widget.getborder.length - 1);
                        var scountry = border.split(',');


                        for(int i=0;i<scountry.length;i++)
                        {
                          var distinctcountry = records.filter((it) => it.countrycode == scountry[i].trimLeft());
                          Sharedborder.add(distinctcountry.get(0));




                        }
                        // setData("ARTICLE_DATA", snapshot.data).then((value){
                        //   // Navigator.pop(context,"TRUE");
                        // });
                        return productList();
                      }
                      return Container(
                        child: Text('No Countries'),
                      );
                    },
                  ) : productList(),
                ),
              ) ,
            ),
          ],

        )

    );




  }







  ListView productList() {

    print("see border");

    //var distincts = records.filter((it) => it.region == widget.getregion);
    return  Sharedborder.length!=0 ?  ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: Sharedborder.length,
        itemBuilder: (context, i){
          print("see image");
          print(Sharedborder[i].flagimage);



          return GestureDetector(
            onTap: (){
              // Navigator.push(context, MaterialPageRoute(
              //     builder: (context) => WikipediaExplorer(region[i].pagetitle)
              // ));
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
                                  tag : Sharedborder[i].countrycode,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2.0),

                                    child: Sharedborder[i].flagimage.length!=0 ?  SvgPicture.network(
                                      Sharedborder[i].flagimage,
                                      width: 30.0,
                                      height: 30.0,
                                      placeholderBuilder: (BuildContext context) => Container(
                                        //padding: const EdgeInsets.all(30.0),
                                          width: 40.0,
                                          height: 40.0,
                                          child: const CircularProgressIndicator()),



                                    ) : Image.asset(PLACEHOLDER,height: 33.0,width: 50.0),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 5,),
                                      Text(Sharedborder[i].countryname, style: mainStyle.text16,),
                                      Text(Sharedborder[i].languages, style: mainStyle.text12,),
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
        }) : Container(
      child: Text("No Countries"),
    );
  }
}