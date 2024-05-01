import 'dart:async';
import 'dart:ui';

import 'package:cupertino_base/app_data.dart';
import 'package:cupertino_base/assets.dart';
import 'package:cupertino_base/configuration.dart';
import 'package:cupertino_base/opponent_bird.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ft_game.dart';

class PlayerBird extends SpriteComponent
    with KeyboardHandler, CollisionCallbacks, HasGameReference<FtGame> {
  String id = "";
  bool alive = true;

  Vector2 previousPosition = Vector2.zero();
  int previousHorizontalDirection = 0;
  int previousVerticalDirection = 0;

  final double moveSpeed = 200;

  PlayerBird({required this.id});

  @override
  Future<FutureOr<void>> onLoad() async {
    int colorId = AppData.colorById[AppData.player_id];

    sprite = await Sprite.load(Assets.birdMap[colorId]!);
    size = Vector2.all(64);

    //size = Vector2(40, 50);
    previousPosition = Vector2(50, game.size.y / 2 - size.y / 2);
    position = previousPosition;

    add(CircleHitbox());
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.space) && alive) {
      fly();
    }

    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += Config.birdVelocity * dt;
    if (position.y >= game.size.y - size.y) {
      gameOver();
    }
    AppData.websocket.sendMessage(
        '{"type": "move", "x": ${position.x}, "y": ${position.y}}');
  }

  void fly() {
    add(
      MoveByEffect(
        Vector2(0, Config.gravity),
        EffectController(duration: 0.2, curve: Curves.decelerate),
      ),
    );
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is OpponentBird) {
      return;
    }
    print("asdasdasdKJSOIDAOIDNAONDOAD" + other.runtimeType.toString());
    gameOver();
  }

  void gameOver() {
    //game.overlays.add('gameOver');
    //game.pauseEngine();

    //game.pauseEngine();
    AppData.playerDied(x, y);
    alive = false;
  }
}
