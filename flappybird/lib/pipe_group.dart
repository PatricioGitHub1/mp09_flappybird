import 'package:cupertino_base/app_data.dart';
import 'package:cupertino_base/configuration.dart';
import 'package:cupertino_base/ft_game.dart';
import 'package:cupertino_base/pipe.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PipeGroup extends PositionComponent with HasGameRef<FtGame> {
  PipeGroup();

  @override
  Future<void> onLoad() async {
    
    position.x = gameRef.size.x;
    final heightt = gameRef.size.y;
    final spacing = 100 + getNumberThenDelete() * (heightt / 4);
    final centerY = spacing + getNumberThenDelete() * (heightt - spacing);

    addAll([
        Pipe(pipePosition: PipePosition.up, height: centerY - spacing / 2),
        Pipe(pipePosition: PipePosition.down, height: heightt - (centerY + spacing / 2))
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= Config.gameSpeed * dt;

    if (position.x < -20) {
      removeFromParent();
      debugPrint("Removed pipe");
    }
  }
  /*void updateScore() {
    gameRef.bird.score += 1;
    FlameAudio.play(Assets.point);
  }
  
  

    if (position.x < -10) {
      removeFromParent();
      updateScore();
    }

    if (gameRef.isHit) {
      removeFromParent();
      gameRef.isHit = false;
    }
  }*/

  static double getNumberThenDelete() {
    int number = AppData.random_numbers[0];
    AppData.random_numbers.removeAt(0);
    return number/100;
  }
}