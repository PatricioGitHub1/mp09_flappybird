import 'dart:convert';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ft_opponent.dart';
import 'ft_player.dart';
import 'websocket_handler.dart';

class FtGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  FtGame();

  late WebSocketHandler websocket;
  FtPlayer? _player;
  final List<FtOpponent> _opponents = [];

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

  void reset() {
    initializeGame(loadHud: false);
  }

  void initializeGame({required bool loadHud}) {
    // Initialize websocket
    initializeWebSocket();
  }

  void initializeWebSocket() {
    websocket = WebSocketHandler();
    websocket.connectToServer("localhost", 8888, serverMessageHandler);
  }

  void serverMessageHandler(String message) {
    if (kDebugMode) {
      // print("Message received: $message");
    }

    // Processar els missatges rebuts
    final data = json.decode(message);

    // Comprovar si 'data' és un Map i si 'type' és igual a 'data'
    if (data is Map<String, dynamic>) {
      if (data['type'] == 'welcome') {
        initPlayer(data['id'].toString());
      }
      if (data['type'] == 'data') {
        var value = data['value'];
        if (value is List) {
          updateOpponents(value);
        }
      }
    }
  }

  void initPlayer(String id) {
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
    Color playerColor = getRandomColor();
    _player = FtPlayer(
        id: id,
        position: Vector2((canvasSize.x / 2), (canvasSize.y / 2)),
        color: playerColor);
    world.add(_player as Component);

    websocket.sendMessage(
        '{"type": "init", "name": "$randomName", "color": "${colorToHex(playerColor)}"}');
  }

  void updateOpponents(List<dynamic> opponentsData) {
    // Crea una llista amb els ID dels oponents actuals
    final currentOpponentIds = _opponents.map((op) => op.id).toList();

    if (_player == null) {
      return;
    }

    for (var opponentData in opponentsData) {
      final id = opponentData['id'];
      double clientX = -100.0;
      double clientY = -100.0;
      String clientColor = "0x00000000";

      if (id == _player?.id || opponentData['clientName'] == null) {
        // No tenim nom, no podem crear l'oponent
        // (o bé és el nostre player que encara no ha informat el nom al servidor)
        continue;
      }

      if (opponentData['clientColor'] != null) {
        clientColor = opponentData['clientColor'];
      }
      if (opponentData['clientX'] != null) {
        clientX = opponentData['clientX'].toDouble();
      }
      if (opponentData['clientY'] != null) {
        clientY = opponentData['clientY'].toDouble();
      }

      if (!currentOpponentIds.contains(id)) {
        // Afegir l'oponent nou
        var newOpponent = FtOpponent(
          id: id,
          position: Vector2(clientX, clientY),
          color: hexToColor(clientColor),
        );
        if (newOpponent.id != _player?.id) {
          _opponents.add(newOpponent);
          world.add(newOpponent);
        }
      } else {
        // Actualitzar la posició de l'oponent existent
        var opponent = _opponents.firstWhere((op) => op.id == id);
        if (opponent.id != _player?.id) {
          opponent.position = Vector2(clientX, clientY);
          //opponent.color = hexToColor(clientColor);
        }
      }
    }

    // Eliminar oponents que ja no estan en la llista
    _opponents.removeWhere((opponent) {
      bool shouldRemove =
          !opponentsData.any((data) => data['id'] == opponent.id);
      if (shouldRemove) {
        world.remove(opponent);
      }
      return shouldRemove;
    });
  }

  Color hexToColor(String hexString) {
    // Eliminar el prefix '0x' si està present
    hexString = hexString.replaceFirst('0x', '');

    // Si la cadena comença amb '#', eliminar-ho
    if (hexString.startsWith('#')) {
      hexString = hexString.substring(1);
    }

    // Si només tenim 6 caràcters, afegir 'ff' al principi per l'opacitat
    if (hexString.length == 6) {
      hexString = 'ff$hexString';
    }

    // Convertir la cadena en un enter i crear un Color
    return Color(int.parse(hexString, radix: 16));
  }

  String colorToHex(Color color) {
    return '0x${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  Color getRandomColor() {
    final random = Random();
    final hue = random.nextDouble() * 360;
    return HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
  }
}
