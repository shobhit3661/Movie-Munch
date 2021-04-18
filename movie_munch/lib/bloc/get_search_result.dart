import 'package:flutter/material.dart';
import 'package:movie_munch/model/movie_response.dart';
import 'package:movie_munch/repository/repository.dart';
import 'package:rxdart/rxdart.dart';

class SearchResultBloc {
  final MovieRepository _repository = MovieRepository();
  final BehaviorSubject<MovieResponse> _subject =
      BehaviorSubject<MovieResponse>();

  getMovies(String s) async {
    MovieResponse response = await _repository.getSeach(s);
    _subject.sink.add(response);
  }

  void drainStream() {
    _subject.drain();
  }

  @mustCallSuper
  void dispose() async {
    await _subject.drain();
    _subject.close();
  }

  BehaviorSubject<MovieResponse> get subject => _subject;
}

final searchResult = SearchResultBloc();
