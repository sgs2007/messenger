import 'package:flutter/material.dart';
import 'package:spacecorp_messanger/Authscreen/auth_screen.dart';
import 'package:spacecorp_messanger/HomeScreen/home_screen.dart';
import 'package:spacecorp_messanger/services/auth.dart';

class LayoutPage extends StatelessWidget {
  const LayoutPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //   future: AuthMedthods().getCurrentUser(),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       return HomeScreen();
    //     } else {
    //       return AuthScreen();
    //     }
    //   },
    // );
    return AuthScreen();
  }
}
