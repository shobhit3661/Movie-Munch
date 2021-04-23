import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_munch/bloc/get_movie_videos_bloc.dart';
import 'package:movie_munch/model/movie.dart';
import 'package:movie_munch/style/theme.dart' as Style;
import 'package:movie_munch/widgets/casts.dart';
import 'package:movie_munch/widgets/movie_info.dart';
import 'package:movie_munch/widgets/similar_movies.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  MovieDetailScreen({Key key, @required this.movie}) : super(key: key);
  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState(movie);
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference db = FirebaseFirestore.instance.collection('data');
  bool _active = false;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  String userEmail;
  final Movie movie;
  _MovieDetailScreenState(this.movie);
  @override
  void initState() {
    super.initState();
    movieVideosBloc..getMovieVideos(movie.id);
  }

  @override
  void dispose() {
    super.dispose();
    movieVideosBloc..drainStream();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        userEmail = user.email;
      }
    } catch (e) {
      print("getCurrentUser error :$e");
    }
  }

  // void checkStatus() {
  //   db.doc(userEmail).get().then((DocumentSnapshot documentSnapshot) {
  //     if (documentSnapshot.exists) {
  //       Map<String, dynamic> data = documentSnapshot.data();
  //       for (int i = 0; i < data['Movieid'].length; i++) {
  //         if (movie.id == data['Movieid'][i]) {
  //           print(movie.id);
  //         }
  //       }
  //     }
  //   });
  // }

  void _changeState() {
    setState(() {
      _active = !_active;
    });
  }

  void updateUser() {
    getCurrentUser();
    Map<String, dynamic> movieMap = ({
      'id': movie.id,
      'popularity': movie.popularity,
      'title': movie.title,
      'backPoster': movie.backPoster,
      'poster': movie.poster,
      'overview': movie.overview,
      'rating': movie.rating
    });
    List<dynamic> elements = [movieMap];
    db.doc(userEmail).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        db
            .doc(userEmail)
            .update({'MovieList': FieldValue.arrayUnion(elements)})
            .then((value) => print("user updates"))
            .catchError((error) => print("Faild to update user: $error"));
      } else {
        db
            .doc(userEmail)
            .set({'MovieList': FieldValue.arrayUnion(elements)})
            .then((value) => print("user added"))
            .catchError((error) => print("Faild to add user: $error"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      body: new Builder(
        builder: (context) {
          return new CustomScrollView(
            slivers: <Widget>[
              new SliverAppBar(
                backgroundColor: Style.Colors.mainColor,
                expandedHeight: 200.0,
                pinned: true,
                flexibleSpace: new FlexibleSpaceBar(
                    title: Text(
                      movie.title.length > 40
                          ? movie.title.substring(0, 37) + "..."
                          : movie.title,
                      style: TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.normal),
                    ),
                    background: Stack(
                      children: <Widget>[
                        Container(
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    "https://image.tmdb.org/t/p/original/" +
                                        movie.backPoster)),
                          ),
                          child: new Container(
                            decoration: new BoxDecoration(
                                color: Colors.black.withOpacity(0.5)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: [
                                  0.1,
                                  0.9
                                ],
                                colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.black.withOpacity(0.0)
                                ]),
                          ),
                        ),
                      ],
                    )),
              ),
              SliverPadding(
                padding: EdgeInsets.all(0.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              movie.rating.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            RatingBar.builder(
                              itemSize: 10.0,
                              initialRating: movie.rating / 2,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 2.0),
                              itemBuilder: (context, _) => Icon(
                                EvaIcons.star,
                                color: Style.Colors.secondColor,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            )
                          ],
                        ),
                      ),
                      // ignore: deprecated_member_use
                      FlatButton(
                        color: Style.Colors.secondColor,
                        onPressed: () {
                          _changeState();
                          updateUser();
                        },
                        child: Text(
                          _active ? 'Added' : 'Add',
                          style: TextStyle(color: Style.Colors.mainColor),
                        ),
                        shape: RoundedRectangleBorder(
                            side:
                                BorderSide(width: 1, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                        child: Text(
                          "OVERVIEW",
                          style: TextStyle(
                              color: Style.Colors.titleColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12.0),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          movie.overview,
                          style: TextStyle(
                              color: Colors.white, fontSize: 12.0, height: 1.5),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      MovieInfo(
                        id: movie.id,
                      ),
                      Casts(
                        id: movie.id,
                      ),
                      SimilarMovies(id: movie.id)
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
