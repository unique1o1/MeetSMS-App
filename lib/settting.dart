import 'package:flutter/material.dart';
import 'package:meetsms_app/databaseClient.dart';
import 'dart:async';
import 'package:meetsms_app/request.dart';
import 'package:meetsms_app/snackbar.dart';

class Settings extends StatefulWidget {
  DatabaseClient db;

  Settings(this.db);
  @override
  State<StatefulWidget> createState() {
    return new _settingState();
  }
}

class _settingState extends State<Settings> {
  var selected = 0;
  String username;
  String loginUrl = "http://www.meet.net.np/meet/action/login";

  String password;
  Map<String, dynamic> userInfo;
  bool isLoading = true;
  Session http = Session();
  bool isSending = false;

  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 100), getdata);
  }

  void getdata() async {
    userInfo = await widget.db.getinfo();
    setState(() {
      userInfo = userInfo;
      isLoading = false;
    });
  }

  Widget _input(
      String validation, bool, String label, String hint, Function save) {
    return new TextFormField(
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      obscureText: bool,
      initialValue: bool ? userInfo['password'] : userInfo['username'],
      validator: (value) => value.length <= 5 ? validation : null,
      onSaved: save,
    );
  }

  final formkey = new GlobalKey<FormState>();
  checkFields() {
    final form = formkey.currentState;
    if (form.validate()) {
      form.save();

      return true;
    }
    return false;
  }

  void loginUser() async {
    if (checkFields()) {
      Map<String, dynamic> s = await widget.db.getinfo();
      if (s['username'] != username) {
        setState(() {
          isSending = true;
        });
        String cookie = await http.post(<String, dynamic>{
          'username': username,
          'password': password,
          'persistent': 'true',
        }, loginUrl, cookieBool: true);
        if (cookie != null) {
          widget.db.updateInfo(password, username, cookie);
          widget.db.updateQuota(0);
          DatabaseClient.quotaStatus = 0;

          showsnackbar("You are now logged in", scaffoldState);
        } else {
          showsnackbar(
              "Username/ Password you entered is mistake", scaffoldState);
        }
        setState(() {
          isSending = false;
        });
      } else {
        showsnackbar("You entered the same username", scaffoldState);
      }
    }
  }

  Widget loginButton() => Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          onPressed: loginUser,
          padding: EdgeInsets.all(12),
          color: Colors.lightBlueAccent,
          child: !isSending
              ? Text('Save', style: TextStyle(color: Colors.white))
              : CircularProgressIndicator(),
        ),
      );

  @override
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldState,
      appBar: new AppBar(
        title: new Text("Settings"),
      ),
      body: isLoading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : new Container(
              child: Column(children: <Widget>[
                Center(
                  child: Form(
                      key: formkey,
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(left: 24.0, right: 24.0),
                        children: <Widget>[
                          SizedBox(height: 48.0),
                          _input("required email", false, "Username",
                              'Enter your Email', (value) => username = value),
                          SizedBox(height: 8.0),
                          _input("required password", true, "Password",
                              'Password', (value) => password = value),
                          SizedBox(height: 24.0),
                          loginButton(),
                        ],
                      )),
                )
              ]),
            ),
    );
  }
}
