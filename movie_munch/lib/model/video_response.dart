import 'package:movie_munch/model/video.dart';

class VideoResponse {
  final List<Video> videos;
  final String error;

  VideoResponse(this.videos, this.error);

  VideoResponse.fromJson(Map<String, dynamic> json)
      : videos = (json["results"] as List)
            .map((i) => new Video.fromJson(i))
            .toList(),
        error = "";

  VideoResponse.withError(String errorValue)
      // ignore: deprecated_member_use
      : videos = List(),
        error = errorValue;
}
