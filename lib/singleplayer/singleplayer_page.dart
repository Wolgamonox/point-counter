import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:point_counter/common/drawer.dart';

class SinglePlayerPage extends StatefulWidget {
  const SinglePlayerPage({super.key});

  @override
  State<SinglePlayerPage> createState() => _SinglePlayerPageState();
}

class _SinglePlayerPageState extends State<SinglePlayerPage> {
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
        title: const Text(
          'Point Counter',
          style: TextStyle(
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
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
