import 'package:flutter/material.dart';
import 'package:movie_munch/bloc/get_search_result.dart';
import 'package:movie_munch/model/movie.dart';
import 'package:movie_munch/model/movie_response.dart';
import 'package:movie_munch/screens/detail_screen.dart';
import 'package:movie_munch/style/theme.dart' as Style;

class ResultInfo extends StatefulWidget {
  final String searchString;
  ResultInfo({Key key, @required this.searchString}) : super(key: key);
  @override
  _MovieInfoState createState() => _MovieInfoState(searchString);
}

class _MovieInfoState extends State<ResultInfo> {
  // final String searchString;
  _MovieInfoState(this.searchString);
  @override
  void initState() {
    super.initState();
    searchResult.getMovies(widget.searchString);
    print(widget.searchString);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MovieResponse>(
      stream: searchResult.subject.stream,
      builder: (context, AsyncSnapshot<MovieResponse> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.error != null && snapshot.data.error.length > 0) {
            return _buildErrorWidget(snapshot.data.error);
          }
          return _buildMovieDetailWidget(snapshot.data);
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error);
        } else {
          return _buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [],
    ));
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Error occured: $error"),
      ],
    ));
  }

  Widget _buildMovieDetailWidget(MovieResponse data) {
    List<Movie> movies = data.movies;
    if (movies.length == 0) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "No More Movies",
                  style: TextStyle(color: Colors.black45),
                )
              ],
            )
          ],
        ),
      );
    } else
      return Scaffold(
        backgroundColor: Style.Colors.mainColor,
        body: ListView.builder(
          itemCount: movies.length,
          itemBuilder: (_, index) {
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MovieDetailScreen(movie: movies[index]),
                  ),
                );
              },
              title: Text(
                movies[index].title,
                style:
                    TextStyle(height: 1.5, color: Colors.white, fontSize: 18.0),
              ),
              leading: Icon(Icons.collections, color: Style.Colors.secondColor),
            );
          },
        ),
      );
  }
}
