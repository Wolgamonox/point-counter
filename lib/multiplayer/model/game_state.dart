import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

@freezed
class Player with _$Player {
  const factory Player({
    required String name,
    required int points,
  }) = _Player;

  factory Player.fromJson(Map<String, Object?> json)
  => _$PlayerFromJson(json);
}

@freezed
class GameState with _$GameState {
  const factory GameState({
    required List<Player> players,
    required int goal,
  }) = _GameState;

  factory GameState.fromJson(Map<String, Object?> json)
  => _$GameStateFromJson(json);
}