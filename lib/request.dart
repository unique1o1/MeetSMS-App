import 'package:http/http.dart' as http;

import 'dart:convert';

class Session {
  Future<dynamic> post(Map<String, dynamic> data, String url,
      {bool cookieBool: false, Map<String, String> headers: const {}}) async {
    http.Response response = await http.post(url, body: data, headers: headers);
    if (cookieBool) {
      return updateCookie(response);
    }
    return response.statusCode;
  }

  String updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      String str = rawCookie.substring(rawCookie.indexOf(',') + 1);
      int index = str.indexOf(';');
      String cookie = (index == -1) ? rawCookie : str.substring(0, index);
      if (rawCookie.contains(RegExp(r'[Ee]xpires'))) return cookie;
    }
    return null;
  }
}
