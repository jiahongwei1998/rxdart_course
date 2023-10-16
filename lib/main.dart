import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

@immutable
class Bloc {
  final Sink<String?> setFirstName;
  final Sink<String?> setLastName;
  final Stream<String> fullName;

  const Bloc._({
    required this.setFirstName,
    required this.setLastName,
    required this.fullName,
  });

  void dispose() {
    setFirstName.close();
    setLastName.close();
  }

  factory Bloc() {
    final firstNameSubject = BehaviorSubject<String?>();
    final lastNameSubject = BehaviorSubject<String?>();

    final Stream<String> fullName = Rx.combineLatest2(
        firstNameSubject.startWith(null), lastNameSubject.startWith(null),
        (firstName, lastName) {
      if (firstName != null &&
          firstName.isNotEmpty &&
          lastName != null &&
          lastName.isNotEmpty) {
        return '$firstName $lastName';
      } else {
        return 'Both first and last name must be provided';
      }
    });
    return Bloc._(
        setFirstName: firstNameSubject.sink,
        setLastName: lastNameSubject.sink,
        fullName: fullName);
  }
}

Stream<String> getNames({required String filePath}) {
  final names = rootBundle.loadString(filePath);
  return Stream.fromFuture(names).transform(const LineSplitter());
}

Stream<String> getAllNames() => getNames(filePath: 'assets/texts/cats.txt')
    .concatWith([getNames(filePath: 'assets/texts/dogs.txt')]).delay(
        const Duration(seconds: 3));

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
    bloc = Bloc();
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
        title: const Center(child: Text('CombineLatest with RxDart')),
      ),
      body: FutureBuilder<List<String>>(
        future: getAllNames().toList(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              final names = snapshot.requireData;
              return ListView.separated(
                itemBuilder: (context, index) => ListTile(
                  title: Text(names[index]),
                ),
                separatorBuilder: (_, __) => const Divider(
                  color: Colors.black,
                ),
                itemCount: names.length,
              );
          }
        },
      ),
    );
  }
}
