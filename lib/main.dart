import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

// import 'package:flutter/rendering.dart';

void main() {
  // debugPaintSizeEnabled=true;
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Point counter',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.orbitronTextTheme(),
      ),
      home: const HomePage(title: 'Point Counter'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

// single ticker provider thing is for the animation
class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;

  int undoQueueSize = 20;
  final Queue<int> _lastNumbers = Queue<int>();

  void _updateLastNumbers(int number) {
    _lastNumbers.addLast(_counter);
    if (_lastNumbers.length > undoQueueSize) {
      _lastNumbers.removeFirst();
    }
  }

  void _addToCounter(int num) {
    _updateLastNumbers(_counter);
    setState(() {
      _counter += num;
    });
  }

  void _undo() {
    if (_lastNumbers.isNotEmpty) {
      setState(() {
        _counter = _lastNumbers.removeLast();
      });
    }
  }

  void _resetCounter() {
    _updateLastNumbers(_counter);
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _undo,
            icon: const Icon(Icons.undo),
          ),
          const SizedBox(width: 5.0),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCounter,
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Expanded(
              flex: 1,
              child: Center(child: Text("Goal: 120")),
            ),
            Expanded(
              flex: 7,
              child: Center(
                child: TextButton(
                  onPressed: () {},
                  child: Stack(
                    alignment: Alignment.center,
                    // decoration: BoxDecoration(color: Colors.brown),
                    // padding: EdgeInsets.only(bottom: 20.0),
                    children: [
                      Text(
                        '$_counter',
                        style: const TextStyle(
                          fontSize: 120.0,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox.square(
                        dimension: 148.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 16.0,
                          value: 0.80,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SimpleAddButton(number: 1, addFunc: _addToCounter),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SimpleAddButton(number: 2, addFunc: _addToCounter),
                    const SizedBox(width: 8.0),
                    SimpleAddButton(number: 5, addFunc: _addToCounter),
                    const SizedBox(width: 8.0),
                    SimpleAddButton(number: 10, addFunc: _addToCounter),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleAddButton extends StatelessWidget {
  const SimpleAddButton(
      {super.key, required this.number, required this.addFunc});

  final int number;
  final Function(int number) addFunc;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton(
        onPressed: () {
          addFunc(number);
        },
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // <-- Radius
          ),
        ),
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}
