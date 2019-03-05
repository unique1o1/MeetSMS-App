import 'package:flutter/material.dart';

void showsnackbar(String displayText, GlobalKey<ScaffoldState> key) {
  SnackBar snackbar = SnackBar(
    content: Text(displayText),
    duration: Duration(milliseconds: 5000),
  );
  key.currentState.showSnackBar(snackbar);
}
