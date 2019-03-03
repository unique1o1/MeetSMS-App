import 'package:http/http.dart' as http;

import 'dart:convert';

class Session {
  Map<String, String> headers = <String, String>{};

  Future<Map> get(String url) async {
    http.Response response = await http.get(url, headers: headers);
    updateCookie(response);
    return json.decode(response.body);
  }

  Future<dynamic> post(Map<String, String> data, String url,
      {bool cookieBool: false}) async {
    http.Response response = await http.post(url, body: data, headers: headers);
    if (cookieBool) {
      print("updateing cookied");

      updateCookie(response);
    }
    return response.body;
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
