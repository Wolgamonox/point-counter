import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_counter/common/drawer.dart';

class MultiPlayerStartPage extends StatelessWidget {
  const MultiPlayerStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: Scaffold.of(context).openDrawer,
            );
          },
        ),
        title: const Text(
          'Point Counter',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 72.0,
                width: 256.0,
                child: FilledButton(
                  onPressed: () => context.go("/multi/create"),
                  child: const Text(
                    "Create Game",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32.0),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              SizedBox(
                height: 72.0,
                width: 256.0,
                child: ElevatedButton(
                  onPressed: () => context.go("/multi/join"),
                  child: const Text(
                    "Join Game",
                    style: TextStyle(fontSize: 32.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
