import 'package:fpdart/fpdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'exceptions.dart';

const String address = 'ws://192.168.1.135';

TaskEither<ServerException, int> createGameRequest(
  String playerName,
  int goal,
) {
  // Connect to base server websocket
  final channel = WebSocketChannel.connect(
    Uri.parse("$address:9000"),
  );

  final channelReady = TaskEither<ServerException, void>.tryCatch(
    () => channel.ready,
    (error, __) => ConnectionFailure(),
  );

  final sendMsg = TaskEither<ServerException, void>.of(
      channel.sink.add("CreateGame:$goal"));

  final getGameId = TaskEither<ServerException, int>.tryCatch(
    () => channel.stream.first.then((value) => int.parse(value)),
    (error, __) => GameIdFailure(),
  );

  final closeChannel = TaskEither<ServerException, void>.tryCatch(
    () => channel.sink.close(),
    (error, __) => CloseChannelFailure(),
  );

  return channelReady
      .call(sendMsg)
      .call(getGameId)
      .chainFirst((_) => closeChannel);
}

TaskEither<ServerException, WebSocketChannel> getGameChannel(
  String playerName,
  int gameId,
) {
  final channel = WebSocketChannel.connect(
    Uri.parse('$address:$gameId'),
  );

  final channelReady = TaskEither<ServerException, void>.tryCatch(
    () => channel.ready,
    (error, __) => ConnectionFailure(),
  );

  final getChannel = TaskEither<ServerException, WebSocketChannel>.of(channel);

  return channelReady.call(getChannel);
}
