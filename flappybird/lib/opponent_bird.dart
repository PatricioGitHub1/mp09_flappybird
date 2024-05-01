import 'dart:math';

import 'package:cupertino_base/app_data.dart';
import 'package:cupertino_base/assets.dart';
import 'package:cupertino_base/ft_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

class OpponentBird extends SpriteGroupComponent<OpponentSprite>
    with HasGameReference<FtGame> {
  String id = "";

  Vector2 previousPosition = Vector2.zero();
  int previousHorizontalDirection = 0;
  int previousVerticalDirection = 0;

  double moveSpeed = 200;

  Vector2 targetPosition = Vector2.zero(); // Posició objectiu (la del servidor)
  double interpolationSpeed = 10;

  OpponentBird({required this.id});

  @override
  Future<void> onLoad() async {
    int colorId = AppData.colorById[id];

    final aliveSprite = await Sprite.load(Assets.birdMap[colorId]!);
    final deadSprite = await Sprite.load('boom.png');
    sprites = {
      OpponentSprite.alive: aliveSprite,
      OpponentSprite.dead: deadSprite
    };

    size = Vector2.all(64);
    current = OpponentSprite.alive;
    //size = Vector2(40, 50);

    previousPosition = Vector2(50, game.size.y / 2 - size.y / 2);
    position = previousPosition;

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    // Defineix un factor d'interpolació. Per exemple, 0.1 per un 10% del camí per frame
    double lerpFactor = interpolationSpeed * dt;

    // Calcula la nova posició com una interpolació lineal entre la posició actual i la targetPosition
    position =
        position + (targetPosition - position) * lerpFactor.clamp(0.0, 1.0);

    super.update(dt);
  }
}
