import 'package:flutter/material.dart';
import 'package:meetsms_app/databaseClient.dart';

class Settings extends StatefulWidget {
  DatabaseClient db;

  Settings(this.db);
  @override
  State<StatefulWidget> createState() {
    return new _settingState();
  }
}

class _settingState extends State<Settings> {
  var isLoading = false;
  var selected = 0;
  String username;
  String password;
  Map<String, dynamic> userInfo;

  void initState() {
    super.initState();
    getdata();
  }

  void getdata() async {
    userInfo = await widget.db.getinfo();
    setState(() {
      userInfo = userInfo;
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
    Map<String, dynamic> a = await widget.db.getinfo();
    print(a['id']);

    if (checkFields()) {
      widget.db.updateInfo(password, username);
      print(await widget.db.getinfo());
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
      body: new Container(
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
                    _input("required password", true, "Password", 'Password',
                        (value) => password = value),
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
