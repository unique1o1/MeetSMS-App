import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

class Offline extends StatelessWidget {
  Widget child;

  Offline({this.child});

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      connectivityBuilder: (
        BuildContext context,
        ConnectivityResult connectivity,
        Widget child,
      ) {
        final bool connected = connectivity != ConnectivityResult.none;
        return new Container(
            child: Column(
          children: [
            connected
                ? SizedBox()
                : Container(
                    height: 20.0,
                    color: connected ? Color(0xFF00EE44) : Color(0xFFEE4400),
                    child: Center(
                      child: Text('OFFLINE'),
                    ),
                  ),
            SizedBox(
              height: 2,
            ),
            child
          ],
        ));
      },
      child: child,
    );
  }
}
