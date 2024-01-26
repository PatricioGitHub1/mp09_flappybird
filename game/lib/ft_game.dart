import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'ft_player.dart';

class FtGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  FtGame();

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
    _player = FtPlayer(
      position: Vector2((canvasSize.x / 2), (canvasSize.y / 2)),
    );
    world.add(_player);
  }

  void reset() {
    initializeGame(loadHud: false);
  }
}
