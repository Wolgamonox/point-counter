import 'package:flutter/material.dart';

import '../common/drawer.dart';

class MultiPlayerPage extends StatefulWidget {
  const MultiPlayerPage({super.key, this.gameId});

  final int? gameId;

  @override
  State<MultiPlayerPage> createState() => _MultiPlayerPageState();
}

class _MultiPlayerPageState extends State<MultiPlayerPage> {
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
        title: Text(
          'Game ${widget.gameId}',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        // actions: <Widget>[
        //   IconButton(
        //     onPressed: _undo,
        //     icon: const Icon(Icons.undo),
        //   ),
        //   const SizedBox(width: 5.0),
        //   IconButton(
        //     icon: const Icon(Icons.refresh),
        //     onPressed: _resetCounter,
        //     padding: const EdgeInsets.symmetric(horizontal: 10),
        //   ),
        // ],
      ),
      drawer: const AppDrawer(),
    );
  }
}
