import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Point counter',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomePage(title: 'Point Counter'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

// singletickerprovider thing is for the animation
class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;

  int undoQueueSize = 5;
  final Queue<int> _lastNumbers = Queue<int>();

  void _updateLastNumbers(int number) {
    _lastNumbers.addLast(_counter);
    if (_lastNumbers.length > undoQueueSize) {
      _lastNumbers.removeFirst();
    }
  }

  void _addToCounter(int num) {
    _updateLastNumbers(_counter);
    _animationController.forward().then((value) {
      _animationController.reverse();
    });
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
    setState(() {
      _counter = 0;
    });
  }

  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 250),
    vsync: this,
  );

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0.0, 0.1),
    end: const Offset(0.0, -0.1),
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOut,
  ));

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: _undo,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCounter,
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
        ],
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Spacer(),
              Center(
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Text(
                    '$_counter',
                    style: const TextStyle(
                      fontSize: 100.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SimpleAddButton(number: 1, addFunc: _addToCounter),
                    SimpleAddButton(number: 2, addFunc: _addToCounter),
                    SimpleAddButton(number: 5, addFunc: _addToCounter),
                    CustomAddButton(addFunc: _addToCounter),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SimpleAddButton extends StatelessWidget {
  const SimpleAddButton({Key? key, required this.number, required this.addFunc})
      : super(key: key);

  final int number;
  final Function(int number) addFunc;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: ElevatedButton(
          onPressed: () {
            addFunc(number);
          },
          child: Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomAddButton extends StatefulWidget {
  const CustomAddButton({Key? key, required this.addFunc}) : super(key: key);

  final Function(int number) addFunc;

  @override
  State<CustomAddButton> createState() => _CustomAddButtonState();
}

class _CustomAddButtonState extends State<CustomAddButton> {
  late TextEditingController _customAmountController;

  @override
  void initState() {
    _customAmountController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  Future<int?> openDialog() => showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Custom add"),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: "Enter custom amount"),
            controller: _customAmountController,
            keyboardType: TextInputType.number,
            onSubmitted: (_) {
              int? number = int.tryParse(_customAmountController.text);
              _customAmountController.clear();
              Navigator.of(context).pop(number);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                _customAmountController.clear();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Add"),
              onPressed: () {
                int? number = int.tryParse(_customAmountController.text);
                _customAmountController.clear();
                Navigator.of(context).pop(number);
              },
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: ElevatedButton(
          child: const Text(
            "Custom",
            style: TextStyle(
              fontSize: kIsWeb ? 24 : 14,
            ),
            softWrap: false,
          ),
          onPressed: () async {
            int? result = await openDialog();
            if (result != null) {
              widget.addFunc(result);
            }
          },
        ),
      ),
    );
  }
}
