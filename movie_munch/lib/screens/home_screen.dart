import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:movie_munch/bloc/get_search_result.dart';
import 'package:movie_munch/style/theme.dart' as Style;
import 'package:movie_munch/widgets/best_movies.dart';
import 'package:movie_munch/widgets/genres.dart';
import 'package:movie_munch/widgets/main_drawer.dart';
import 'package:movie_munch/widgets/now_playing.dart';
import 'package:movie_munch/widgets/persons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_munch/widgets/result.dart';

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
        print("loggedInUser.email");
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
        title: Text("Discover"),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: DataSearch());
              },
              icon: Icon(
                EvaIcons.searchOutline,
                color: Colors.white,
              ))
        ],
      ),
      drawer: MainDrawer(),
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

class DataSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    searchResult.getMovies(query);
    return ResultInfo(searchString: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query != '') {
      searchResult.getMovies(query);
      return ResultInfo(searchString: query);
    }
    return ResultInfo(searchString: "old");
  }
}
