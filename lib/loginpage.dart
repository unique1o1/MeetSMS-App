import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meetsms_app/databaseClient.dart';
import 'package:meetsms_app/home.dart';
import 'package:meetsms_app/request.dart';
import 'package:meetsms_app/snackbar.dart';

class LoginPage extends StatefulWidget {
  DatabaseClient db;

  LoginPage(this.db);

  @override
  _LoginPageSate createState() => _LoginPageSate();
}

class _LoginPageSate extends State<LoginPage> {
  String username;
  String password;
  bool isSending = false;
  int radioItemConditionValue = 1;

  Session http = Session();
  String loginUrl = "http://www.meet.net.np/meet/action/login";
  final mainKey = GlobalKey<ScaffoldState>();
  BoxDecoration boxDecoration = BoxDecoration(boxShadow: [
    BoxShadow(
        color: Colors.grey[500],
        blurRadius: 0, // has the effect of softening the shadow
        offset: Offset(
            0, // horizontal, move right 10
            1 // vertical, move down 10
            ))
  ], color: Colors.white);
  void _itemconditionValueHandler(int value) {
    setState(() {
      radioItemConditionValue = value;
    });
  }

  final logo = Hero(
      tag: 'hero',
      child: Container(
        height: 220.0,
        width: 110.0,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/monkey.gif'), fit: BoxFit.cover),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(500.0),
              bottomRight: Radius.circular(500.0)),
        ),
      ));

  Widget _input(String validation, bool obscure, String label, String hint,
      Function save) {
    return new TextFormField(
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      obscureText: obscure,
      validator: (value) => value.length <= 5 ? validation : null,
      onSaved: save,
    );
  }

  //google sign
  final formkey = new GlobalKey<FormState>();
  bool checkFields() {
    final form = formkey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void loginUser() async {
    print("inside");
    setState(() {
      isSending = true;
    });
    if (checkFields()) {
      if (radioItemConditionValue == 1) {
        //Ncell
        widget.db.insertInfo(password, username, "Not needed for Ncell");
        setState(() {
          isSending = false;
        });
      } else {
        String cookie = await http.post(<String, dynamic>{
          'username': username,
          'password': password,
          'persistent': "true",
        }, loginUrl, cookieBool: true);
        if (cookie != null) {
          widget.db.insertInfo(password, username, cookie);

          widget.db.insertResetTime();

          Map<String, dynamic> a = await widget.db.getinfo();
          print(a['username']);

          setState(() {
            isSending = false;
          });
        } else {
          setState(() {
            isSending = false;
          });
          showsnackbar("Username/ Password you entered is mistake", mainKey);
          return;
        }
      }
      var pref = await SharedPreferences.getInstance();
      pref.setInt("getNetwork", radioItemConditionValue);
      Navigator.of(context)
          .pushReplacement(new MaterialPageRoute(builder: (context) {
        return new HomePage(widget.db);
      }));
    }
    setState(() {
      isSending = false;
    });
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
              ? Text('Log In', style: TextStyle(color: Colors.white))
              : CircularProgressIndicator(),
        ),
      );

  Center generateItemRadioTile() {
    return Center(
      child: Container(
        child: Row(
          children: <Widget>[
            Radio(
              value: 1,
              groupValue: radioItemConditionValue,
              onChanged: _itemconditionValueHandler,
            ),
            Text("Ncell"),
            Radio(
              value: 2,
              groupValue: radioItemConditionValue,
              onChanged: _itemconditionValueHandler,
            ),
            Text("NTC"),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: mainKey,
      body: Center(
        child: Form(
            key: formkey,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
                logo,
                SizedBox(height: 48.0),
                _input(
                    "Username must be more than 5 character",
                    false,
                    "username",
                    'Enter your username',
                    (value) => username = value),
                SizedBox(height: 8.0),
                _input("Password must be more than 5 character ", true,
                    "Password", 'Password', (value) => password = value),
                SizedBox(height: 24.0),
                generateItemRadioTile(),
                loginButton(),
              ],
            )),
      ),
    );
  }
}
