import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:movie_munch/style/theme.dart' as Style;
import 'package:movie_munch/widgets/best_movies.dart';
import 'package:movie_munch/widgets/genres.dart';
import 'package:movie_munch/widgets/now_playing.dart';
import 'package:movie_munch/widgets/persons.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  User loggedInUser;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      appBar: AppBar(
        backgroundColor: Style.Colors.mainColor,
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(
            EvaIcons.menu2Outline,
            color: Colors.white,
          ),
          onPressed: () {
            print("menu pressed");
          },
        ),
        title: Text("Discover"),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                print("search pressed");
              },
              icon: Icon(
                EvaIcons.searchOutline,
                color: Colors.white,
              ))
        ],
      ),
      body: ListView(
        children: <Widget>[
          NowPlaying(),
          GenresScreen(),
          PersonsList(),
          BestMovies(),
        ],
      ),
    );
  }
}
