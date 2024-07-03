import 'dart:convert';
import 'dart:ui';

import 'package:fpdart/fpdart.dart' hide State;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../common/utils.dart';
import '../common/add_button.dart';
import '../common/drawer.dart';
import 'model/game_state.dart';
import 'server/actions.dart';
import 'server/exceptions.dart';

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

  Widget _buildPageBody(WebSocketChannel channel) {
    return Column(
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

              int points = gameState.players
                  .firstWhere((player) => player.name == widget.playerName)
                  .points;

              final ScrollController scrollController = ScrollController();

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
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ListView.separated(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: gameState.players.length,
                          itemBuilder: (BuildContext context, int index) {
                            double progress = gameState.players[index].points /
                                gameState.goal;

                            return Card(
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
                                          gameState.players[index].name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${gameState.players[index].points}",
                                          style: const TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8.0),
                                    SizedBox.square(
                                      dimension: 30.0,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        color: progressToColor(progress),
                                        backgroundColor: Colors.grey.shade300,
                                        strokeWidth: 6.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
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
                        '$points',
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
                  addFunc: (newPoints) {
                    channel.sink.add(generatePointEvent(newPoints));
                  },
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
                  addFunc: (newPoints) {
                    channel.sink.add(generatePointEvent(newPoints));
                  },
                ),
                const SizedBox(width: 8.0),
                SimpleAddButton(
                  number: 5,
                  addFunc: (newPoints) {
                    channel.sink.add(generatePointEvent(newPoints));
                  },
                ),
                const SizedBox(width: 8.0),
                SimpleAddButton(
                  number: 10,
                  addFunc: (newPoints) {
                    channel.sink.add(generatePointEvent(newPoints));
                  },
                ),
              ],
            ),
          ),
        ),
      ],
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
        title: Text(
          'Game ${widget.gameId}',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.qr_code_2),
          ),
          const SizedBox(width: 5.0),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.undo),
          ),
          const SizedBox(width: 5.0),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
          future: channelEither,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final widget = snapshot.requireData.match(
              (err) => Center(
                child: Text("Error ${err.runtimeType}"),
              ),
              (channel) => _buildPageBody(channel),
            );

            return widget;
          }),
    );
  }
}
