import 'dart:convert';
import 'dart:math';

import 'package:cupertino_base/configuration.dart';
import 'package:cupertino_base/pipe_group.dart';
import 'package:cupertino_base/player_bird.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ft_opponent.dart';
import 'ft_player.dart';
import 'utils_websockets.dart';

class FtGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  FtGame();
  Timer interval = Timer(Config.pipeInterval, repeat: true);

  late WebSocketsHandler websocket;
  FtPlayer? _player;
  final List<FtOpponent> _opponents = [];

  // flappy birdssss
  late PlayerBird playerBird;

  DateTime? lastUpdateTime;
  double serverUpdateInterval = 0; // En segons

  @override
  Future<void> onLoad() async {
    int retryCount = 0;
    bool assetLoaded = false;

    while (!assetLoaded) {
      try {
        await images.loadAll([
          'bluebird.png',
          'multicolorbird.png',
          'redbird.png',
          'yellowbird.png',
          'player.png',
          'rocket.png',
          'pipe.png',
          'pipe_rotated.png'
        ]);
        assetLoaded = true;
      } catch (e) {
        print('Error loading assets');
        retryCount++;
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (retryCount == 5) {
        break;
      }
    }

    camera.viewfinder.anchor = Anchor.topLeft;
    
    addAll([
      playerBird = PlayerBird(),
    ]);

    interval.onTick = () => add(PipeGroup());
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  void reset() {
    //initializeGame(loadHud: false);
  }

  /*void initializeGame({required bool loadHud}) {
    // Initialize websocket
    initializeWebSocket();
  }

  void initializeWebSocket() {
    websocket = WebSocketsHandler();
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

  static void initPlayer(String id, String nickname) {

    websocket.sendMessage(
        '{"type": "init", "name": "$randomName", "color": "${colorToHex(playerColor)}"}');
  }*/

  void updateOpponents(List<dynamic> opponentsData) {
    // Crea una llista amb els ID dels oponents actuals
    final currentOpponentIds = _opponents.map((op) => op.id).toList();

    if (_player == null) {
      return;
    }

    DateTime now = DateTime.now();
    if (lastUpdateTime != null) {
      serverUpdateInterval =
          now.difference(lastUpdateTime!).inMilliseconds / 1000.0;
    }
    lastUpdateTime = now;
    var interpolationSpeed = 1 / serverUpdateInterval;

    for (var opponentData in opponentsData) {
      final id = opponentData['id'];
      String clientColor = "0x00000000";
      double clientX = -100.0;
      double clientY = -100.0;

      if (id == _player?.id || opponentData['name'] == null) {
        // No tenim nom, no podem crear l'oponent
        // (o bé és el nostre player que encara no ha informat el nom al servidor)
        continue;
      }

      if (opponentData['color'] != null) {
        clientColor = opponentData['color'];
      }
      if (opponentData['x'] != null) {
        clientX = opponentData['x'].toDouble();
      }
      if (opponentData['y'] != null) {
        clientY = opponentData['y'].toDouble();
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
        // Definir la posició fins a la que s'ha de interpolar la posició de l'oponent
        var opponent = _opponents.firstWhere((op) => op.id == id);
        opponent.interpolationSpeed = interpolationSpeed;
        opponent.targetPosition = Vector2(clientX, clientY);
        // opponent.color = hexToColor(clientColor);
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
