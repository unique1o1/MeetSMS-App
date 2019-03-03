import 'package:flutter/material.dart';
import 'package:meetsms_app/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:meetsms_app/loginpage.dart';
import 'package:meetsms_app/databaseClient.dart';

//import 'package:firebase_auth/firebase_auth.dart';
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new Page();
  }
}

class Page extends State<MyApp> {
  bool isLoading = true;
  bool val;
  DatabaseClient db;

  Widget splashscreen() {
    return Scaffold(
        body: Stack(fit: StackFit.expand, children: <Widget>[
      Container(
        decoration: BoxDecoration(color: Colors.blue[700]),
      ),
      Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 50.0,
                  child: new ClipRRect(
                      borderRadius: new BorderRadius.circular(20.0),
                      child: Image(
                        image: AssetImage(
                          "images/icon.png",
                        ),
                        colorBlendMode: BlendMode.color,
                        height: 60.0,
                        fit: BoxFit.contain,
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                Text(
                  "MeetSMS",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0),
                )
              ],
            ),
          ),
        )
      ])
    ]));
  }

  void getinfo() async {
    db = DatabaseClient();
    await db.create();

    var pref = await SharedPreferences.getInstance();
    val = pref.getBool("gotinfo");
    setState(() {
      isLoading = false;
    });
  }

  void initState() {
    super.initState();

    Timer(Duration(seconds: 1), getinfo);
  }

  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Meet SMS",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLoading
          ? splashscreen()
          : val ?? false ? HomePage(db) : LoginPage(db),
    );
  }
}
