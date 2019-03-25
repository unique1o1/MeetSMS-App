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
        return new Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              height: 24.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                color: connected ? Color(0xFF00EE44) : Color(0xFFEE4400),
                child: Center(
                  child: Text("${connected ? 'ONLINE' : 'OFFLINE'}"),
                ),
              ),
            ),
            child
          ],
        );
      },
      child: child,
    );
  }
}
