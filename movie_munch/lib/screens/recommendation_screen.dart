import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_munch/model/myList.dart';
import 'dart:math';
import 'package:movie_munch/style/theme.dart' as Style;

class RecommendationScreen extends StatefulWidget {
  @override
  _RecommendationScreen createState() => _RecommendationScreen();
}

class _RecommendationScreen extends State<RecommendationScreen> {
  List<int> movieList = Mylist.mylist;
  List<int> finalList;
  int ran = new Random().nextInt(200);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$ran'),
    );
  }
}
