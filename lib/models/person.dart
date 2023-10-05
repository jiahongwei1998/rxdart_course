import 'package:flutter/foundation.dart';
import 'package:rxdart_course/models/thing.dart';

@immutable
class Person extends Thing {
  final int age;
  const Person({required this.age, required super.name});

  @override
  String toString() => 'Person, name: $name, age:$age';

  Person.fromJson(Map<String, dynamic> json)
      : age = json['age'] as int,
        super(name: json['name'] as String);
}

extension TrimmedCaseInsensitiveContain on String {
  bool trimmedContains(String other) =>
      trim().toLowerCase().contains(other.trim().toLowerCase());
}
