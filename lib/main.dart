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
  int val;
  DatabaseClient db;

  void getinfo() async {
    db = DatabaseClient();
    await db.create();

    var pref = await SharedPreferences.getInstance();
    val = pref.getInt("getNetwork");
    setState(() {
      isLoading = false;
    });
  }

  void initState() {
    super.initState();

    getinfo();
  }

  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Meet SMS",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : val == 1 || val == 2 ?? val != null ? HomePage(db) : LoginPage(db),
    );
  }
}
