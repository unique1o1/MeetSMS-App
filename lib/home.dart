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
        title: new Text("Meet SMS"),
      ),
      drawer: drawerSidebar(),
      body: Text('rasdf'),
    );
  }
}
