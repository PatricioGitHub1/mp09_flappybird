import 'package:cupertino_base/ft_game.dart';
import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget {
  final FtGame game;

  const GameOverScreen({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black38,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(
                  fontSize: 60,
                  color: Colors.orange,
                  fontFamily: 'Game',
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Text(
                'Score: ${game.playerBird.score}',
                style: const TextStyle(
                  fontSize: 60,
                  color: Colors.white,
                  fontFamily: 'Game',
                ),
              ),
            ],
          ),
        ),
      );
}
