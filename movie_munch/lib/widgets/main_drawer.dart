import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_munch/style/theme.dart' as Style;

class MainDrawer extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  String userName;
  void getuserName() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        userName = user.email;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    getuserName();
    return Drawer(
      child: Container(
        color: Style.Colors.mainColor,
        padding: EdgeInsets.only(top: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.person,
              color: Style.Colors.secondColor,
              size: 70,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              userName,
              style: TextStyle(color: Style.Colors.secondColor, fontSize: 20),
            ),
            Divider(
              color: Style.Colors.secondColor,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Favorites",
                    style: TextStyle(
                        color: Style.Colors.secondColor, fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 500,
                ),
                TextButton(
                  onPressed: () {
                    _auth.signOut().then((_) =>
                        Navigator.of(context).pushReplacementNamed('/login'));
                  },
                  child: Text(
                    "Logout",
                    style: TextStyle(
                        color: Style.Colors.secondColor, fontSize: 20),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
