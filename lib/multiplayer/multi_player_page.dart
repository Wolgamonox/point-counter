import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:fpdart/fpdart.dart' hide State;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../common/utils.dart';
import '../common/router_utils.dart';
import '../common/add_button.dart';
import '../common/drawer.dart';
import 'model/game_state.dart';
import 'server/actions.dart';
import 'server/config.dart';
import 'server/exceptions.dart';

// TODO handle server crashing ?

// TODO big refactor

class MultiPlayerPage extends StatefulWidget {
  const MultiPlayerPage(
      {super.key, required this.gameId, required this.playerName});

  final int gameId;
  final String playerName;

  @override
  State<MultiPlayerPage> createState() => _MultiPlayerPageState();
}

class _MultiPlayerPageState extends State<MultiPlayerPage> {
  late final Future<Either<ServerException, WebSocketChannel>> channelEither;
  final log = Logger();

  // Local Counter
  int _counter = 0;
  int undoQueueSize = 20;
  final Queue<int> _lastNumbers = Queue<int>();

  void _updateLastNumbers(int number) {
    _lastNumbers.addLast(_counter);
    if (_lastNumbers.length > undoQueueSize) {
      _lastNumbers.removeFirst();
    }
  }

  void _addToCounter(WebSocketChannel channel, int num) {
    if (_counter != 999) {
      _updateLastNumbers(_counter);
    }

    setState(() {
      _counter += num;
      _counter = _counter.clamp(0, 999);

      channel.sink.add(generatePointEvent(_counter));
    });
  }

  void _undo(WebSocketChannel channel) {
    if (_lastNumbers.isNotEmpty) {
      setState(() {
        _counter = _lastNumbers.removeLast();
        channel.sink.add(generatePointEvent(_counter));
      });
    }
  }

  void _resetCounter(WebSocketChannel channel) {
    _updateLastNumbers(_counter);
    setState(() {
      _counter = 0;
      channel.sink.add(generatePointEvent(_counter));
    });
  }

  @override
  void initState() {
    // Open connection
    channelEither = getGameChannel(widget.playerName, widget.gameId).run();

    // Send player join event
    channelEither.then(
      (channel) => channel.match(
        (err) => log.e("Error when joining game: ${err.runtimeType}"),
        (channel) => channel.sink.add(playerAddMsg()),
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    channelEither.then(
      (channel) => channel.match(
        (err) => log.e(
            "Error when disposing game channel connection: ${err.runtimeType}"),
        (channel) => channel.sink.close(),
      ),
    );
    super.dispose();
  }

  String generatePointEvent(int newPoints) {
    return '{"PointEvent":{"player_name":"${widget.playerName}","new_points":$newPoints}}';
  }

  String playerAddMsg() {
    return '{"PlayerJoin":{"client_addr":null,"player_name":"${widget.playerName}"}}';
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Scan code to join game"),
          content: Container(
            alignment: Alignment.center,
            height: 200.0,
            width: 200.0,
            child: QrImageView(
              data:
                  'http://$address/#/multi/join/${widget.gameId}',
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: channelEither,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: AlertDialog(
              title: Text("Error when joining game ${widget.gameId}."),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    clearAndNavigate(context, '/multi');
                  },
                  child: const Text("Go back"),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final page = snapshot.requireData.match(
          (err) => Scaffold(
            body: AlertDialog(
              title: Text("Game ${widget.gameId} does not exist"),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    clearAndNavigate(context, '/multi');
                  },
                  child: const Text("Go back"),
                ),
              ],
            ),
          ),
          (channel) => Scaffold(
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
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: _showMyDialog,
                  icon: const Icon(Icons.qr_code_2),
                ),
                const SizedBox(width: 5.0),
                IconButton(
                  onPressed: () => _undo(channel),
                  icon: const Icon(Icons.undo),
                ),
                const SizedBox(width: 5.0),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _resetCounter(channel),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ],
            ),
            drawer: const AppDrawer(),
            body: Column(
              children: [
                Expanded(
                  flex: 10,
                  child: StreamBuilder(
                    stream: channel.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      GameState gameState = GameState.fromJson(
                        jsonDecode(snapshot.requireData),
                      );

                      final ScrollController scrollController =
                          ScrollController();

                      // Sort players so as to have the current player in front
                      final currentPlayer = gameState.players.firstWhere((player) => player.name == widget.playerName);
                      var players = gameState.players.toList();
                      players.remove(currentPlayer);
                      players.insert(0, currentPlayer);

                      return Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                              }),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ListView.separated(
                                  controller: scrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: players.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    double progress =
                                        players[index].points /
                                            gameState.goal;

                                    Color? color;
                                    if (index == 0) {
                                      color = Theme.of(context).colorScheme.primaryContainer;
                                    }

                                    return Card(
                                      color: color,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  players[index].name,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "${players[index].points}",
                                                  style: const TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 8.0),
                                            SizedBox.square(
                                              dimension: 30.0,
                                              child: CircularProgressIndicator(
                                                value: progress,
                                                color:
                                                    progressToColor(progress),
                                                backgroundColor:
                                                    Colors.grey.shade400,
                                                strokeWidth: 6.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const SizedBox(
                                    width: 4.0,
                                  ),
                                ),
                              ),
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
                        ],
                      );
                    },
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
                        SimpleAddButton(
                          number: 1,
                          addFunc: (number) => _addToCounter(channel, number),
                        ),
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
                        SimpleAddButton(
                          number: 2,
                          addFunc: (number) => _addToCounter(channel, number),
                        ),
                        const SizedBox(width: 8.0),
                        SimpleAddButton(
                          number: 5,
                          addFunc: (number) => _addToCounter(channel, number),
                        ),
                        const SizedBox(width: 8.0),
                        SimpleAddButton(
                          number: 10,
                          addFunc: (number) => _addToCounter(channel, number),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        return page;
      },
    );
  }
}
