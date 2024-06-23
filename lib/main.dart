import 'dart:collection';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

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
        textTheme: GoogleFonts.bebasNeueTextTheme(),
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
    if (_counter != 999) {
      _updateLastNumbers(_counter);
    }

    setState(() {
      _counter += num;
      _counter = _counter.clamp(0, 999);
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
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
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
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.center,
                height: 100.0,
                child: Text(
                  "Point Counter",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              const Divider(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
                child: const Text(
                  "Single player",
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
              const Divider(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
                child: const Text(
                  "Multiplayer",
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
              const Divider(),
              const Spacer(),
              const Divider(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
                child: const Text(
                  "About",
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.separated(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Player ${index + 1}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "68",
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8.0),
                              const SizedBox.square(
                                dimension: 30.0,
                                child: CircularProgressIndicator(
                                  color: Colors.green,
                                  value: 0.87,
                                  strokeWidth: 6.0,
                                  strokeCap: StrokeCap.round,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(
                      width: 4.0,
                    ),
                    itemCount: 9,
                  ),
                ),
              ),
            ),
            const Divider(),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      label: const Text(
                        "120",
                        style: TextStyle(fontSize: 36.0),
                      ),
                      icon: const Icon(
                        Icons.flag,
                        size: 36.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const SizedBox.square(
                    dimension: 30.0,
                    child: CircularProgressIndicator(
                      color: Colors.green,
                      value: 0.80,
                      strokeCap: StrokeCap.round,
                      strokeWidth: 8.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: Center(
                child: Text(
                  '$_counter',
                  style: const TextStyle(
                    fontSize: 150.0,
                    color: Colors.black,
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
