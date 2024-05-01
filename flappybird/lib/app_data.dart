import 'dart:convert';

import 'package:cupertino_base/ft_game.dart';
import 'package:cupertino_base/opponent_bird.dart';
import 'package:cupertino_base/player_bird.dart';
import 'package:cupertino_base/utils_websockets.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/single_child_widget.dart';

enum CurrentScreen { login, waiting, playing }

enum PipePosition { up, down }

enum OpponentSprite { alive, dead }

class AppData with ChangeNotifier {
  CurrentScreen screen = CurrentScreen.login;
  String startCountdown = "Waiting for players...";
  static late WebSocketsHandler websocket;
  static String nickname = "";
  static String player_id = "";
  List<String> lobbyPlayers = [];
  static late Map<String, dynamic> rawLeaderboard;
  static late List<Map<String, dynamic>> finalLeaderboard;
  static List<int> random_numbers = [];
  static Map<String, dynamic> colorById = {};
  static bool isEndGame = false;
  static bool endgameTick2 = false;

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
      //print("Message received: $message");
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

      if (data['type'] == "game_over") {
        print(data);
        Map<String, dynamic> playerScore = data['data']['playerScore'];
        // Sort player scores based on score value
        List<MapEntry<String, dynamic>> sortedPlayerScores = playerScore.entries
            .toList()
          ..sort((a, b) =>
              (b.value['score'] as int).compareTo(a.value['score'] as int));

        // Create ordered list
        finalLeaderboard = sortedPlayerScores
            .map((entry) => {
                  'id': entry.key,
                  'score': entry.value['score'],
                  'nickname': entry.value['nickname'],
                })
            .toList();

        print(finalLeaderboard);
        isEndGame = true;
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

  static void playerDied(double x, double y, int score) {
    if (!PlayerBird.alive) {
      return;
    }
    print(
        '{"type": "died", "x": $x, "y": $y, "nickname":"$nickname", "id":"$player_id", "score":$score}');
    websocket.sendMessage(
        '{"type": "died", "x": $x, "y": $y, "nickname":"$nickname", "id":"$player_id", "score":$score}');
  }

  void updateOpponents(opponentsData) {
    DateTime now = DateTime.now();
    if (lastUpdateTime != null) {
      serverUpdateInterval =
          now.difference(lastUpdateTime!).inMilliseconds / 1000.0;
    }
    lastUpdateTime = now;
    var interpolationSpeed = 1 / serverUpdateInterval;

    //print(opponentsData.toString());
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
