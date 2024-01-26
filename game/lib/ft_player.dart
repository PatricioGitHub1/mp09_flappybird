import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'ft_game.dart';

class FtPlayer extends SpriteComponent
    with KeyboardHandler, CollisionCallbacks, HasGameReference<FtGame> {
  FtPlayer({required super.position})
      : super(size: Vector2.all(64), anchor: Anchor.center);

  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 200;
  int horizontalDirection = 0;
  int verticalDirection = 0;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('player.png');
    size = Vector2.all(64);
    add(CircleHitbox());
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Modificar la direcció horitzontal basada en les tecles dreta i esquerra
    horizontalDirection = 0;
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      horizontalDirection -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      horizontalDirection += 1;
    }

    // Modificar la direcció vertical basada en les tecles amunt i avall
    verticalDirection = 0;
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      verticalDirection -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      verticalDirection += 1;
    }

    return false;
  }

  @override
  void update(double dt) {
    position.add(Vector2(horizontalDirection * moveSpeed * dt,
        verticalDirection * moveSpeed * dt));
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is FtPlayer) {
      return;
    }

    super.onCollision(intersectionPoints, other);
  }
}
