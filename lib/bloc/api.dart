import 'dart:convert';
import 'dart:io';

import 'package:rxdart_course/models/animal.dart';
import 'package:rxdart_course/models/person.dart';
import 'package:rxdart_course/models/thing.dart';

typedef SearchTerm = String;

class Api {
  List<Animal>? _animals;
  List<Person>? _persons;

  Future<List<Thing>> search(SearchTerm searchTerm) async {
    final term = searchTerm.trim().toLowerCase();
    // Search in the cache
    final cachedResults = _extractThingsUsingSearchTerm(term);
    if (cachedResults != null) {
      return cachedResults;
    }
    // We don't have hte values cached, let's call APIs
    // Start by calling persons API
    final persons = await _getJson('http://127.0.0.1:5500/apis/persons.json')
        .then((json) => json.map((e) => Person.fromJson(e)));
    _persons = persons.toList();
    // Then call animals API
    final animals = await _getJson('http://127.0.0.1:5500/apis/animals.json')
        .then((json) => json.map((e) => Animal.fromJson(e)));
    _animals = animals.toList();

    return _extractThingsUsingSearchTerm(term) ?? [];
  }

  List<Thing>? _extractThingsUsingSearchTerm(SearchTerm term) {
    final cachedAnimals = _animals;
    final cachedPersons = _persons;

    if (cachedAnimals != null && cachedPersons != null) {
      List<Thing> result = [];
      for (final animal in cachedAnimals) {
        if (animal.name.trimmedContains(term) ||
            animal.type.name.trimmedContains(term)) {
          result.add(animal);
        }
      }

      for (final person in cachedPersons) {
        if (person.name.trimmedContains(term) ||
            person.age.toString().trimmedContains(term)) {
          result.add(person);
        }
      }

      return result;
    }
    return null;
  }

  Future<List<dynamic>> _getJson(String url) => HttpClient()
      .getUrl(Uri.parse(url))
      .then((req) => req.close())
      .then((res) => res.transform(utf8.decoder).join())
      .then((jsonStr) => json.decode(jsonStr) as List<dynamic>);
}
