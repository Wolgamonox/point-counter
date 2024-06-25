import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:point_counter/common/router_utils.dart';

Future<void> createGame(
  BuildContext context,
  String playerName,
  int goal,
) async {
  // Connect to base server websocket
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://127.0.0.1:9000'),
  );

  // Request a game creation
  channel.sink.add("CreateGame:$goal");

  // Get game id
  int gameId = 0;
  await for (String event in channel.stream) {
    if (event.isNotEmpty) {
      gameId = int.parse(event);
      break;
    }
  }

  print("Created game: $gameId by player: $playerName");
  await channel.sink.close();

  // launch a the game
  joinGame(context, playerName, gameId);
}

void joinGame(BuildContext context, String playerName, int gameId) {
  clearAndNavigate(context, '/multi/join/$gameId/$playerName');
}

Future<void> showCreateGameDialog(BuildContext context) async {
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
                autofocus: true,
                validator: (value) {
                  RegExp numbersAndLetters = RegExp(r"^[a-zA-Z0-9_.-]*$");

                  if (value == null || value.isEmpty) {
                    return 'Please enter a player name';
                  } else if (!numbersAndLetters.hasMatch(value.trim())) {
                    return 'Please use only letters and numbers';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
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
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (_formKey.currentState!.validate()) {
                    createGame(
                      context,
                      nameController.text.trim(),
                      int.parse(goalController.text),
                    );
                  }
                },
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
                        createGame(
                          context,
                          nameController.text.trim(),
                          int.parse(goalController.text),
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

Future<void> showJoinGameDialog(BuildContext context) async {
  TextEditingController gameIdController = TextEditingController();
  TextEditingController nameController = TextEditingController();

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
                "Join a game",
                style: TextStyle(fontSize: 32.0),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: gameIdController,
                autocorrect: false,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a game ID';
                  } else if (int.tryParse(value) == null) {
                    return 'Please enter a number';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  if (_formKey.currentState!.validate()) {
                    joinGame(
                      context,
                      nameController.text.trim(),
                      int.parse(gameIdController.text),
                    );
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                  labelText: "Game ID",
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: nameController,
                autocorrect: false,
                validator: (value) {
                  RegExp numbersAndLetters = RegExp(r"^[a-zA-Z0-9_.-]*$");

                  if (value == null || value.isEmpty) {
                    return 'Please enter a player name';
                  } else if (!numbersAndLetters.hasMatch(value.trim())) {
                    return 'Please use only letters and numbers';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  labelText: "Player Name",
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
                        joinGame(
                          context,
                          nameController.text.trim(),
                          int.parse(gameIdController.text),
                        );
                      }
                    },
                    child: const Text('Join Game'),
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
