import 'dart:async';
import 'dart:ui';

import 'package:cupertino_base/app_data.dart';
import 'package:cupertino_base/assets.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'ft_game.dart';

class PlayerBird extends SpriteComponent
    with KeyboardHandler, CollisionCallbacks, HasGameReference<FtGame> {

  PlayerBird();

      @override
  Future<FutureOr<void>> onLoad() async {
    /*print(AppData.colorById);
    print(AppData.player_id);
    print(AppData.colorById[AppData.player_id]);

    int colorId = AppData.colorById[AppData.player_id];
    print(colorId.runtimeType);
    final bird = await game.loadSprite(Assets.birdMap[colorId]!);*/
    int colorId = AppData.colorById[AppData.player_id];
    print(AppData.colorById);
    print(AppData.player_id);
    print(AppData.colorById[AppData.player_id]);

    sprite = await Sprite.load(Assets.birdMap[colorId]!);
    size = Vector2.all(64);

    //size = Vector2(40, 50);
    position = Vector2(50, game.size.y/2 - size.y/2);
  }
}