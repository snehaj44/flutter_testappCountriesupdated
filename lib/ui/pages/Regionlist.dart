import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';




import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_testapp/API%20Files/ArticleApi.dart';
import 'package:flutter_testapp/API%20Files/CountriesAPI.dart';
import 'package:flutter_testapp/API%20Files/RegionsAPI.dart';
import 'package:flutter_testapp/API%20Files/config.dart';
import 'package:flutter_testapp/Model/Articles.dart';
import 'package:flutter_testapp/Model/Articlesjson.dart';
import 'package:flutter_testapp/Model/Countries.dart';
import 'package:flutter_testapp/Model/Regions.dart';
import 'package:flutter_testapp/Resources/SavedArticle.dart';
import 'package:flutter_testapp/Resources/SavedCountry.dart';
import 'package:flutter_testapp/Resources/Sharedprefernces.dart';
import 'package:flutter_testapp/ui/pages/Countrylist.dart';
import 'package:flutter_testapp/ui/pages/WikipediaExplorer.dart';
import 'package:http/http.dart';
import 'package:kt_dart/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_testapp/style/Textstyle.dart';
import 'Imageview.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';



class Regionlist extends StatefulWidget {

  // final String getcid;
  // const ArticleList(this.getcid);
  @override
  _Regionlist createState() => _Regionlist();
}

class _Regionlist extends State<Regionlist> {
  ScrollController _scrollController;
  bool internet = false;
  String articleString = '';
  List<Regions> region = [];
  String text,imgurl;
  SavedCountry saved = SavedCountry();
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

  Future<List<Regions>> getSavedCountries() async {
    getData("Regions_DATA").then((value) {
      setState(() {
        if (value != null) {
          var json = jsonDecode(value);
          var jdata = jsonDecode(json);
          var langname;
          for(var details in jdata){

            String creg = details['region'];




            region.add(Regions(regions: creg));

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
            Text("Regions",style: mainStyle.text20White,),
          ],
        ),


      ),
      drawer: new Drawer(


        child: new ListView(

            children: <Widget>[
              InkWell(

                onTap: (){
                  Navigator.pop(context);

                },
                child: ListTile(
                  title: Text('Home'),
                  leading: Icon(Icons.home,color: Colors.amber,),
                ),
              ),
              InkWell(

                onTap: (){
                 _onBackPressed();

                },
                child: ListTile(
                  title: Text('Exit'),
                  leading: Icon(Icons.exit_to_app,color: Colors.amber,),
                ),
              ),

              ]
        ),
      ),
      body: DoubleBackToCloseApp(
              snackBar: const SnackBar(
              content: Text('Tap back again to exit'),
                ),


      child:Column(
        children: [



          Expanded(
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: region.length==0 ? FutureBuilder(
                  future:  getRegions() ,
                  builder: (context,snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return SpinKitThreeBounce(
                        color: Colors.amber,
                        size: 20,
                      );
                    }
                    if(snapshot.hasData){
                    region = snapshot.data;

                     print("display");
                    // print(uniqueregion);
                     print(region);

                      // setData("ARTICLE_DATA", snapshot.data).then((value){
                      //   // Navigator.pop(context,"TRUE");
                      // });
                      return productList();
                    }
                    return Container(
                      child: Text('No regions'),
                    );
                  },
                ) : productList(),
              ),
                ) ,
          ),
                ],

              )
      ),
            );




  }







  ListView productList() {
    var records = mutableListFrom(region);
    var distincts = records.distinctBy((it) => it.regions).toList();
    print("dist");
    print(distincts);

    return ListView.builder(

        primary: false,
        shrinkWrap: true,
        itemCount: distincts.size,
        itemBuilder: (context, i){
          // print("see image");
          // print(region[i].flagimage);



          return GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Countrylist(distincts[i].regions)
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

                              Expanded(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 5,),
                                      Text(distincts[i].regions.isNotEmpty ? distincts[i].regions : "Other", style: mainStyle.text16,),
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
  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you want to exit an App'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                //Navigator.of(context).pop(true);
                SystemNavigator.pop();
              },
            )
          ],
        );
      },
    ) ?? false;
  }
}
extension IterableDistinctExt<T> on Iterable<T> {
  Iterable<T> distinct() sync* {
    final visited = <T>{};
    for (final el in this) {
      if (visited.contains(el)) continue;
      yield el;
      visited.add(el);
    }
  }
}