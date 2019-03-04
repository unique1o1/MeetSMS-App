import 'package:flutter/material.dart';
import 'package:meetsms_app/databaseClient.dart';
import 'dart:async';

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
  String password;
  Map<String, dynamic> userInfo;
  bool isLoading = true;

  void showsnackbar(String displayText) {
    SnackBar snackbar = SnackBar(
      content: Text(displayText),
      duration: Duration(milliseconds: 5000),
    );
    scaffoldState.currentState.showSnackBar(snackbar);
  }

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
        widget.db.updateInfo(password, username);
        widget.db.updateQuota(0);
        showsnackbar("Please restart the app for the changes to take effect");
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
          child: Text('Save', style: TextStyle(color: Colors.white)),
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
