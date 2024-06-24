import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void clearAndNavigate(BuildContext context, String path) {
  while (context.canPop() == true) {
    context.pop();
  }
  context.pushReplacement(path);
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
              onPressed: () => clearAndNavigate(context, '/single'),
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
              onPressed: () => clearAndNavigate(context, '/multi'),
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
    );
  }
}
