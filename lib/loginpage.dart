import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meetsms_app/databaseClient.dart';
import 'package:meetsms_app/home.dart';

class LoginPage extends StatefulWidget {
  DatabaseClient db;

  LoginPage(this.db);

  @override
  _LoginPageSate createState() => _LoginPageSate();
}

class _LoginPageSate extends State<LoginPage> {
  String username;
  String password;

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
      validator: (value) => value.length <= 5 ? validation : null,
      onSaved: save,
    );
  }

  //google sign
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
    print("inside");

    if (checkFields()) {
      widget.db.insertInfo(password, username);
      Map<String, dynamic> a = await widget.db.getinfo();
      print(a['username']);

      var pref = await SharedPreferences.getInstance();
      pref.setBool("gotinfo", true);
      Navigator.of(context)
          .pushReplacement(new MaterialPageRoute(builder: (context) {
        return new HomePage(widget.db);
      }));
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
          child: Text('Log In', style: TextStyle(color: Colors.white)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                loginButton(),
              ],
            )),
      ),
    );
  }
}
