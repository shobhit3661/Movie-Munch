import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_munch/screens/cart_screen.dart';
import 'package:movie_munch/screens/recommendation_screen.dart';
import 'package:movie_munch/style/theme.dart' as Style;
import 'package:tflite_flutter/tflite_flutter.dart';

class MainDrawer extends StatelessWidget {
  final _modelFile = 'coverted_model.tflite';
  final _auth = FirebaseAuth.instance;
  static int n = 64;
  var input = List<List<int>>(n * 2).reshape([n, 2]);
  var output = List<double>(n).reshape([n, 1]);
  User loggedInUser;
  int userId;
  String userName;

  void getuserName() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        userName = user.email;
      }
      DocumentReference db =
          FirebaseFirestore.instance.collection('data').doc(userName);
      db.get().then((DocumentSnapshot datasnap) {
        userId = datasnap['userId'];
      });
    } catch (e) {
      print(e);
    }
  }

  void loadandRunModel() async {
    try {
      Interpreter _interpreter;
      _interpreter = await Interpreter.fromAsset(_modelFile);
      _interpreter.allocateTensors();
      _interpreter.run(input, output);
      print(input);
      print(output);
      _interpreter.close();
    } catch (e) {
      print("This is the errore");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    getuserName();
    //loadandRunModel();
    return Drawer(
      child: Container(
        color: Style.Colors.mainColor,
        padding: EdgeInsets.only(top: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
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
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CartScreen()));
                  },
                  child: Text(
                    "Favorites",
                    style: TextStyle(
                        color: Style.Colors.secondColor, fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RecommendationScreen()));
                  },
                  child: Text(
                    "Recommendation",
                    style: TextStyle(
                        color: Style.Colors.secondColor, fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    //  loadModel();
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
