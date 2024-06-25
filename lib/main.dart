import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'multiplayer/multi_player_page.dart';
import 'singleplayer/single_player_page.dart';
import 'multiplayer/multi_player_start_page.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MyApp());
}

/// The route configuration.
final GoRouter _router = GoRouter(
  initialLocation: '/single',
  routes: <RouteBase>[
    GoRoute(
      path: '/single',
      builder: (BuildContext context, GoRouterState state) {
        return const SinglePlayerPage();
      },
    ),
    GoRoute(
        path: '/multi',
        builder: (BuildContext context, GoRouterState state) {
          return const MultiPlayerStartPage();
        },
        routes: [
          GoRoute(
              path: 'join/:gameId',
              builder: (BuildContext context, GoRouterState state) {
                int? gameId = state.pathParameters['gameId'] != null
                    ? int.parse(state.pathParameters['gameId']!)
                    : null;
                return MultiPlayerPage(gameId: gameId);
              }),
        ]),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Point counter',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.bebasNeueTextTheme(),
      ),
      routerConfig: _router,
    );
  }
}
