import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'ft_game.dart';

class FtOpponent extends SpriteComponent with HasGameReference<FtGame> {
  FtOpponent({required this.id, required super.position, required this.color})
      : super(size: Vector2.all(64), anchor: Anchor.center);

  String id = "";
  Color color = const Color.fromARGB(255, 0, 0, 0);

  final double moveSpeed = 200;
  int horizontalDirection = 0;
  int verticalDirection = 0;

  @override
  Future<void> onLoad() async {
    priority = 0; // Dibuixar-lo per sota del player
    sprite = await Sprite.load('player.png');
    size = Vector2.all(64);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    center.add(Vector2(horizontalDirection * moveSpeed * dt,
        verticalDirection * moveSpeed * dt));

    super.update(dt);
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
