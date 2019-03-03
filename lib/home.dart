import 'package:flutter/material.dart';
import "package:meetsms_app/databaseClient.dart";
import 'package:meetsms_app/settting.dart';

class HomePage extends StatefulWidget {
  DatabaseClient db;
  HomePage(this.db);

  @override
  State<StatefulWidget> createState() {
    return new _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  String message;
  String recepient;

  Widget _input(
      String validation, bool, String label, String hint, Function save) {
    return new TextFormField(
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        // contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
        contentPadding:
            new EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
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

  Drawer drawerSidebar() {
    return new Drawer(
      child: new Column(
        children: <Widget>[
          new UserAccountsDrawerHeader(
              accountName: new Text("SMS"), accountEmail: null),
          new Column(
            children: <Widget>[
              new ListTile(
                  leading: new Icon(Icons.settings,
                      color: Theme.of(context).accentColor),
                  title: new Text("Settings"),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context)
                        .push(new MaterialPageRoute(builder: (context) {
                      return Settings(widget.db);
                    }));
                  }),
            ],
          )
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          iconTheme: new IconThemeData(color: Colors.black),
          title: Hero(
              tag: 'hero',
              child: new ClipRRect(
                  borderRadius: new BorderRadius.circular(20.0),
                  child: Image(
                    image: AssetImage(
                      "images/icon.png",
                    ),
                    colorBlendMode: BlendMode.color,
                    height: 40.0,
                    fit: BoxFit.fitHeight,
                  ))),
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: Colors.transparent),
      drawer: drawerSidebar(),
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
