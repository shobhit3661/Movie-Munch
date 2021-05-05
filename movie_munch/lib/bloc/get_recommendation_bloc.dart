import 'package:flutter/material.dart';
import 'package:movie_munch/model/movie_response.dart';
import 'package:movie_munch/repository/repository.dart';
import 'package:rxdart/rxdart.dart';

class GetRecommendationBloc {
  final MovieRepository _repository = MovieRepository();
  final BehaviorSubject<MovieResponse> _subject =
      BehaviorSubject<MovieResponse>();

  getRecommendation(int id) async {
    MovieResponse response = await _repository.getRecommendation(id);
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

final recommendationResult = GetRecommendationBloc();
