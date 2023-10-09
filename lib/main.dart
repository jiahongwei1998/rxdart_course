import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

extension Log on Object {
  void log() => debugPrint(toString());
}

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum TypeOfTing { animal, person }

@immutable
class Thing {
  final TypeOfTing type;
  final String name;

  const Thing({required this.type, required this.name});
}

@immutable
class Bloc {
  final Sink<TypeOfTing?> setTypeOfThing; // write-only
  final Stream<TypeOfTing?> currentTypeOfThing; // read-only
  final Stream<Iterable<Thing>> things;

  const Bloc._({
    required this.setTypeOfThing,
    required this.currentTypeOfThing,
    required this.things,
  });

  void dispose() {
    setTypeOfThing.close();
  }

  factory Bloc({
    required Iterable<Thing> things,
  }) {
    final typeOfThingSubject = BehaviorSubject<TypeOfTing?>();
    final filteredThings = typeOfThingSubject
        .debounceTime(const Duration(milliseconds: 300))
        .map<Iterable<Thing>>((typeOfThing) {
      if (typeOfThing != null) {
        return things.where((element) => element.type == typeOfThing);
      } else {
        return things;
      }
    }).startWith(things);

    return Bloc._(
        setTypeOfThing: typeOfThingSubject.sink,
        currentTypeOfThing: typeOfThingSubject.stream,
        things: filteredThings);
  }
}

const things = [
  Thing(type: TypeOfTing.person, name: 'Foo'),
  Thing(type: TypeOfTing.person, name: 'Bar'),
  Thing(type: TypeOfTing.person, name: 'Baz'),
  Thing(type: TypeOfTing.animal, name: 'Bunz'),
  Thing(type: TypeOfTing.animal, name: 'Fluffers'),
  Thing(type: TypeOfTing.animal, name: 'Woofz'),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Bloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = Bloc(things: things);
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('FlitreChip with RxDart')),
      ),
      body: Column(
        children: [
          StreamBuilder<TypeOfTing?>(
            stream: bloc.currentTypeOfThing,
            builder: (context, snapshot) {
              final selectedTypeOfThing = snapshot.data;
              return Wrap(
                children: TypeOfTing.values
                    .map((typeOfThing) => FilterChip(
                          selectedColor: Colors.blueAccent[100],
                          onSelected: (selected) {
                            final type = selected ? typeOfThing : null;
                            bloc.setTypeOfThing.add(type);
                          },
                          label: Text(typeOfThing.name),
                          selected: selectedTypeOfThing == typeOfThing,
                        ))
                    .toList(),
              );
            },
          ),
          Expanded(
              child: StreamBuilder<Iterable<Thing>>(
            stream: bloc.things,
            builder: (context, snapshot) {
              final things = snapshot.data ?? [];
              return ListView.builder(
                itemCount: things.length,
                itemBuilder: (context, index) {
                  final thing = things.elementAt(index);
                  return ListTile(
                    title: Text(thing.name),
                    subtitle: Text(thing.type.name),
                  );
                },
              );
            },
          )),
        ],
      ),
    );
  }
}
