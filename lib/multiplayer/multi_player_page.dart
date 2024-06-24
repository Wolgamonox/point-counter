import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:point_counter/common/drawer.dart';

Future<void> _showCreateGameDialog(BuildContext context) async {
  TextEditingController nameController = TextEditingController();
  TextEditingController goalController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) => Dialog.fullscreen(
      child: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Create a new game",
                style: TextStyle(fontSize: 32.0),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: nameController,
                autocorrect: false,
                validator: (value) {
                  RegExp numbersAndLetters = RegExp(r"^[a-zA-Z0-9_.-]*$");

                  if (value == null || value.isEmpty) {
                    return 'Please enter a player name';
                  } else if (!numbersAndLetters.hasMatch(value)) {
                    return 'Please use only letters and numbers';
                  }
                  return null;
                },
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  labelText: "Player Name",
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: goalController,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a point Goal';
                  } else if (int.tryParse(value) == null) {
                    return 'Please enter a number';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                  labelText: "Point Goal",
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print("player: ${nameController.text}");
                        print("goal: ${goalController.text}");

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Creating game ... ')),
                        );
                      }
                    },
                    child: const Text('Start Game'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class MultiPlayerPage extends StatelessWidget {
  const MultiPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

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
        actions: const <Widget>[
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.undo),
          // ),
          // const SizedBox(width: 5.0),
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   onPressed: () {},
          //   padding: const EdgeInsets.symmetric(horizontal: 10),
          // ),
        ],
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
                  onPressed: () => _showCreateGameDialog(context),
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
                  onPressed: () {},
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

///
/// Expanded(
//               flex: 1,
//               child: ScrollConfiguration(
//                 behavior:
//                     ScrollConfiguration.of(context).copyWith(dragDevices: {
//                   PointerDeviceKind.touch,
//                   PointerDeviceKind.mouse,
//                 }),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: ListView.separated(
//                     controller: scrollController,
//                     scrollDirection: Axis.horizontal,
//                     itemBuilder: (BuildContext context, int index) {
//                       return Card(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   Text(
//                                     "Player ${index + 1}",
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   const Text(
//                                     "68",
//                                     style:
//                                         TextStyle(fontStyle: FontStyle.italic),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(width: 8.0),
//                               const SizedBox.square(
//                                 dimension: 30.0,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.green,
//                                   value: 0.87,
//                                   strokeWidth: 6.0,
//                                   strokeCap: StrokeCap.round,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                     separatorBuilder: (BuildContext context, int index) =>
//                         const SizedBox(
//                       width: 4.0,
//                     ),
//                     itemCount: 9,
//                   ),
//                 ),
//               ),
//             ),
