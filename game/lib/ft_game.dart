import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ft_player.dart';
import 'websocket_handler.dart';

class FtGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  FtGame();

  late WebSocketHandler websocket;
  late FtPlayer _player;
  int health = 3;

  @override
  Future<void> onLoad() async {
    //debugMode = true; // Uncomment to see the bounding boxes
    await images.loadAll([
      'player.png',
      'rocket.png',
    ]);
    camera.viewfinder.anchor = Anchor.topLeft;
    initializeGame(loadHud: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  void initializeGame({required bool loadHud}) {
    websocket = WebSocketHandler();
    websocket.connectToServer("localhost", 8888, serverMessageHandler);
    _player = FtPlayer(
        position: Vector2((canvasSize.x / 2), (canvasSize.y / 2)), game: this);
    world.add(_player);
  }

  void reset() {
    initializeGame(loadHud: false);
  }

  void serverMessageHandler(String message) {
    if (kDebugMode) {
      print("Message received: $message");
    }
  }
}
