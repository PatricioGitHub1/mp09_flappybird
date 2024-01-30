import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'ft_game.dart';

class FtPlayer extends SpriteComponent
    with KeyboardHandler, CollisionCallbacks, HasGameReference<FtGame> {
  FtPlayer({required this.id, required super.position, required this.color})
      : super(size: Vector2.all(64), anchor: Anchor.center);

  String id = "";
  Color color = const Color.fromARGB(255, 175, 175, 175);

  Vector2 previousPosition = Vector2.zero();
  int previousHorizontalDirection = 0;
  int previousVerticalDirection = 0;

  final double moveSpeed = 200;
  int horizontalDirection = 0;
  int verticalDirection = 0;

  @override
  Future<void> onLoad() async {
    priority = 1; // Dibuixar-lo per sobre de tot
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
    center.add(Vector2(horizontalDirection * moveSpeed * dt,
        verticalDirection * moveSpeed * dt));

    Vector2 newPosition = center.clone();
    if (newPosition != previousPosition ||
        horizontalDirection != previousHorizontalDirection ||
        verticalDirection != previousVerticalDirection) {
      // Enviar les dades al servidor, només si s'han produït canvis
      game.websocket.sendMessage(
          '{"type": "move", "x": ${position.x}, "y": ${position.y}, "horizontalDirection": $horizontalDirection, "verticalDirection": $verticalDirection}');

      previousPosition.setFrom(newPosition);
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is FtPlayer) {
      return;
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Preparar el Paint amb color i opacitat
    final paint = Paint()
      ..colorFilter =
          ColorFilter.mode(color.withOpacity(0.5), BlendMode.srcATop)
      ..filterQuality = FilterQuality.high;

    // Renderitzar el sprite amb el Paint personalitzat
    sprite?.render(canvas, size: size, overridePaint: paint);
  }
}
