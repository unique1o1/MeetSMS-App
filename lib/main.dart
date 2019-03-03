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
        decoration: BoxDecoration(color: Colors.redAccent),
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
                  child: Image.asset(
                    "images/watch.png",
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                Text(
                  "Spectra",
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

    db.create();

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
