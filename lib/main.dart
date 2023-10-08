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

void testIt() async {
  final steam1 = Stream.periodic(
    const Duration(seconds: 1),
    (count) => 'Steam 1, count = $count',
  );
  final steam2 = Stream.periodic(
    const Duration(seconds: 3),
    (count) => 'Steam 2, count = $count',
  );
  final combined = Rx.combineLatest2(
    steam1,
    steam2,
    (one, two) => 'One = ($one), two = ($two)',
  );
  await for (final value in combined) {
    value.log();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    testIt();
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Home Page')),
      ),
    );
  }
}
