import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../common/router_utils.dart';
import 'server/actions.dart';

Future createGame(BuildContext context, String playerName, int goal) async {
  final request = await createGameRequest(playerName, goal).run();

  if (context.mounted) {
    request.match(
      (err) {
        final logger = Logger();
        logger.e("Error Creating game: ${err.runtimeType}");

        context.go("/multi");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
            "Error while creating the game",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          )),
        );
      },
      (gameId) => joinGame(context, playerName, gameId),
    );
  }
}

void joinGame(BuildContext context, String playerName, int gameId) {
  if (context.mounted) {
    clearAndNavigate(context, '/multi/play/$gameId/$playerName');
  }
}

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController goalController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Form(
          key: formKey,
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
                decoration: const InputDecoration(
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
                  if (formKey.currentState!.validate()) {
                    createGame(
                      context,
                      nameController.text.trim(),
                      int.parse(goalController.text),
                    );
                  }
                },
                decoration: const InputDecoration(
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
                    onPressed: () => context.go("/multi"),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
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
    );
  }
}

class JoinGamePage extends StatefulWidget {
  const JoinGamePage({super.key, this.gameId});

  final int? gameId;

  @override
  State<JoinGamePage> createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  TextEditingController gameIdController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // Set initial value if the game id was provided through navigation
    gameIdController.text = widget.gameId != null ? "${widget.gameId}" : "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Form(
          key: formKey,
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
                  if (formKey.currentState!.validate()) {
                    joinGame(
                      context,
                      nameController.text.trim(),
                      int.parse(gameIdController.text),
                    );
                  }
                },
                decoration: const InputDecoration(
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
                onFieldSubmitted: (_) {
                  if (formKey.currentState!.validate()) {
                    joinGame(
                      context,
                      nameController.text.trim(),
                      int.parse(gameIdController.text),
                    );
                  }
                },
                decoration: const InputDecoration(
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
                    onPressed: () => context.go("/multi"),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
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
    );
  }
}
