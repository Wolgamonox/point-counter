import 'package:logger/logger.dart';
import 'package:point_counter/multiplayer/server/exceptions.dart';
import 'package:test/test.dart';

import 'package:point_counter/multiplayer/server/actions.dart';

void main() {
  group('Test CreateGame request', () {
    // TODO have a better setup that sets the server up to test both
    test('Should return an error if websocket could not connect', () async {
      final request = await createGameRequest("Bob", 100).run();

      expect(request.isLeft(), true);

      request.getLeft().match(
            () => {},
            (result) => expect(result, isA<ConnectionFailure>()),
          );
    });

    test('Should return a game ID if the connection succeeded', () async {
      final request = await createGameRequest("Bob", 100).run();

      final logger = Logger();
      logger.e("Error Creating game: ${request.getLeft().fold(
            () => null,
            (value) => value,
          ).runtimeType}");

      expect(request.isRight(), true);

      request.getRight().match(
            () => {},
            (result) => expect(result, isA<int>()),
          );
    });
  });
}
