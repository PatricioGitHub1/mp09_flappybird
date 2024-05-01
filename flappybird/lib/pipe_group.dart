import 'package:cupertino_base/app_data.dart';
import 'package:cupertino_base/configuration.dart';
import 'package:cupertino_base/ft_game.dart';
import 'package:cupertino_base/pipe.dart';
import 'package:cupertino_base/player_bird.dart';
import 'package:flame/components.dart';

class PipeGroup extends PositionComponent with HasGameRef<FtGame> {
  PipeGroup();

  @override
  Future<void> onLoad() async {
    position.x = gameRef.size.x;
    final heightt = gameRef.size.y;
    final spacing = 300 + getNumberThenDelete() * (heightt / 4);
    final centerY = spacing + getNumberThenDelete() * (heightt - spacing);

    addAll([
      Pipe(pipePosition: PipePosition.up, height: centerY - spacing / 2),
      Pipe(
          pipePosition: PipePosition.down,
          height: heightt - (centerY + spacing / 2))
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= Config.gameSpeed * dt;

    if (position.x < -20) {
      removeFromParent();
      updateScore();
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
    return number / 100;
  }

  void updateScore() {
    if (PlayerBird.alive) {
      gameRef.playerBird.score += 1;
      AppData.websocket.sendMessage(
          '{"type": "score", "id": "${AppData.player_id}", "score": ${gameRef.playerBird.score}}');
    }
  }
}
