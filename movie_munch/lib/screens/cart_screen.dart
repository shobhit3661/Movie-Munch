import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_munch/model/movie.dart';
import 'package:movie_munch/style/theme.dart' as Style;
import 'detail_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreen createState() => _CartScreen();
}

class _CartScreen extends State<CartScreen> {
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference db = FirebaseFirestore.instance.collection('data');
  String userEmail;
  User loggedInUser;
  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        userEmail = loggedInUser.email;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUser();
    DocumentReference userData =
        FirebaseFirestore.instance.collection('data').doc(userEmail);

    return StreamBuilder<DocumentSnapshot>(
      stream: userData.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          print("snapshot has error in cart screen");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }
        return Scaffold(
          backgroundColor: Style.Colors.mainColor,
          appBar: AppBar(
            backgroundColor: Style.Colors.mainColor,
            centerTitle: true,
            title: Text("favorites"),
          ),
          body: ListView(
            children: <Widget>[
              _movieList(snapshot.data),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildLoadingWidget() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 25.0,
          width: 25.0,
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 4.0,
          ),
        )
      ],
    ),
  );
}

Widget _movieList(DocumentSnapshot data) {
  Map<String, dynamic> movies = data.data();
  if (movies['MovieList'].length == 0) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                "No More Movies",
                style: TextStyle(fontSize: 20, color: Style.Colors.secondColor),
              )
            ],
          )
        ],
      ),
    );
  } else
    return ListView.builder(
      physics: ScrollPhysics(),
      itemCount: movies['MovieList'].length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.all(8),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            Movie passMovie = new Movie(
                movies['MovieList'][index]['id'],
                movies['MovieList'][index]['popularity'],
                movies['MovieList'][index]['title'],
                movies['MovieList'][index]['backPoster'],
                movies['MovieList'][index]['poster'],
                movies['MovieList'][index]['overview'],
                movies['MovieList'][index]['rating']);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(movie: passMovie),
              ),
            );
          },
          child: Container(
            height: 100,
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  height: 80,
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(2.0),
                    ),
                    shape: BoxShape.rectangle,
                    image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage("https://image.tmdb.org/t/p/w200/" +
                            movies['MovieList'][index]['poster'])),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text(
                        movies['MovieList'][index]['title'],
                        maxLines: 2,
                        style: TextStyle(
                            height: 1.4,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RatingBar.builder(
                      itemSize: 12.0,
                      initialRating: movies['MovieList'][index]['rating'] / 2,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                      itemBuilder: (context, _) => Icon(
                        EvaIcons.star,
                        color: Style.Colors.secondColor,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
}
