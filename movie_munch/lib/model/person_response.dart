import 'package:movie_munch/model/person.dart';

class PersonResponse {
  final List<Person> persons;
  final String error;

  PersonResponse(this.persons, this.error);

  PersonResponse.fromJson(Map<String, dynamic> json)
      : persons =
            (json["results"] as List).map((i) => Person.fromJson(i)).toList(),
        error = "";

  PersonResponse.withError(String errorValue)
      // ignore: deprecated_member_use
      : persons = List(),
        error = errorValue;
}
