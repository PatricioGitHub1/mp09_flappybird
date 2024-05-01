import 'dart:convert';

import 'package:cupertino_base/ft_game.dart';
import 'package:cupertino_base/opponent_bird.dart';
import 'package:cupertino_base/utils_websockets.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/single_child_widget.dart';

enum CurrentScreen { login, waiting, playing }

enum PipePosition { up, down }

enum OpponentSprite { alive, dead }

class AppData with ChangeNotifier {
  CurrentScreen screen = CurrentScreen.login;
  String startCountdown = "Waiting for players...";
  static late WebSocketsHandler websocket;
  String nickname = "";
  static String player_id = "";
  List<String> lobbyPlayers = [];
  static List<int> random_numbers = [];
  static Map<String, dynamic> colorById = {};

  DateTime? lastUpdateTime;
  double serverUpdateInterval = 0;

  void forceNotifyListeners() {
    super.notifyListeners();
  }

  void initializeWebSocket(String ip, int port) {
    websocket = WebSocketsHandler();
    websocket.connectToServer(ip, port, serverMessageHandler);
  }

  void serverMessageHandler(String message) {
    if (kDebugMode) {
      print("Message received: $message");
    }

    // Processar els missatges rebuts
    final data = json.decode(message);

    // Comprovar si 'data' és un Map i si 'type' és igual a 'data'
    if (data is Map<String, dynamic>) {
      if (data['type'] == 'welcome') {
        screen = CurrentScreen.waiting;
        player_id = data['id'];
        notifyListeners();
        //initPlayer(data['id'].toString());
        initPlayer(nickname);
      }
      if (data['type'] == 'data') {
        var value = data['value'];
        if (value is List) {
          updateOpponents(value);
        }
        /*
        print(data);
        if (FtGame.idPlayerMap.containsKey(data['id']) &&
            data['id'] != player_id) {
          updateOpponents(data);
        }*/
      }

      if (data['type'] == 'players_names') {
        List<dynamic> names = data['value']['names'];
        colorById = data['value']['colors'];
        lobbyPlayers = names.map((item) => item.toString()).toList();
        notifyListeners();
      }

      if (data['type'] == 'game_start') {
        screen = CurrentScreen.waiting;
        random_numbers = data['value']['random_numbers'].cast<int>();
        List<String> contador = ["Game starting in...", "3", "2", "1", "GO"];
        startCountdownSequence(contador);
      }
    }
  }

  void startCountdownSequence(List<String> stringss) async {
    for (String text in stringss) {
      startCountdown = text;
      notifyListeners();
      print("se deberia ver delay");
      await Future.delayed(const Duration(seconds: 1));
    }

    screen = CurrentScreen.playing;
    notifyListeners();
  }

  void initPlayer(String nickname) {
    websocket.sendMessage('{"type": "init", "name": "$nickname"}');
  }

  static void playerDied(double x, double y) {
    websocket.sendMessage('{"type": "died", "x": $x, "y": $y}');
  }

  void updateOpponents(opponentsData) {
    DateTime now = DateTime.now();
    if (lastUpdateTime != null) {
      serverUpdateInterval =
          now.difference(lastUpdateTime!).inMilliseconds / 1000.0;
    }
    lastUpdateTime = now;
    var interpolationSpeed = 1 / serverUpdateInterval;

    print(opponentsData.toString());
    for (var opponentData in opponentsData) {
      final id = opponentData['id'];
      if (FtGame.idPlayerMap.containsKey(id)) {
        OpponentBird opponent = FtGame.idPlayerMap[id]!;

        double clientX = -100.0;
        double clientY = -100.0;

        if (opponentData['x'] != null) {
          clientX = opponentData['x'].toDouble();
        }
        if (opponentData['y'] != null) {
          clientY = opponentData['y'].toDouble();
        }

        if (opponentData['alive'] == false) {
          clientX = -20.0;
          opponent.current = OpponentSprite.dead;
          opponent.moveSpeed = 30;
          FtGame.idPlayerMap.remove(id);
        }

        opponent.interpolationSpeed = interpolationSpeed;
        opponent.targetPosition = Vector2(clientX, clientY);
      }
    }
  }
}
