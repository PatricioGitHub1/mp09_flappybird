import 'dart:math';

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
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  void initializeGame({required bool loadHud}) {
    // Initialize websocket
    initializeWebSocket();
    _player =
        FtPlayer(position: Vector2((canvasSize.x / 2), (canvasSize.y / 2)));
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

  void initializeWebSocket() {
    websocket = WebSocketHandler();
    websocket.connectToServer("localhost", 8888, serverMessageHandler);

    final List<String> randomNames = [
      "Alice",
      "Bob",
      "Charlie",
      "David",
      "Eva",
      "Frank",
      "Grace",
      "Hank",
      "Ivy",
      "Jack"
    ];
    final random = Random();
    final randomName = randomNames[random.nextInt(randomNames.length)];
    websocket.sendMessage('{"type": "name", "value": "$randomName"}');
  }
}
