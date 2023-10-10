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

typedef AsyncSnapshotBuilderCallback<T> = Widget Function(
  BuildContext context,
  T? value,
);

class AsyncSnapshotBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final AsyncSnapshotBuilderCallback<T>? onNone;
  final AsyncSnapshotBuilderCallback<T>? onWaiting;
  final AsyncSnapshotBuilderCallback<T>? onActive;
  final AsyncSnapshotBuilderCallback<T>? onDone;

  const AsyncSnapshotBuilder({
    super.key,
    required this.stream,
    this.onNone,
    this.onWaiting,
    this.onActive,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            final callback = onNone ?? (_, __) => const SizedBox();
            return callback(context, snapshot.data);
          case ConnectionState.waiting:
            final callback =
                onWaiting ?? (_, __) => const CircularProgressIndicator();
            return callback(context, snapshot.data);
          case ConnectionState.active:
            final callback = onActive ?? (_, __) => const SizedBox();
            return callback(context, snapshot.data);
          case ConnectionState.done:
            final callback = onDone ?? (_, __) => const SizedBox();
            return callback(context, snapshot.data);
        }
      },
    );
  }
}

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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter first name here...',
              ),
              onChanged: bloc.setFirstName.add,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter last name here...',
              ),
              onChanged: bloc.setLastName.add,
            ),
            AsyncSnapshotBuilder(
              stream: bloc.fullName,
              onActive: (context, value) {
                return Text(value ?? '');
              },
            ),
          ],
        ),
      ),
    );
  }
}
