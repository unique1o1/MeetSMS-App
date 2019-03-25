import 'package:flutter/material.dart';
import "package:meetsms_app/databaseClient.dart";
import 'package:meetsms_app/settting.dart';
import 'package:meetsms_app/request.dart';
import 'package:meetsms_app/snackbar.dart';
import 'offline.dart';

class HomePage extends StatefulWidget {
  DatabaseClient db;
  HomePage(this.db);

  @override
  State<StatefulWidget> createState() {
    return new _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  String message = '';
  String recepients = '';
  Session http = Session();

  final mainKey = GlobalKey<ScaffoldState>();
  String loginUrl = "http://www.meet.net.np/meet/action/login";

  String smsUrl = "http://www.meet.net.np/meet/mod/sms/actions/send.php";
  bool isSending = false;
  int quota = 0;

  void initState() {
    super.initState();
    initialQuota();
  }

  void initialQuota() async {
    int value = await widget.db.getEpoch();
    value = DateTime.fromMillisecondsSinceEpoch(value).day - DateTime.now().day;

    if (value < 0) {
      widget.db
          .updateEpoch(); //update epoch if more than a day has gone by which also updats the quota
    } else {
      DatabaseClient.quotaStatus = await widget.db.getQuota();

      setState(() {
        DatabaseClient.quotaStatus = DatabaseClient.quotaStatus;
      });
    }
  }

  Widget _input(bool, String label, String hint, Function save) {
    return new TextField(
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
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
          return new AlertDialog(
            title: new Text(
              "Alert",
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            content: Text(
              displayText,
              style: TextStyle(
                  color: Colors.grey[800], fontWeight: FontWeight.normal),
            ),
            actions: <Widget>[
              // uFlatButtonsually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void sendMessage() async {
    if (message.isEmpty || recepients.isEmpty) {
      showsnackbar(
          message.isEmpty ? "Message field is empty" : "Numbers field is empty",
          mainKey);
    } else {
      String numbers = "";

      List<String> numberList = recepients.split(',');
      if (numberList.length > 10) {
        showdialog("Sending more than 10 SMS is not supported.");
      }
      String ncell = "";
      String WrongNumbers = "";

      numberList.forEach((String number) {
        String temp = number.replaceAll(' ', '');
        if (temp.contains(RegExp(r'^\d{10}$')) &&
            temp.contains(RegExp(r'^(984)|(985)|(986)'))) {
          numbers += numbers.isEmpty ? temp : "," + temp;
        } else if (temp.contains(RegExp(r'^\d{10}$')) &&
            temp.contains(RegExp(r'^(980)|(981)|(982)'))) {
          ncell += ncell.isEmpty ? temp : "," + temp;
        } else {
          WrongNumbers += WrongNumbers.isEmpty ? temp : "," + temp;
        }
      });
      if (WrongNumbers.isNotEmpty) {
        showsnackbar(
            "SMS to $WrongNumbers was not send because these numbers are  wrong",
            mainKey);
      }
      if (ncell.isNotEmpty) {
        showsnackbar(
            "SMS to $ncell was not send because Ncell numbers are not supported",
            mainKey);
      }
      if (numbers.isNotEmpty) {
        setState(() {
          isSending = true;
        });
        String cookie = await widget.db.getcookie();

        int resp = await http.post(
            <String, String>{
              "recipient": numbers,
              "message": message,
              "SmsLanguage": "English",
              "sendbutton": "Send Now"
            },
            smsUrl,
            headers: {'cookie': cookie});
        setState(() {
          isSending = false;
        });
        if (resp == 302) {
          showdialog("""Message was send to the following numbers:$numbers""");
          DatabaseClient.quotaStatus += numbers.split(',').length;
          print('object j j ${DatabaseClient.quotaStatus}');

          widget.db.updateQuota(DatabaseClient.quotaStatus);
          setState(() {
            DatabaseClient.quotaStatus = DatabaseClient.quotaStatus;
          });
        } else
          showdialog("""$resp Errored when sending message""");
      }
    }
  }

  Widget loginButton() => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 130.0),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: EdgeInsets.all(20.0),
          onPressed: sendMessage,
          color: Colors.lightBlueAccent,
          child: SizedBox(
              height: 40.0,
              width: 80.0,
              child: Center(
                child: !isSending
                    ? Icon(Icons.send, color: Colors.white)
                    : CircularProgressIndicator(),
              )),
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
        resizeToAvoidBottomInset: false,
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
        body: Offline(
            child: RefreshIndicator(
          child: new Container(
            height: 1920.0,
            child: Column(children: <Widget>[
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Quota",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 5.0),
                    Container(
                      width: 30.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          border:
                              Border.all(color: Colors.grey[350], width: 1.0)),
                      child: Text(
                        DatabaseClient.quotaStatus.toString(),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
              Center(
                child: Form(
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
                    SizedBox(height: 170.0),
                  ],
                )),
              )
            ]),
          ),
          onRefresh: () async {
            Map<String, dynamic> s = await widget.db.getinfo();

            String cookie = await http.post(<String, dynamic>{
              'username': s['username'],
              'password': s['password'],
              'persistent': 'true',
            }, loginUrl, cookieBool: true);
            if (cookie != null) {
              widget.db.updateInfo(s['password'], s['username'], cookie);
              print('refresjed');

              showsnackbar("Refreshed login cookie", mainKey);
            } else {
              showsnackbar("Problem refreshing cookie", mainKey);
            }
          },
        )));
  }
}
