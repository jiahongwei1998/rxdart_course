import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rxdart/rxdart.dart';

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
    );
  }
}

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Create our behavior subject every time widget is rebuilt.
    final subject = useMemoized(
      () => BehaviorSubject<String>(),
      [key],
    );

    // Dispose of the old subject every time widget is rebuilt.
    useEffect(() => subject.close, [subject]);

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<String>(
          stream: subject.stream
              .distinct()
              .debounceTime(const Duration(seconds: 1)),
          initialData: 'Please start typing',
          builder: (context, snapshot) {
            return Text(snapshot.requireData);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          onChanged: (value) {
            subject.sink.add(value);
          },
        ),
      ),
    );
  }
}
