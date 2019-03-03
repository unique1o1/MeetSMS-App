import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'dart:convert';

class Session {
  String login_url = "http://www.meet.net.np/meet/action/login";

  String sms_url = "http://www.meet.net.np/meet/mod/sms/actions/send.php";

  Map<String, String> headers = <String, String>{};

  Future<Map> get(String url) async {
    http.Response response = await http.get(url, headers: headers);
    updateCookie(response);
    return json.decode(response.body);
  }

  Future<Map> post(Map<String, String> data) async {
    http.Response response =
        await http.post(login_url, body: data, headers: headers);
    updateCookie(response);
    return json.decode(response.body);
  }

  void updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}
