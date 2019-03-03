import 'package:flutter/material.dart';
import "package:meetsms_app/databaseClient.dart";
import 'package:meetsms_app/settting.dart';
import 'package:meetsms_app/request.dart';

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
  String recepients;
  Session http = Session();

  final mainKey = GlobalKey<ScaffoldState>();
  String loginUrl = "http://www.meet.net.np/meet/action/login";

  String smsUrl = "http://www.meet.net.np/meet/mod/sms/actions/send.php";

  void initState() {
    super.initState();
    initialRequest();
  }

  void initialRequest() async {
    Map<String, dynamic> userInfo = await widget.db.getinfo();

    http.post(<String, String>{
      "username": userInfo['username'],
      "password": userInfo['password'],
    }, loginUrl, cookieBool: true);
  }

  Widget _input(bool, String label, String hint, Function save) {
    return new TextField(
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        // contentPadding:
        contentPadding: bool
            ? new EdgeInsets.symmetric(vertical: 50.0, horizontal: 10.0)
            : EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      keyboardType: bool ? TextInputType.multiline : TextInputType.phone,
      maxLines: bool ? 10 : null,
      onChanged: save,
    );
  }

  //google sign
  void showdialog(String displayText) {
    showDialog(
        context: context,
        builder: (context) {
          return new SimpleDialog(
            title: new Text("Select theme"),
            children: <Widget>[
              Text(
                "Alert",
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              Text(
                displayText,
                style: TextStyle(
                    color: Colors.grey[800], fontWeight: FontWeight.normal),
              )
            ],
          );
        });
  }

  void loginUser() async {
    print(message);
    String numbers = "";

    print(recepients);
    List<String> numberList = recepients.split('.');
    if (numberList.length > 10) {
      showdialog("Sending more than 10 SMS is not supported.");
    }
    String ncell = "";

    numberList.forEach((String number) {
      String temp = number.replaceAll(' ', '');
      if (temp.contains(RegExp(r'^\d{10}$'))) {
        if (int.parse(temp) >= 9800000000 && int.parse(temp) <= 9829999999) {
          ncell += temp;
        } else {
          numbers += temp;
        }
      } else {
        showdialog("The number you entered is mistake");
        print("The number you entered is mistake");
      }
    });
    SnackBar snackbar = SnackBar(
      content: Text(
          "SMS to $ncell was not send because Ncell numbers are not supported"),
      duration: Duration(milliseconds: 3000),
    );
    mainKey.currentState.showSnackBar(snackbar);
    dynamic resp = http.post(<String, String>{
      "recipient": numbers,
      "message": message,
      "SmsLanguage": "English",
      "sendbutton": "Send Now"
    }, smsUrl);
    print(resp);
  }

  Widget loginButton() => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 130.0),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: EdgeInsets.all(20.0),
          onPressed: loginUser,
          color: Colors.lightBlueAccent,
          child: Icon(Icons.send, color: Colors.white),
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
      key: mainKey,
      resizeToAvoidBottomPadding: false,
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
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
                SizedBox(height: 48.0),
                _input(false, "Number", "Recepient's Number",
                    (value) => recepients = value),
                SizedBox(height: 25.0),
                _input(true, "Message", 'Your message',
                    (value) => message = value),
                SizedBox(height: 24.0),
                loginButton(),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
