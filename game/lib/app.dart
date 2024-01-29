import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';

import 'ft_game.dart';
import 'ft_main_overlay.dart';

// Main application widget
class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() => AppState();
}

// Main application state
class AppState extends State<App> {
  // Definir el contingut del widget 'App'
  @override
  Widget build(BuildContext context) {
    // Farem servir la base 'Cupertino'
    return GameWidget<FtGame>.controlled(
      gameFactory: FtGame.new,
      overlayBuilderMap: {
        'MainOverlay': (_, game) => FtMainOverlay(game: game),
      },
      initialActiveOverlays: const ['MainOverlay'],
    );
  }
}
