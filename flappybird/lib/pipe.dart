import 'dart:async';
import 'dart:ui';

import 'package:cupertino_base/app_data.dart';
import 'package:cupertino_base/assets.dart';
import 'package:cupertino_base/ft_game.dart';
import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class Pipe extends SpriteComponent with HasGameRef<FtGame> {
  Pipe({
    required this.pipePosition,
    required this.height,
  });

  @override
  final double height;
  final PipePosition pipePosition;

  @override
  Future<void> onLoad() async {
    int retryCount = 0;
    bool assetLoaded = false;

    Image? pipe;
    Image? pipeRotated;

    while (!assetLoaded) {
      try {
        pipe = await Flame.images.load(Assets.pipe);
        pipeRotated = await Flame.images.load(Assets.rotated_pipe);
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

    size = Vector2(50, height);

    switch (pipePosition) {
      case PipePosition.up:
        position.y = 0;
        sprite = Sprite(pipeRotated!);
        break;
      case PipePosition.down:
        position.y = gameRef.size.y - size.y;
        sprite = Sprite(pipe!);
        break;
    }

    add(RectangleHitbox());
  }
}
