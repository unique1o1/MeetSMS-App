import 'package:flutter/material.dart';
import 'package:meetsms_app/databaseClient.dart';
import 'package:meetsms_app/request.dart';
import 'snackbar.dart';

class Refresh extends StatelessWidget {
  final Widget child;
  final DatabaseClient db;
  Session http = Session();

  String loginUrl = "http://www.meet.net.np/meet/action/login";

  Refresh({this.child, this.db});

  Widget build(context) {
    return RefreshIndicator(
      child: child,
      onRefresh: () async {
        Map<String, dynamic> s = await db.getinfo();

        String cookie = await http.post(<String, dynamic>{
          'username': s['username'],
          'password': s['password'],
          'persistent': 'true',
        }, loginUrl, cookieBool: true);
        if (cookie != null) {
          db.updateInfo(s['password'], s['username'], cookie);
          print('refresjed');

          showsnackbar("Refreshed login cookie", mainKey);
        } else {
          showsnackbar("Problem refreshing cookie", mainKey);
        }
      },
    );
  }
}
