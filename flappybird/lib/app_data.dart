import 'dart:convert';

import 'package:cupertino_base/ft_game.dart';
import 'package:cupertino_base/utils_websockets.dart';
import 'package:flutter/foundation.dart';

enum CurrentScreen {
    login,
    waiting,
    playing
}

enum PipePosition {
  up,
  down
}

class AppData with ChangeNotifier {
  CurrentScreen screen = CurrentScreen.login;
  String startCountdown = "Waiting for players...";
  late WebSocketsHandler websocket;
  String nickname = "";
  static String player_id = "";
  List<String> lobbyPlayers = [];
  static List<int> random_numbers  = [];
  static Map<String, dynamic> colorById = {};

  void forceNotifyListeners() {
    super.notifyListeners();
  }

  void initializeWebSocket(String ip, int port) {
    websocket = WebSocketsHandler();
    websocket.connectToServer(ip, port , serverMessageHandler);
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
          //updateOpponents(value);
        }
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

    websocket.sendMessage(
        '{"type": "init", "name": "$nickname"}');
  }

}