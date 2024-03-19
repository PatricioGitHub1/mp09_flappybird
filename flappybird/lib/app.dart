import 'package:cupertino_base/app_data.dart';
import 'package:cupertino_base/ft_game.dart';
import 'package:cupertino_base/ft_main_overlay.dart';
import 'package:cupertino_base/main_menu.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'waiting_menu.dart';


class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define your app's theme
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("FlappyBird : Battle Royale"),) // Set the app bar title
        ),
        body: Consumer<AppData>(
          builder: (context, appData, _) {
            switch (appData.screen) {

              case CurrentScreen.login:
                return MainMenuForm();

              case CurrentScreen.waiting:
                return WaitingMenu();

              case CurrentScreen.playing:
                return GameWidget<FtGame>.controlled(
                  gameFactory: FtGame.new,
                  overlayBuilderMap: {
                    'MainOverlay': (_, game) => FtMainOverlay(game: game),
                  },
                  initialActiveOverlays: const ['MainOverlay'],
                );
              default:
                return MainMenuForm();
            }
          },
        ),
      ),
    );
  }
}