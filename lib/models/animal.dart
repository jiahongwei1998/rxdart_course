import 'package:flutter/foundation.dart';
import 'package:rxdart_course/models/thing.dart';

enum AnimalType { dog, cat, rabbit, unknown }

@immutable
class Animal extends Thing {
  final AnimalType type;

  const Animal({required this.type, required super.name});

  @override
  String toString() => 'Animal, name: $name, type:$type';

  factory Animal.fromJson(Map<String, dynamic> json) {
    final AnimalType animalType;
    switch ((json['type'] as String).toLowerCase().trim()) {
      case 'rabbit':
        animalType = AnimalType.rabbit;
        break;
      case 'dog':
        animalType = AnimalType.dog;
        break;
      case 'cat':
        animalType = AnimalType.cat;
        break;
      default:
        animalType = AnimalType.unknown;
    }

    return Animal(type: animalType, name: json['name'] as String);
  }
}
