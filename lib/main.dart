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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final BehaviorSubject<DateTime> subject;
  late final Stream<String> streamOfStrings;

  @override
  void initState() {
    super.initState();
    subject = BehaviorSubject<DateTime>();
    streamOfStrings = subject.switchMap(
      (dateTime) => Stream.periodic(
        const Duration(seconds: 1),
        (count) => 'Stream count = $count, dateTime = $dateTime',
      ),
    );
  }

  @override
  void dispose() {
    subject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Home Page')),
      ),
      body: Column(children: [
        StreamBuilder<String>(
          stream: streamOfStrings,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final string = snapshot.requireData;
              return Text(string);
            } else {
              return const Text('Waiting for the button to be pressed');
            }
          },
        ),
        TextButton(
          onPressed: () {
            subject.add(DateTime.now());
          },
          child: const Text('Start the stream'),
        ),
      ]),
    );
  }
}
