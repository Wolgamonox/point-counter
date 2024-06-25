import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:point_counter/common/drawer.dart';

import '../common/add_button.dart';
import '../common/utils.dart';

class SinglePlayerPage extends StatefulWidget {
  const SinglePlayerPage({super.key});

  @override
  State<SinglePlayerPage> createState() => _SinglePlayerPageState();
}

class _SinglePlayerPageState extends State<SinglePlayerPage> {
  int _counter = 0;
  int _goal = 0;

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

  void _setGoal(int newGoal) {
    setState(() {
      _goal = newGoal.clamp(0, 999);
    });
  }

  Future<void> _showSetGoalDialog() async {
    TextEditingController controller = TextEditingController()..text;

    final _formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (context) => Form(
        key: _formKey,
        child: AlertDialog(
          title: const Text("Goal"),
          content: TextFormField(
            autofocus: true,
            controller: controller,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a point Goal';
              } else if (int.tryParse(value) == null ||
                  int.tryParse(value)! < 0) {
                return 'Please enter a positive number';
              }
              return null;
            },
            onFieldSubmitted: (value) {
              if (_formKey.currentState!.validate()) {
                _setGoal(int.parse(controller.value.text));
                Navigator.of(context).pop();
              }
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _setGoal(int.parse(controller.value.text));
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Ok"),
            ),
          ],
        ),
      ),
    );
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
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton.icon(
                      onPressed: () => _showSetGoalDialog(),
                      label: Text(
                        "$_goal",
                        style: const TextStyle(fontSize: 36.0),
                      ),
                      icon: const Icon(
                        Icons.flag,
                        size: 36.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  _goal > 0
                      ? SizedBox.square(
                          dimension: 30.0,
                          child: CircularProgressIndicator(
                            value: _counter / _goal,
                            color: progressToColor(_counter / _goal),
                            backgroundColor: Colors.grey.shade300,
                            strokeWidth: 8.0,
                          ),
                        )
                      : Container(),
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
