import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_munch/bloc/get_movie_videos_bloc.dart';
import 'package:movie_munch/bloc/get_recommendation_bloc.dart';
import 'package:movie_munch/model/movie.dart';
import 'package:movie_munch/model/movie_response.dart';
import 'package:movie_munch/style/theme.dart' as Style;
import 'package:movie_munch/widgets/casts.dart';
import 'package:movie_munch/widgets/movie_info.dart';
import 'package:movie_munch/widgets/similar_movies.dart';
import 'package:rxdart/rxdart.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  MovieDetailScreen({Key key, @required this.movie}) : super(key: key);
  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState(movie);
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  String userEmail;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference db = FirebaseFirestore.instance.collection('data');
  bool _active = false;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  final Movie movie;
  _MovieDetailScreenState(this.movie);
  @override
  void initState() {
    getCurrentUser();
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

        db.doc(userEmail).get().then((DocumentSnapshot documentData) {
          if (documentData.exists) {
            Map<String, dynamic> documentdata = documentData.data();
            for (int i = 0; i < documentdata['MovieList'].length; i++) {
              if (documentdata['MovieList'][i]['id'] == movie.id) {
                _changeState();
              }
            }
          }
        });
      }
    } catch (e) {
      print("getCurrentUser error :$e");
    }
  }

  void _changeState() {
    setState(() {
      _active = !_active;
    });
  }

  List<Movie> getRecommendation() {
    try {
      recommendationResult.getRecommendation(movie.id);
      Stream streamData = recommendationResult.subject.stream;
      BehaviorSubject<MovieResponse> responseData = streamData;
      MovieResponse finalResult = responseData.value;
      List<Movie> ans = finalResult.movies;
      if (ans.length == 0) {
        ans = getRecommendation();
      }
      return ans;
    } catch (e) {
      print('very bad error $e');
    }
  }

  void updateUser(bool state) {
    List<Movie> recommendationList = getRecommendation();
    List<dynamic> finalRecommendationList = List<dynamic>();
    String movieId = movie.id.toString();
    for (int i = 0; i < recommendationList.length; i++) {
      Map<String, dynamic> temp = ({
        'id': recommendationList[i].id,
        'popularity': recommendationList[i].popularity,
        'title': recommendationList[i].title,
        'backPoster': recommendationList[i].backPoster,
        'poster': recommendationList[i].poster,
        'overview': recommendationList[i].overview,
        'rating': recommendationList[i].rating
      });
      finalRecommendationList.add(temp);
    }

    if (state) {
      _changeState();
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
      db
          .doc(userEmail)
          .update({'MovieList': FieldValue.arrayRemove(elements)})
          .then((value) => print('Movie deleted'))
          .catchError((error) => print("error in removing $error"));

      db.doc(userEmail).collection('recommendation').doc(movieId).delete();
    } else {
      _changeState();
      int userCount;
      db.get().then((res) => userCount = res.size);
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
              .set({
                'userId': userCount + 610,
                'MovieList': FieldValue.arrayUnion(elements)
              })
              .then((value) => print("user added"))
              .catchError((error) => print("Faild to add user: $error"));
        }
      });
      db
          .doc(userEmail)
          .collection('recommendation')
          .doc(movieId)
          .set({'list': finalRecommendationList})
          .then((value) => print("Recommendation Added"))
          .catchError((error) => print('recommendation got error $error'));
    }
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
                          updateUser(_active);
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
